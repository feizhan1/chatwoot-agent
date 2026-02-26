#!/bin/bash

# 自动翻译提示词脚本（中文 → 英文）
# 使用 Claude API 进行翻译，保持技术结构和格式不变

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# 配置文件路径
CONFIG_FILE="$SCRIPT_DIR/translation-config.env"

# 加载配置
if [ -f "$CONFIG_FILE" ]; then
    # shellcheck disable=SC1090
    source "$CONFIG_FILE"
else
    echo "⚠️  配置文件不存在: $CONFIG_FILE"
    echo "💡 请先运行: ./scripts/setup-translation.sh"
    exit 1
fi

# 规范化提供者名称
TRANSLATION_PROVIDER="$(echo "${TRANSLATION_PROVIDER:-anthropic}" | tr '[:upper:]' '[:lower:]')"

# 提供者相关默认值
case "$TRANSLATION_PROVIDER" in
    openrouter)
        OPENROUTER_BASE_URL="${OPENROUTER_BASE_URL:-https://openrouter.ai/api/v1}"
        MODEL="${MODEL:-${OPENROUTER_MODEL:-anthropic/claude-opus-4.6}}"
        MAX_TOKENS="${MAX_TOKENS:-${OPENROUTER_MAX_TOKENS:-12000}}"
        if [ -z "$OPENROUTER_API_KEY" ]; then
            echo "❌ 错误: OPENROUTER_API_KEY 未设置"
            exit 1
        fi
        ;;
    *)
        API_BASE_URL="${ANTHROPIC_BASE_URL:-https://api.anthropic.com}"
        API_KEY="${ANTHROPIC_AUTH_TOKEN:-$ANTHROPIC_API_KEY}"
        MODEL="${MODEL:-claude-sonnet-4-5-20250929}"
        MAX_TOKENS="${MAX_TOKENS:-8000}"
        if [ -z "$API_KEY" ]; then
            echo "❌ 错误: ANTHROPIC_AUTH_TOKEN 或 ANTHROPIC_API_KEY 未设置"
            echo "💡 请在 $CONFIG_FILE 中设置您的认证信息"
            exit 1
        fi
        ;;
esac

# 翻译系统提示词（翻译指令）
TRANSLATION_SYSTEM_PROMPT='你是专业的 AI 提示词翻译专家。将中文提示词翻译为英文，严格遵守以下规则：

**保持不变**：
- XML 标签：`<session_metadata>`, `<user_query>` 等
- 模板变量：`{{ $(...) }}` 语法完全保持
- 字段名：`Login Status`, `Channel`, `iso_code` 等
- 枚举值：`query_product_data`, `handoff` 等
- URL 链接
- 专有名词：`TVCMALL`, `TVC Assistant`, `MOQ`, `SKU`
- Markdown 格式：`#`, `**`, `-`, `>`, 缩进
- 换行符：`\n\n`

**翻译内容**：
- 自然语言描述
- 章节标题
- 用户话术示例
- 回复模板中的文字

**术语对照**：
角色与身份→Role & Identity | 核心目标→Core Goals | 语言策略→Language Policy
关键→CRITICAL | 强制要求→MANDATORY | 严格→STRICT | 必须→MUST | 不得→DO NOT

**关键要求**：
1. 直接输出翻译后的完整内容
2. 不要添加任何解释、说明或注释
3. 不要用代码块包裹结果
4. 保持原文件的确切格式和结构
5. 如果原文只有一行，输出也只有一行'

translate_with_anthropic() {
    local CONTENT="$1"
    local REQUEST_JSON RESPONSE TRANSLATED_CONTENT

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

    RESPONSE=$(curl -s --max-time 300 "${API_BASE_URL}/v1/messages" \
        -H "Content-Type: application/json" \
        -H "x-api-key: $API_KEY" \
        -H "anthropic-version: 2023-06-01" \
        -d "$REQUEST_JSON")

    if echo "$RESPONSE" | jq -e '.error' > /dev/null 2>&1; then
        echo "   ❌ API 错误: $(echo "$RESPONSE" | jq -r '.error.message')" >&2
        return 1
    fi

    TRANSLATED_CONTENT=$(echo "$RESPONSE" | jq -r '.content[0].text' 2>&1)

    if [ $? -ne 0 ] || [ -z "$TRANSLATED_CONTENT" ] || [ "$TRANSLATED_CONTENT" = "null" ]; then
        echo "   ❌ 翻译失败：未返回内容" >&2
        echo "   📋 原始响应（前 500 字符）:" >&2
        echo "$RESPONSE" | head -c 500 >&2
        echo "" >&2
        return 1
    fi

    echo "$TRANSLATED_CONTENT"
}

translate_with_openrouter() {
    local CONTENT="$1"
    local TRANSLATE_SCRIPT="$SCRIPT_DIR/openrouter-translate.mjs"
    local TRANSLATED_CONTENT

    if [ ! -f "$TRANSLATE_SCRIPT" ]; then
        echo "   ❌ 缺少翻译脚本: $TRANSLATE_SCRIPT" >&2
        return 1
    fi

    if ! command -v node >/dev/null 2>&1; then
        echo "   ❌ 未安装 Node.js，无法使用 OpenRouter SDK" >&2
        return 1
    fi

    TRANSLATED_CONTENT=$(TRANSLATION_SYSTEM_PROMPT="$TRANSLATION_SYSTEM_PROMPT" \
        MODEL="$MODEL" \
        MAX_TOKENS="$MAX_TOKENS" \
        OPENROUTER_API_KEY="$OPENROUTER_API_KEY" \
        OPENROUTER_BASE_URL="$OPENROUTER_BASE_URL" \
        node "$TRANSLATE_SCRIPT" <<< "$CONTENT")

    if [ $? -ne 0 ] || [ -z "$TRANSLATED_CONTENT" ]; then
        echo "   ❌ OpenRouter 翻译失败" >&2
        return 1
    fi

    echo "$TRANSLATED_CONTENT"
}

# 翻译单个文件的函数
translate_file() {
    local INPUT_FILE="$1"
    local OUTPUT_FILE="${INPUT_FILE%.md}.en.md"

    echo "   翻译: $INPUT_FILE → $OUTPUT_FILE"

    # 读取文件内容
    if [ ! -f "$INPUT_FILE" ]; then
        echo "   ❌ 文件不存在: $INPUT_FILE"
        return 1
    fi

    CONTENT=$(cat "$INPUT_FILE")

    # 🆕 智能检测：跳过不需要翻译的文件
    # 检测条件：
    # 1. 仅包含占位符（如 {user_query}）
    # 2. 文件极短（≤3行且≤100字符）
    # 3. 纯英文固定字符串（如错误消息）
    LINE_COUNT=$(echo "$CONTENT" | wc -l | tr -d ' ')
    CHAR_COUNT=$(echo "$CONTENT" | wc -c | tr -d ' ')

    # 移除首尾空白后的内容
    TRIMMED_CONTENT=$(echo "$CONTENT" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

    # 检测是否为简单占位符（如 {user_query}, {draft_message}）
    if [[ "$TRIMMED_CONTENT" =~ ^\{[a-z_]+\}$ ]]; then
        echo "   ⏭️  跳过（占位符文件）: $INPUT_FILE"
        echo "$CONTENT" > "$OUTPUT_FILE"
        return 0
    fi

    # 检测是否为极短文件且不含中文
    if [ "$LINE_COUNT" -le 3 ] && [ "$CHAR_COUNT" -le 100 ]; then
        # 使用 perl 检测是否包含非 ASCII 字符（包括中文）- 跨平台兼容
        if ! perl -ne 'exit 1 if /[^\x00-\x7F]/' <<< "$CONTENT" 2>/dev/null; then
            : # 包含非 ASCII 字符，继续翻译
        else
            echo "   ⏭️  跳过（短英文文件）: $INPUT_FILE"
            echo "$CONTENT" > "$OUTPUT_FILE"
            return 0
        fi
    fi

    case "$TRANSLATION_PROVIDER" in
        openrouter)
            if ! TRANSLATED_CONTENT=$(translate_with_openrouter "$CONTENT"); then
                echo "   ❌ 翻译失败: $INPUT_FILE"
                return 1
            fi
            ;;
        *)
            if ! TRANSLATED_CONTENT=$(translate_with_anthropic "$CONTENT"); then
                echo "   ❌ 翻译失败: $INPUT_FILE"
                return 1
            fi
            ;;
    esac

    if [ -z "$TRANSLATED_CONTENT" ]; then
        echo "   ❌ 翻译失败：未返回内容"
        return 1
    fi

    # 写入输出文件
    echo "$TRANSLATED_CONTENT" > "$OUTPUT_FILE"

    echo "   ✅ 完成: $OUTPUT_FILE"
    return 0
}

# 主逻辑
if [ $# -eq 0 ]; then
    echo "用法: $0 <文件1> [文件2] [文件3] ..."
    echo "示例: $0 production-agent/system-prompt.md"
    exit 1
fi

SUCCESS_COUNT=0
FAIL_COUNT=0

for file in "$@"; do
    if translate_file "$file"; then
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
