#!/bin/bash

# 分块翻译提示词脚本（用于处理大文件）
# 将大文件分成多个部分，分别翻译后合并

set -e

CONFIG_FILE="$(dirname "$0")/translation-config.env"

if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    echo "❌ 配置文件不存在: $CONFIG_FILE"
    exit 1
fi

if [ -z "$ANTHROPIC_AUTH_TOKEN" ] && [ -z "$ANTHROPIC_API_KEY" ]; then
    echo "❌ 错误: ANTHROPIC_AUTH_TOKEN 或 ANTHROPIC_API_KEY 未设置"
    exit 1
fi

API_BASE_URL="${ANTHROPIC_BASE_URL:-https://api.anthropic.com}"
API_KEY="${ANTHROPIC_AUTH_TOKEN:-$ANTHROPIC_API_KEY}"
MODEL="${MODEL:-claude-sonnet-4-5-20250929}"
MAX_TOKENS="${MAX_TOKENS:-8000}"

# 每个块的最大行数（根据文件复杂度调整）
CHUNK_SIZE=200

TRANSLATION_SYSTEM_PROMPT='你是专业的 AI 提示词翻译专家。将中文提示词翻译为英文，严格遵守以下规则：

**保持不变**：
- XML 标签：`<session_metadata>`, `<user_query>` 等
- 模板变量：`{variable}` 格式
- 字段名：`Login Status`, `Channel`, `iso_code` 等
- 枚举值：`query_product_data`, `handoff` 等
- URL 链接
- 专有名词：`TVCMALL`, `TVC Assistant`, `MOQ`, `SKU`
- Markdown 格式：`#`, `**`, `-`, `>`, 缩进
- 代码块和示例中的 JSON 字段名

**翻译内容**：
- 自然语言描述和说明
- 章节标题（但保持 Markdown 格式）
- 示例中的用户话术和回复内容

**关键要求**：
1. 直接输出翻译后的内容，不添加任何解释
2. 不要用代码块包裹结果
3. 保持原文件的确切格式和结构
4. 保持换行和缩进'

translate_chunk() {
    local CONTENT="$1"
    local CHUNK_NUM="$2"
    local ERROR_MSG

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
                    content: ("请翻译以下部分（这是大文件的第" + ($chunk_num | tostring) + "部分）：\n\n" + $content)
                }
            ]
        }' --arg chunk_num "$CHUNK_NUM")

    if ! RESPONSE=$(curl -sS "${API_BASE_URL}/v1/messages" \
        -H "Content-Type: application/json" \
        -H "x-api-key: $API_KEY" \
        -H "anthropic-version: 2023-06-01" \
        -d "$REQUEST_JSON" 2>&1); then
        echo "   ❌ 网络请求失败: $(echo "$RESPONSE" | head -c 200)"
        return 1
    fi

    # 检查错误
    if echo "$RESPONSE" | grep -q "error code:"; then
        echo "   ❌ API 错误: $(echo "$RESPONSE" | head -c 200)"
        return 1
    fi

    ERROR_MSG=$(echo "$RESPONSE" | jq -r '
        if type == "object" and ((.error? != null) or (.type? == "error")) then
            if (.error? | type) == "object" then
                (.error.message // .error.type // (.error | tostring))
            elif .error? != null then
                (.error | tostring)
            else
                (.message // .detail // "unknown error")
            end
        else
            empty
        end
    ' 2>/dev/null)
    if [ -n "$ERROR_MSG" ] && [ "$ERROR_MSG" != "null" ]; then
        echo "   ❌ API 错误: $ERROR_MSG"
        return 1
    fi

    # 提取内容
    TRANSLATED=$(echo "$RESPONSE" | jq -r '
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

    if [ $? -ne 0 ] || [ -z "$TRANSLATED" ] || [ "$TRANSLATED" = "null" ]; then
        echo "   ❌ 翻译失败"
        return 1
    fi

    echo "$TRANSLATED"
    return 0
}

translate_file_chunked() {
    local INPUT_FILE="$1"
    local OUTPUT_FILE="${INPUT_FILE%.md}.en.md"

    echo "   翻译（分块）: $INPUT_FILE → $OUTPUT_FILE"

    if [ ! -f "$INPUT_FILE" ]; then
        echo "   ❌ 文件不存在: $INPUT_FILE"
        return 1
    fi

    # 计算总行数
    TOTAL_LINES=$(wc -l < "$INPUT_FILE")
    CHUNK_COUNT=$(( ($TOTAL_LINES + $CHUNK_SIZE - 1) / $CHUNK_SIZE ))

    echo "   📄 文件总行数: $TOTAL_LINES"
    echo "   📦 将分为 $CHUNK_COUNT 个块（每块 ~$CHUNK_SIZE 行）"

    # 创建临时目录
    TEMP_DIR=$(mktemp -d)
    trap "rm -rf $TEMP_DIR" EXIT

    # 翻译每个块
    for ((i=1; i<=CHUNK_COUNT; i++)); do
        START_LINE=$(( ($i - 1) * $CHUNK_SIZE + 1 ))
        END_LINE=$(( $i * $CHUNK_SIZE ))

        echo "   🔄 翻译块 $i/$CHUNK_COUNT (行 $START_LINE-$END_LINE)..."

        # 提取块内容
        CHUNK_CONTENT=$(sed -n "${START_LINE},${END_LINE}p" "$INPUT_FILE")

        # 翻译块
        if ! translate_chunk "$CHUNK_CONTENT" "$i" > "$TEMP_DIR/chunk_$i.txt"; then
            echo "   ❌ 块 $i 翻译失败"
            return 1
        fi

        sleep 1  # 避免速率限制
    done

    # 合并所有块
    echo "   🔗 合并翻译结果..."
    cat "$TEMP_DIR"/chunk_*.txt > "$OUTPUT_FILE"

    echo "   ✅ 完成: $OUTPUT_FILE"
    return 0
}

# 主逻辑
if [ $# -eq 0 ]; then
    echo "用法: $0 <文件1> [文件2] ..."
    echo "示例: $0 intent-agent/system-prompt.md"
    exit 1
fi

SUCCESS_COUNT=0
FAIL_COUNT=0

for file in "$@"; do
    if translate_file_chunked "$file"; then
        ((SUCCESS_COUNT++))
    else
        ((FAIL_COUNT++))
    fi
done

echo ""
echo "📊 翻译统计: ✅ 成功 $SUCCESS_COUNT 个 | ❌ 失败 $FAIL_COUNT 个"

if [ $FAIL_COUNT -gt 0 ]; then
    exit 1
fi

exit 0
