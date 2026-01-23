#!/bin/bash
# 快速查看测试用例脚本

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 显示所有测试场景
show_all_scenarios() {
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}AI 客服系统测试场景总览${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo ""

    for file in *.json; do
        if [ "$file" != "index.json" ]; then
            scenario=$(cat "$file" | grep -o '"scenario": "[^"]*"' | cut -d'"' -f4)
            count=$(cat "$file" | grep -o '"id": "TC[0-9]*"' | wc -l | xargs)
            echo -e "${YELLOW}▶ $file${NC}"
            echo -e "  场景: $scenario"
            echo -e "  用例数: $count"
            echo ""
        fi
    done
}

# 查看特定测试用例
show_test_case() {
    case_id=$1
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}查找测试用例: $case_id${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo ""

    # 从 index.json 查找文件
    file=$(cat index.json | grep "\"$case_id\"" | cut -d'"' -f4)

    if [ -z "$file" ]; then
        echo -e "${RED}错误: 找不到测试用例 $case_id${NC}"
        exit 1
    fi

    echo -e "${YELLOW}文件: $file${NC}"
    echo ""

    # 提取并显示测试用例
    cat "$file" | jq ".cases[] | select(.id == \"$case_id\")"
}

# 显示关键测试用例
show_critical_cases() {
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${RED}关键测试用例 (Critical)${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo ""

    critical_cases=$(cat index.json | jq -r '.critical_cases[]')

    for case_id in $critical_cases; do
        file=$(cat index.json | jq -r ".case_index.\"$case_id\"")
        name=$(cat "$file" | jq -r ".cases[] | select(.id == \"$case_id\") | .name")
        echo -e "${RED}⚠ $case_id${NC} - $name ($file)"
    done
}

# 按意图分类显示
show_by_intent() {
    intent=$1
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}意图: $intent${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo ""

    cases=$(cat index.json | jq -r ".by_intent.\"$intent\"[]" 2>/dev/null)

    if [ -z "$cases" ]; then
        echo -e "${RED}错误: 找不到意图 $intent${NC}"
        echo ""
        echo "可用意图:"
        cat index.json | jq -r '.by_intent | keys[]'
        exit 1
    fi

    for case_id in $cases; do
        file=$(cat index.json | jq -r ".case_index.\"$case_id\"")
        name=$(cat "$file" | jq -r ".cases[] | select(.id == \"$case_id\") | .name")
        echo "• $case_id - $name"
    done
}

# 显示端到端场景
show_scenarios() {
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}端到端测试场景${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo ""

    cat index.json | jq -r '.scenarios | to_entries[] | "\(.key):\n  \(.value | join(", "))\n"'
}

# 帮助信息
show_help() {
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}测试用例快速查看工具${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo ""
    echo "用法:"
    echo "  ./quick-view.sh [选项]"
    echo ""
    echo "选项:"
    echo "  -a, --all              显示所有测试场景"
    echo "  -c, --case <ID>        查看特定测试用例 (例: TC017)"
    echo "  -k, --critical         显示所有关键测试用例"
    echo "  -i, --intent <intent>  按意图查看用例"
    echo "  -s, --scenarios        显示端到端场景"
    echo "  -h, --help             显示帮助信息"
    echo ""
    echo "示例:"
    echo "  ./quick-view.sh -a                    # 显示所有场景"
    echo "  ./quick-view.sh -c TC017              # 查看 TC017"
    echo "  ./quick-view.sh -k                    # 显示关键用例"
    echo "  ./quick-view.sh -i query_product_data # 查看产品查询用例"
    echo ""
}

# 主函数
main() {
    cd "$(dirname "$0")"

    case "$1" in
        -a|--all)
            show_all_scenarios
            ;;
        -c|--case)
            if [ -z "$2" ]; then
                echo -e "${RED}错误: 请提供测试用例 ID${NC}"
                exit 1
            fi
            show_test_case "$2"
            ;;
        -k|--critical)
            show_critical_cases
            ;;
        -i|--intent)
            if [ -z "$2" ]; then
                echo -e "${RED}错误: 请提供意图名称${NC}"
                exit 1
            fi
            show_by_intent "$2"
            ;;
        -s|--scenarios)
            show_scenarios
            ;;
        -h|--help|*)
            show_help
            ;;
    esac
}

main "$@"
