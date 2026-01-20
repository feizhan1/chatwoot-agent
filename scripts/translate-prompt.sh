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

# 检查 API Key
if [ -z "$ANTHROPIC_API_KEY" ]; then
    echo "❌ 错误: ANTHROPIC_API_KEY 未设置"
    echo "💡 请在 $CONFIG_FILE 中设置您的 API Key"
    exit 1
fi

# 翻译系统提示词（翻译指令）
TRANSLATION_SYSTEM_PROMPT='你是一个专业的AI提示词翻译专家。你的任务是将中文提示词翻译为英文，同时严格遵守以下规则：

**必须保持不变的内容**：
1. XML 标签名称（如 `<session_metadata>`, `<user_query>` 等）
2. 模板变量语法（如 `{{ $(...) }}` ）
3. 字段名/键名（如 `Login Status`, `Channel`, `iso_code` 等）
4. 意图枚举值（如 `query_product_data`, `handoff` 等）
5. URL 链接
6. 专有名词（如 `TVCMALL`, `TVC Assistant`, `MOQ`, `SKU` 等）
7. Markdown 格式标记（`#`, `**`, `-`, `>`, 缩进等）
8. 代码块标记和换行符（`\n\n`）

**需要翻译的内容**：
1. 自然语言描述和说明
2. 章节标题（如 "角色与身份" → "Role & Identity"）
3. 用户话术示例（如 "请问您的订单号是多少？" → "Could you please share your order number?"）
4. 固定回复模板的文字内容

**术语对照**：
- 角色与身份 → Role & Identity
- 核心目标 → Core Goals
- 上下文优先级与逻辑 → Context Priority & Logic
- 工具失败处理 → Tool Failure Handling
- 语言策略 → Language Policy
- 输出模板 → Output Templates
- 场景处理规则 → Scenario Handling Rules
- 语气与约束 → Tone & Constraints
- 关键 → CRITICAL
- 强制要求 → MANDATORY
- 严格 → STRICT
- 必须 → MUST
- 不得 → DO NOT
- 绝不 → NEVER

**输出要求**：
1. 保持原有文件的完整结构和格式
2. 确保 Markdown 渲染效果一致
3. 保持专业的 AI 提示词工程术语
4. 直接输出翻译后的完整文件内容，不要添加任何说明或注释'

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
        --arg system "$TRANSLATION_SYSTEM_PROMPT" \
        --arg content "$CONTENT" \
        '{
            model: "claude-sonnet-4-5-20250929",
            max_tokens: 8000,
            system: $system,
            messages: [
                {
                    role: "user",
                    content: ("请将以下中文提示词翻译为英文：\n\n" + $content)
                }
            ]
        }')

    # 调用 Claude API
    RESPONSE=$(curl -s https://api.anthropic.com/v1/messages \
        -H "Content-Type: application/json" \
        -H "x-api-key: $ANTHROPIC_API_KEY" \
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
