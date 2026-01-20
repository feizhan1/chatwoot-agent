#!/bin/bash

# 自动翻译提示词脚本（中文 → 英文）
# 使用 Claude API 进行翻译，保持技术结构和格式不变

set -e

# 配置文件路径
CONFIG_FILE="$(dirname "$0")/translation-config.env"

# 加载配置
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    echo "⚠️  配置文件不存在: $CONFIG_FILE"
    echo "💡 请先运行: ./scripts/setup-translation.sh"
    exit 1
fi

# 检查 API 配置
if [ -z "$ANTHROPIC_AUTH_TOKEN" ] && [ -z "$ANTHROPIC_API_KEY" ]; then
    echo "❌ 错误: ANTHROPIC_AUTH_TOKEN 或 ANTHROPIC_API_KEY 未设置"
    echo "💡 请在 $CONFIG_FILE 中设置您的认证信息"
    exit 1
fi

# 设置默认值
API_BASE_URL="${ANTHROPIC_BASE_URL:-https://api.anthropic.com}"
API_KEY="${ANTHROPIC_AUTH_TOKEN:-$ANTHROPIC_API_KEY}"
MODEL="${MODEL:-claude-sonnet-4-5-20250929}"
MAX_TOKENS="${MAX_TOKENS:-8000}"

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

    # 调用 Claude API
    RESPONSE=$(curl -s "${API_BASE_URL}/v1/messages" \
        -H "Content-Type: application/json" \
        -H "x-api-key: $API_KEY" \
        -H "anthropic-version: 2023-06-01" \
        -d "$REQUEST_JSON")

    # 检查是否成功
    if echo "$RESPONSE" | jq -e '.error' > /dev/null 2>&1; then
        ERROR_MSG=$(echo "$RESPONSE" | jq -r '.error.message')
        echo "   ❌ API 错误: $ERROR_MSG"
        return 1
    fi

    # 提取翻译内容
    TRANSLATED_CONTENT=$(echo "$RESPONSE" | jq -r '.content[0].text')

    if [ -z "$TRANSLATED_CONTENT" ] || [ "$TRANSLATED_CONTENT" = "null" ]; then
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
