#!/bin/bash

# 调试版本的翻译脚本 - 显示完整的 API 响应

set -e

CONFIG_FILE="$(dirname "$0")/translation-config.env"

if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    echo "❌ 配置文件不存在: $CONFIG_FILE"
    exit 1
fi

API_BASE_URL="${ANTHROPIC_BASE_URL:-https://api.anthropic.com}"
API_KEY="${ANTHROPIC_AUTH_TOKEN:-$ANTHROPIC_API_KEY}"
MODEL="${MODEL:-claude-sonnet-4-5-20250929}"

# 简单的测试请求
echo "🔍 测试 API 连接..."
echo "📍 端点: ${API_BASE_URL}/v1/messages"
echo "🔑 API Key: ${API_KEY:0:20}..."
echo "🤖 模型: $MODEL"
echo ""

REQUEST_JSON=$(jq -n \
    --arg model "$MODEL" \
    '{
        model: $model,
        max_tokens: 100,
        messages: [
            {
                role: "user",
                content: "测试连接，请简单回复 OK"
            }
        ]
    }')

echo "📤 发送请求..."
echo "$REQUEST_JSON" | jq '.'
echo ""

RESPONSE=$(curl -v "${API_BASE_URL}/v1/messages" \
    -H "Content-Type: application/json" \
    -H "x-api-key: $API_KEY" \
    -H "anthropic-version: 2023-06-01" \
    -d "$REQUEST_JSON" 2>&1)

echo ""
echo "📥 完整响应:"
echo "$RESPONSE"
echo ""

# 尝试提取 JSON 部分
JSON_PART=$(echo "$RESPONSE" | grep -o '{.*}' | tail -1)
if [ -n "$JSON_PART" ]; then
    echo "🔍 JSON 部分:"
    echo "$JSON_PART" | jq '.' 2>&1 || echo "$JSON_PART"
fi
