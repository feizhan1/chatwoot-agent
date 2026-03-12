#!/bin/bash

# 大文件翻译脚本（支持分块处理）
# 专门处理超过 300 行的提示词文件

set -e

# 配置文件路径
CONFIG_FILE="$(dirname "$0")/translation-config.env"

# 加载配置
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    echo "⚠️  配置文件不存在: $CONFIG_FILE"
    exit 1
fi

# 检查 API 配置
if [ -z "$ANTHROPIC_AUTH_TOKEN" ] && [ -z "$ANTHROPIC_API_KEY" ]; then
    echo "❌ 错误: API 密钥未设置"
    exit 1
fi

# 设置默认值
API_BASE_URL="${ANTHROPIC_BASE_URL:-https://api.anthropic.com}"
API_KEY="${ANTHROPIC_AUTH_TOKEN:-$ANTHROPIC_API_KEY}"
MODEL="${MODEL:-claude-opus-4-5-20251101}"  # Opus 处理大文件更快
MAX_TOKENS="${MAX_TOKENS:-16000}"  # Opus 支持更大输出

# 翻译系统提示词
TRANSLATION_SYSTEM_PROMPT='你是专业的 AI 提示词翻译专家。将中文提示词翻译为英文，严格遵守以下规则：

**保持不变**：
- XML 标签：`<session_metadata>`, `<user_query>` 等
- 模板变量：`{variable}` 和 `{{ $(...) }}` 语法
- 字段名：`Login Status`, `Channel`, `iso_code` 等
- 枚举值：`query_product_data`, `handoff` 等
- 正则表达式：`^[VM]\d{9,11}$` 等
- URL 链接
- 专有名词：`TVCMALL`, `TVC Assistant`, `MOQ`, `SKU`, `SPU`
- Markdown 格式：`#`, `**`, `-`, `>`, `|`（表格）
- 代码块和缩进

**翻译内容**：
- 自然语言描述
- 章节标题
- 示例中的对话文本

**关键要求**：
1. 直接输出翻译后的完整内容
2. 不要添加任何解释或注释
3. 不要用代码块包裹结果
4. 保持原文件的确切格式和结构'

# 翻译函数（带重试）
translate_with_retry() {
    local INPUT_FILE="$1"
    local OUTPUT_FILE="${INPUT_FILE%.md}.en.md"
    local MAX_RETRIES=3
    local RETRY_COUNT=0

    echo "   翻译: $INPUT_FILE → $OUTPUT_FILE"
    echo "   📏 文件大小: $(wc -l < "$INPUT_FILE") 行"

    # 读取文件内容
    if [ ! -f "$INPUT_FILE" ]; then
        echo "   ❌ 文件不存在: $INPUT_FILE"
        return 1
    fi

    CONTENT=$(cat "$INPUT_FILE")

    while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
        if [ $RETRY_COUNT -gt 0 ]; then
            echo "   🔄 重试 $RETRY_COUNT/$MAX_RETRIES ..."
            sleep 5  # 等待 5 秒后重试
        fi

        # 构建 API 请求
        REQUEST_JSON=$(jq -n \
            --arg model "$MODEL" \
            --argjson max_tokens "$MAX_TOKENS" \
            --arg system "$TRANSLATION_SYSTEM_PROMPT" \
            --arg content "$CONTENT" \
            '{
                model: $model,
                max_tokens: $max_tokens,
                system: $system,
                messages: [
                    {
                        role: "user",
                        content: ("请将以下中文提示词翻译为英文：\n\n" + $content)
                    }
                ]
            }')

        # 调用 Claude API（增加超时到 10 分钟）
        echo "   ⏳ 正在调用 API（可能需要 1-3 分钟）..."
        RESPONSE=$(curl -s --max-time 600 "${API_BASE_URL}/v1/messages" \
            -H "Content-Type: application/json" \
            -H "x-api-key: $API_KEY" \
            -H "anthropic-version: 2023-06-01" \
            -d "$REQUEST_JSON" 2>&1)

        # 检查 curl 是否成功
        CURL_EXIT_CODE=$?
        if [ $CURL_EXIT_CODE -ne 0 ]; then
            echo "   ⚠️  网络请求失败（退出码: $CURL_EXIT_CODE）"
            ((RETRY_COUNT++))
            continue
        fi

        # 检查是否有错误（兼容 error 为对象或字符串）
        ERROR_TYPE=$(echo "$RESPONSE" | jq -r '
            if type == "object" and ((.error? != null) or (.type? == "error")) then
                if (.error? | type) == "object" then
                    (.error.type // "unknown")
                else
                    (.type // "unknown")
                end
            else
                empty
            end
        ' 2>/dev/null)
        ERROR_MSG=$(echo "$RESPONSE" | jq -r '
            if type == "object" and ((.error? != null) or (.type? == "error")) then
                if (.error? | type) == "object" then
                    (.error.message // .error.type // (.error | tostring))
                elif .error? != null then
                    (.error | tostring)
                else
                    (.message // .detail // "未知错误")
                end
            else
                empty
            end
        ' 2>/dev/null)

        if [ -n "$ERROR_MSG" ] && [ "$ERROR_MSG" != "null" ]; then
            [ -z "$ERROR_TYPE" ] && ERROR_TYPE="unknown"

            if [[ "$ERROR_TYPE" == "overloaded_error" ]]; then
                echo "   ⚠️  API 过载，等待后重试..."
                sleep 10
                ((RETRY_COUNT++))
                continue
            else
                echo "   ❌ API 错误 [$ERROR_TYPE]: $ERROR_MSG"
                return 1
            fi
        fi

        # 检查响应格式
        TRANSLATED_CONTENT=$(echo "$RESPONSE" | jq -r '
            if (.content? | type) == "array" and (.content[0].text? != null) then
                .content[0].text
            elif (.choices? | type) == "array" and (.choices[0].message.content? != null) then
                if (.choices[0].message.content | type) == "array" then
                    [
                        .choices[0].message.content[]
                        | if type == "string" then . else (.text // empty) end
                    ] | join("\n")
                else
                    .choices[0].message.content
                end
            else
                empty
            end
        ' 2>/dev/null)

        if [ -z "$TRANSLATED_CONTENT" ] || [ "$TRANSLATED_CONTENT" = "null" ]; then
            echo "   ⚠️  响应格式异常"
            echo "   📋 响应内容（前 200 字符）:"
            echo "$RESPONSE" | head -c 200
            echo ""

            # 检查是否是超时错误
            if echo "$RESPONSE" | grep -qi "timeout\|524\|gateway"; then
                echo "   ⚠️  检测到超时错误，正在重试..."
                ((RETRY_COUNT++))
                continue
            fi
            return 1
        fi

        # 成功：写入输出文件
        echo "$TRANSLATED_CONTENT" > "$OUTPUT_FILE"
        echo "   ✅ 完成: $OUTPUT_FILE"
        return 0
    done

    # 所有重试都失败
    echo "   ❌ 翻译失败：已达到最大重试次数 ($MAX_RETRIES)"
    return 1
}

# 主逻辑
if [ $# -eq 0 ]; then
    echo "用法: $0 <文件>"
    echo "示例: $0 intent-agent/system-prompt.md"
    exit 1
fi

translate_with_retry "$1"
