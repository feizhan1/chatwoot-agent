#!/bin/bash

# 安装仓库内版本化 Git hooks（推荐在 clone 后执行一次）

set -e

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || true)"

if [ -z "$PROJECT_ROOT" ]; then
    echo "❌ 当前目录不在 Git 仓库内"
    exit 1
fi

HOOKS_DIR="$PROJECT_ROOT/.githooks"
PRE_COMMIT_HOOK="$HOOKS_DIR/pre-commit"

if [ ! -f "$PRE_COMMIT_HOOK" ]; then
    echo "❌ 未找到 hook 文件: $PRE_COMMIT_HOOK"
    exit 1
fi

chmod +x "$PRE_COMMIT_HOOK"
git -C "$PROJECT_ROOT" config core.hooksPath .githooks

echo "✅ 已启用仓库内 hooks"
echo "   core.hooksPath=$(git -C "$PROJECT_ROOT" config --get core.hooksPath)"
echo "   hook 文件: .githooks/pre-commit"
