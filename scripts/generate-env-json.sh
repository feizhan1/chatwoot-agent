#!/bin/bash
set -e  # 任何错误立即退出

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

# ============================================
# 函数：解析.env文件为JSON
# ============================================
parse_env_to_json() {
    local env_file="$1"
    local json="{}"

    while IFS='=' read -r key value || [ -n "$key" ]; do
        # 跳过空行和注释
        [[ -z "$key" || "$key" =~ ^[[:space:]]*# ]] && continue

        # 移除前后空格
        key=$(echo "$key" | xargs)
        value=$(echo "$value" | xargs)

        # 移除值中的引号（如果有）
        value=$(echo "$value" | sed 's/^["'"'"']//;s/["'"'"']$//')

        # 使用jq构建JSON
        json=$(echo "$json" | jq --arg k "$key" --arg v "$value" '. + {($k): $v}')
    done < "$env_file"

    echo "$json"
}

# ============================================
# 函数：读取英文prompt文件内容
# ============================================
read_prompt_file_en() {
    local agent_dir="$1"
    local prompt_type="$2"  # "user-prompt" or "system-prompt"

    local en_file="${agent_dir}${prompt_type}.en.md"
    local zh_file="${agent_dir}${prompt_type}.md"

    if [ -f "$en_file" ]; then
        cat "$en_file"
    elif [ -f "$zh_file" ]; then
        cat "$zh_file"
    else
        echo ""
    fi
}

# ============================================
# 函数：读取中文prompt文件内容
# ============================================
read_prompt_file_zh() {
    local agent_dir="$1"
    local prompt_type="$2"  # "user-prompt" or "system-prompt"

    local zh_file="${agent_dir}${prompt_type}.md"

    if [ -f "$zh_file" ]; then
        cat "$zh_file"
    else
        echo ""
    fi
}

# ============================================
# 函数：构建英文prompt部分
# ============================================
build_prompt_section_en() {
    local prompt_json="{}"

    # 遍历所有agent目录
    for agent_dir in */; do
        # 跳过scripts和.git等非agent目录
        [[ "$agent_dir" =~ ^(scripts|\.git|node_modules)/ ]] && continue

        # 检查是否包含prompt文件（至少有一个.md或.en.md文件）
        if [ ! -f "${agent_dir}user-prompt.md" ] && [ ! -f "${agent_dir}user-prompt.en.md" ] && \
           [ ! -f "${agent_dir}system-prompt.md" ] && [ ! -f "${agent_dir}system-prompt.en.md" ]; then
            continue
        fi

        local agent_name="${agent_dir%/}"

        echo "   读取 $agent_name (EN)..." >&2

        # 读取英文版本
        local user_prompt_en=$(read_prompt_file_en "$agent_dir" "user-prompt")
        local system_prompt_en=$(read_prompt_file_en "$agent_dir" "system-prompt")

        # 构建该agent的英文JSON
        prompt_json=$(echo "$prompt_json" | jq \
            --arg name "$agent_name" \
            --arg up "$user_prompt_en" \
            --arg sp "$system_prompt_en" \
            '. + {($name): {"user-prompt": $up, "system-prompt": $sp}}')
    done

    echo "$prompt_json"
}

# ============================================
# 函数：构建中文prompt部分
# ============================================
build_prompt_section_zh() {
    local prompt_json="{}"

    # 遍历所有agent目录
    for agent_dir in */; do
        # 跳过scripts和.git等非agent目录
        [[ "$agent_dir" =~ ^(scripts|\.git|node_modules)/ ]] && continue

        # 检查是否包含prompt文件（至少有一个.md或.en.md文件）
        if [ ! -f "${agent_dir}user-prompt.md" ] && [ ! -f "${agent_dir}user-prompt.en.md" ] && \
           [ ! -f "${agent_dir}system-prompt.md" ] && [ ! -f "${agent_dir}system-prompt.en.md" ]; then
            continue
        fi

        local agent_name="${agent_dir%/}"

        echo "   读取 $agent_name (ZH)..." >&2

        # 读取中文版本
        local user_prompt_zh=$(read_prompt_file_zh "$agent_dir" "user-prompt")
        local system_prompt_zh=$(read_prompt_file_zh "$agent_dir" "system-prompt")

        # 构建该agent的中文JSON
        prompt_json=$(echo "$prompt_json" | jq \
            --arg name "$agent_name" \
            --arg up "$user_prompt_zh" \
            --arg sp "$system_prompt_zh" \
            '. + {($name): {"user-prompt": $up, "system-prompt": $sp}}')
    done

    echo "$prompt_json"
}

# ============================================
# 主函数
# ============================================
main() {
    echo "📝 生成 env.json..."

    # 检查必要文件
    if [ ! -f "stage.env" ] || [ ! -f "production.env" ]; then
        echo "❌ 错误: stage.env 或 production.env 不存在" >&2
        exit 1
    fi

    # 检查jq可用性
    if ! command -v jq &> /dev/null; then
        echo "❌ 错误: jq 未安装，请运行: brew install jq" >&2
        exit 1
    fi

    # 1. 解析stage环境
    echo "   解析 stage.env..."
    stage_json=$(parse_env_to_json "stage.env")

    # 2. 解析production环境
    echo "   解析 production.env..."
    production_json=$(parse_env_to_json "production.env")

    # 3. 构建英文prompt部分
    echo "   读取所有agent的英文prompt..."
    prompt_json=$(build_prompt_section_en)

    # 4. 构建中文prompt部分
    echo "   读取所有agent的中文prompt..."
    zh_prompt_json=$(build_prompt_section_zh)

    # 5. 合并所有部分
    echo "   合并JSON..."
    final_json=$(jq -n \
        --argjson stage "$stage_json" \
        --argjson production "$production_json" \
        --argjson prompt "$prompt_json" \
        --argjson zh_prompt "$zh_prompt_json" \
        '{stage: $stage, production: $production, prompt: $prompt, zh_prompt: $zh_prompt}')

    # 6. 写入文件（原子操作）
    echo "   写入 env.json..."
    echo "$final_json" | jq '.' > env.json.tmp
    mv env.json.tmp env.json

    echo "✅ env.json 生成完成"
}

# 执行主函数
main
