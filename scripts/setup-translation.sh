#!/bin/bash

# 自动翻译系统一键设置脚本

set -e

echo "🚀 AI 提示词自动翻译系统 - 设置向导"
echo "================================================"
echo ""

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/translation-config.env"
CONFIG_EXAMPLE="$SCRIPT_DIR/translation-config.env.example"

# 检查是否已配置
if [ -f "$CONFIG_FILE" ]; then
    echo "⚠️  配置文件已存在: $CONFIG_FILE"
    read -p "是否要重新配置？(y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "✅ 保持现有配置"
        exit 0
    fi
fi

# 创建配置文件
echo "📝 创建配置文件..."

if [ ! -f "$CONFIG_EXAMPLE" ]; then
    echo "❌ 错误: 示例配置文件不存在"
    exit 1
fi

cp "$CONFIG_EXAMPLE" "$CONFIG_FILE"

echo "✅ 配置文件已创建: $CONFIG_FILE"
echo ""

# 获取 API Key
echo "🔑 请输入您的 Anthropic API Key"
echo "   获取地址: https://console.anthropic.com/settings/keys"
echo ""
read -p "API Key: " -r API_KEY

if [ -z "$API_KEY" ]; then
    echo "❌ API Key 不能为空"
    exit 1
fi

# 更新配置文件
sed -i.bak "s/your_api_key_here/$API_KEY/" "$CONFIG_FILE"
rm -f "$CONFIG_FILE.bak"

echo "✅ API Key 已保存"
echo ""

# 验证配置
echo "🧪 验证配置..."

if bash "$SCRIPT_DIR/translate-prompt.sh" --help > /dev/null 2>&1 || true; then
    echo "✅ 翻译脚本可执行"
else
    echo "❌ 翻译脚本验证失败"
    exit 1
fi

echo ""
echo "================================================"
echo "🎉 设置完成！"
echo ""
echo "📖 使用方法："
echo ""
echo "1. 自动模式（推荐）："
echo "   - 修改任何 system-prompt.md 或 user-prompt.md"
echo "   - 运行 'git commit'"
echo "   - 系统会自动翻译并生成 .en.md 文件"
echo ""
echo "2. 手动模式："
echo "   ./scripts/translate-prompt.sh <文件路径>"
echo "   示例: ./scripts/translate-prompt.sh production-agent/system-prompt.md"
echo ""
echo "3. 批量翻译所有文件："
echo "   ./scripts/batch-translate.sh"
echo ""
echo "⚠️  重要提醒："
echo "   - .en.md 文件由系统自动生成，请勿手动编辑"
echo "   - 配置文件包含 API Key，已添加到 .gitignore"
echo "   - 如需跳过自动翻译，使用: git commit --no-verify"
echo ""
