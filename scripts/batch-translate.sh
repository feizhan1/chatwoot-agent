#!/bin/bash

# 批量翻译所有提示词文件（中文 → 英文）

set -e

echo "🌐 批量翻译所有提示词文件"
echo "================================================"
echo ""

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# 查找所有中文提示词文件
PROMPT_FILES=$(find "$PROJECT_ROOT" -type f \( -name "system-prompt.md" -o -name "user-prompt.md" \) ! -name "*.en.md" | sort)

if [ -z "$PROMPT_FILES" ]; then
    echo "❌ 未找到任何提示词文件"
    exit 1
fi

FILE_COUNT=$(echo "$PROMPT_FILES" | wc -l | tr -d ' ')
echo "📝 找到 $FILE_COUNT 个文件需要翻译:"
echo "$PROMPT_FILES" | sed 's/^/   - /' | sed "s|$PROJECT_ROOT/||g"
echo ""

# 支持 --yes 参数跳过确认
if [ "$1" != "--yes" ] && [ "$1" != "-y" ]; then
    read -p "确认开始批量翻译？(y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ 已取消"
        exit 0
    fi
fi

echo ""
echo "🚀 开始翻译..."
echo ""

# 逐个翻译
SUCCESS_COUNT=0
FAIL_COUNT=0
SKIP_COUNT=0

for file in $PROMPT_FILES; do
    REL_PATH=$(echo "$file" | sed "s|$PROJECT_ROOT/||")
    EN_FILE="${file%.md}.en.md"

    # 检查英文版本是否已存在且较新
    if [ -f "$EN_FILE" ] && [ "$EN_FILE" -nt "$file" ]; then
        echo "⏭️  跳过（已是最新）: $REL_PATH"
        ((SKIP_COUNT++))
        continue
    fi

    echo "📄 翻译: $REL_PATH"

    if bash "$SCRIPT_DIR/translate-prompt.sh" "$file"; then
        ((SUCCESS_COUNT++))
    else
        ((FAIL_COUNT++))
        echo "   ❌ 失败"
    fi

    echo ""
done

echo "================================================"
echo "📊 翻译完成统计:"
echo "   ✅ 成功: $SUCCESS_COUNT 个"
echo "   ❌ 失败: $FAIL_COUNT 个"
echo "   ⏭️  跳过: $SKIP_COUNT 个"
echo ""

if [ $FAIL_COUNT -gt 0 ]; then
    echo "⚠️  部分文件翻译失败，请检查日志"
    exit 1
fi

echo "🎉 批量翻译完成！"
