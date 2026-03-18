#!/bin/bash

# 测试翻译系统是否正常工作

set -e

echo "🧪 翻译系统测试"
echo "================================================"
echo ""

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(git rev-parse --show-toplevel)"

# 测试 1: 检查脚本文件
echo "📝 测试 1: 检查脚本文件..."
REQUIRED_FILES=(
    "$SCRIPT_DIR/setup-translation.sh"
    "$SCRIPT_DIR/install-hooks.sh"
    "$SCRIPT_DIR/translate-prompt.sh"
    "$SCRIPT_DIR/batch-translate.sh"
    "$SCRIPT_DIR/translation-config.env.example"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "   ✅ $file"
    else
        echo "   ❌ 缺少: $file"
        exit 1
    fi
done

# 测试 2: 检查执行权限
echo ""
echo "🔐 测试 2: 检查执行权限..."
EXEC_FILES=(
    "$SCRIPT_DIR/setup-translation.sh"
    "$SCRIPT_DIR/install-hooks.sh"
    "$SCRIPT_DIR/translate-prompt.sh"
    "$SCRIPT_DIR/batch-translate.sh"
)

for file in "${EXEC_FILES[@]}"; do
    if [ -x "$file" ]; then
        echo "   ✅ $(basename "$file")"
    else
        echo "   ❌ 无执行权限: $(basename "$file")"
        exit 1
    fi
done

# 测试 3: 检查 Git Hook
echo ""
echo "🪝 测试 3: 检查 Git Hook..."
HOOKS_PATH="$(git config --get core.hooksPath || true)"

if [ -z "$HOOKS_PATH" ]; then
    HOOK_FILE="$(git rev-parse --git-dir)/hooks/pre-commit"
else
    case "$HOOKS_PATH" in
        /*)
            HOOK_FILE="$HOOKS_PATH/pre-commit"
            ;;
        *)
            HOOK_FILE="$PROJECT_ROOT/$HOOKS_PATH/pre-commit"
            ;;
    esac
fi

if [ -f "$HOOK_FILE" ]; then
    echo "   ✅ Pre-commit hook 已安装: $HOOK_FILE"
    if [ -x "$HOOK_FILE" ]; then
        echo "   ✅ Hook 具有执行权限"
    else
        echo "   ❌ Hook 缺少执行权限"
        exit 1
    fi
else
    echo "   ❌ Pre-commit hook 未安装"
    echo "   💡 请先运行: ./scripts/install-hooks.sh"
    exit 1
fi

# 测试 4: 检查配置文件
echo ""
echo "⚙️  测试 4: 检查配置..."
CONFIG_FILE="$SCRIPT_DIR/translation-config.env"

if [ -f "$CONFIG_FILE" ]; then
    echo "   ✅ 配置文件存在"

    # 检查 API Key
    if grep -q "your_api_key_here" "$CONFIG_FILE"; then
        echo "   ⚠️  API Key 未配置（请运行 ./scripts/setup-translation.sh）"
    else
        echo "   ✅ API Key 已配置"
    fi
else
    echo "   ⚠️  配置文件不存在（请运行 ./scripts/setup-translation.sh）"
fi

# 测试 5: 检查 .gitignore
echo ""
echo "🙈 测试 5: 检查 .gitignore..."
GITIGNORE_FILE="$(git rev-parse --show-toplevel)/.gitignore"

if [ -f "$GITIGNORE_FILE" ]; then
    echo "   ✅ .gitignore 存在"

    if grep -q "translation-config.env" "$GITIGNORE_FILE"; then
        echo "   ✅ 配置文件已加入 .gitignore"
    else
        echo "   ⚠️  建议将 translation-config.env 加入 .gitignore"
    fi
else
    echo "   ⚠️  .gitignore 不存在"
fi

echo ""
echo "================================================"
echo "✅ 所有测试通过！"
echo ""
echo "📖 下一步："
if [ ! -f "$CONFIG_FILE" ]; then
    echo "   1. 运行: ./scripts/setup-translation.sh"
    echo "   2. 修改任意提示词文件"
    echo "   3. 运行: git add . && git commit -m \"测试自动翻译\""
else
    if grep -q "your_api_key_here" "$CONFIG_FILE"; then
        echo "   1. 运行: ./scripts/setup-translation.sh 配置 API Key"
        echo "   2. 修改任意提示词文件"
        echo "   3. 运行: git add . && git commit -m \"测试自动翻译\""
    else
        echo "   ✅ 系统已就绪！"
        echo "   - 修改任意提示词文件"
        echo "   - 运行: git add . && git commit -m \"更新提示词\""
        echo "   - 系统会自动翻译并生成 .en.md 文件"
    fi
fi
echo ""
