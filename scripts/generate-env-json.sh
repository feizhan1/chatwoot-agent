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
    local prompt_type="$2"  # "user-prompt" / "system-prompt" / "struct-output"

    local en_file="${agent_dir}${prompt_type}.en.md"
    local zh_file="${agent_dir}${prompt_type}.md"

    if [ -s "$en_file" ]; then
        cat "$en_file"
    elif [ -f "$zh_file" ]; then
        cat "$zh_file"
    elif [ -f "$en_file" ]; then
        # 英文文件存在但为空且无中文回退时，保留其原样内容
        cat "$en_file"
    else
        echo ""
    fi
}

# ============================================
# 函数：读取中文prompt文件内容
# ============================================
read_prompt_file_zh() {
    local agent_dir="$1"
    local prompt_type="$2"  # "user-prompt" / "system-prompt" / "struct-output"

    local zh_file="${agent_dir}${prompt_type}.md"

    if [ -f "$zh_file" ]; then
        cat "$zh_file"
    else
        echo ""
    fi
}

# ============================================
# 函数：构建英文prompt部分（包含tools和sop_dict）
# ============================================
build_prompt_section_en() {
    local prompt_json="{}"

    # 遍历所有agent目录
    for agent_dir in */; do
        # 跳过scripts和.git等非agent目录
        [[ "$agent_dir" =~ ^(scripts|\.git|node_modules)/ ]] && continue

        # 检查是否包含prompt文件（至少有一个.md或.en.md文件）
        if [ ! -f "${agent_dir}user-prompt.md" ] && [ ! -f "${agent_dir}user-prompt.en.md" ] && \
           [ ! -f "${agent_dir}system-prompt.md" ] && [ ! -f "${agent_dir}system-prompt.en.md" ] && \
           [ ! -f "${agent_dir}struct-output.md" ] && [ ! -f "${agent_dir}struct-output.en.md" ]; then
            continue
        fi

        local agent_name="${agent_dir%/}"

        echo "   读取 $agent_name (EN)..." >&2

        # 读取英文版本
        local user_prompt_en=$(read_prompt_file_en "$agent_dir" "user-prompt")
        local system_prompt_en=$(read_prompt_file_en "$agent_dir" "system-prompt")
        local struct_output_en=$(read_prompt_file_en "$agent_dir" "struct-output")

        # 构建基础 agent 对象
        local agent_obj
        agent_obj=$(jq -n \
            --arg up "$user_prompt_en" \
            --arg sp "$system_prompt_en" \
            '{"user-prompt": $up, "system-prompt": $sp}')

        if [ -n "$struct_output_en" ]; then
            agent_obj=$(echo "$agent_obj" | jq \
                --arg so "$struct_output_en" \
                '. + {"struct-output": $so}')
        fi

        # 读取该agent的tools（如果有）
        if [ -d "${agent_dir}tools" ]; then
            local agent_tools_json="{}"
            for tool_file in "${agent_dir}tools/"*.md; do
                [ ! -f "$tool_file" ] && continue

                local tool_name=$(basename "$tool_file" .md)
                [[ "$tool_name" == *.en ]] && continue

                local en_file="${agent_dir}tools/${tool_name}.en.md"
                local zh_file="${agent_dir}tools/${tool_name}.md"
                local content=""

                if [ -f "$en_file" ]; then
                    content=$(cat "$en_file")
                elif [ -f "$zh_file" ]; then
                    content=$(cat "$zh_file")
                else
                    continue
                fi

                agent_tools_json=$(echo "$agent_tools_json" | jq \
                    --arg name "$tool_name" \
                    --arg content "$content" \
                    '. + {($name): $content}')
            done

            if [ "$agent_tools_json" != "{}" ]; then
                agent_obj=$(echo "$agent_obj" | jq \
                    --argjson tools "$agent_tools_json" \
                    '. + {tools: $tools}')
            fi
        fi

        # 读取该agent的sop_dict（英文优先，回退中文）
        local sop_dict_content=""
        if [ -f "${agent_dir}sop_dict.en.json" ]; then
            sop_dict_content=$(cat "${agent_dir}sop_dict.en.json")
        elif [ -f "${agent_dir}sop_dict.json" ]; then
            sop_dict_content=$(cat "${agent_dir}sop_dict.json")
        fi

        if [ -n "$sop_dict_content" ]; then
            agent_obj=$(echo "$agent_obj" | jq \
                --argjson sop_dict "$sop_dict_content" \
                '. + {sop_dict: $sop_dict}')
        fi

        prompt_json=$(echo "$prompt_json" | jq \
            --arg name "$agent_name" \
            --argjson obj "$agent_obj" \
            '. + {($name): $obj}')
    done

    echo "$prompt_json"
}

# ============================================
# 函数：构建中文prompt部分（包含tools和sop_dict）
# ============================================
build_prompt_section_zh() {
    local prompt_json="{}"

    # 遍历所有agent目录
    for agent_dir in */; do
        # 跳过scripts和.git等非agent目录
        [[ "$agent_dir" =~ ^(scripts|\.git|node_modules)/ ]] && continue

        # 检查是否包含prompt文件（至少有一个.md或.en.md文件）
        if [ ! -f "${agent_dir}user-prompt.md" ] && [ ! -f "${agent_dir}user-prompt.en.md" ] && \
           [ ! -f "${agent_dir}system-prompt.md" ] && [ ! -f "${agent_dir}system-prompt.en.md" ] && \
           [ ! -f "${agent_dir}struct-output.md" ] && [ ! -f "${agent_dir}struct-output.en.md" ]; then
            continue
        fi

        local agent_name="${agent_dir%/}"

        echo "   读取 $agent_name (ZH)..." >&2

        # 读取中文版本
        local user_prompt_zh=$(read_prompt_file_zh "$agent_dir" "user-prompt")
        local system_prompt_zh=$(read_prompt_file_zh "$agent_dir" "system-prompt")
        local struct_output_zh=$(read_prompt_file_zh "$agent_dir" "struct-output")

        # 构建基础 agent 对象
        local agent_obj
        agent_obj=$(jq -n \
            --arg up "$user_prompt_zh" \
            --arg sp "$system_prompt_zh" \
            '{"user-prompt": $up, "system-prompt": $sp}')

        if [ -n "$struct_output_zh" ]; then
            agent_obj=$(echo "$agent_obj" | jq \
                --arg so "$struct_output_zh" \
                '. + {"struct-output": $so}')
        fi

        # 读取该agent的tools（如果有）
        if [ -d "${agent_dir}tools" ]; then
            local agent_tools_json="{}"
            for tool_file in "${agent_dir}tools/"*.md; do
                [ ! -f "$tool_file" ] && continue

                local tool_name=$(basename "$tool_file" .md)
                [[ "$tool_name" == *.en ]] && continue

                local zh_file="${agent_dir}tools/${tool_name}.md"
                [ ! -f "$zh_file" ] && continue

                local content=$(cat "$zh_file")

                agent_tools_json=$(echo "$agent_tools_json" | jq \
                    --arg name "$tool_name" \
                    --arg content "$content" \
                    '. + {($name): $content}')
            done

            if [ "$agent_tools_json" != "{}" ]; then
                agent_obj=$(echo "$agent_obj" | jq \
                    --argjson tools "$agent_tools_json" \
                    '. + {tools: $tools}')
            fi
        fi

        # 读取该agent的中文sop_dict
        if [ -f "${agent_dir}sop_dict.json" ]; then
            local sop_dict_content
            sop_dict_content=$(cat "${agent_dir}sop_dict.json")
            agent_obj=$(echo "$agent_obj" | jq \
                --argjson sop_dict "$sop_dict_content" \
                '. + {sop_dict: $sop_dict}')
        fi

        prompt_json=$(echo "$prompt_json" | jq \
            --arg name "$agent_name" \
            --argjson obj "$agent_obj" \
            '. + {($name): $obj}')
    done

    echo "$prompt_json"
}

# ============================================
# 主函数
# ============================================
main() {
    echo "📝 更新 env.json 中的 prompt 字段..."

    # 检查jq可用性
    if ! command -v jq &> /dev/null; then
        echo "❌ 错误: jq 未安装，请运行: brew install jq" >&2
        exit 1
    fi

    # 1. 读取现有的 env.json（如果存在）
    if [ -f "env.json" ]; then
        echo "   读取现有的 env.json..."
        existing_json=$(cat env.json)
    else
        echo "   env.json 不存在，将创建新文件..."
        # 初始化基础结构
        existing_json='{}'

        # 如果 stage.env 和 production.env 存在，解析它们
        if [ -f "stage.env" ]; then
            echo "   解析 stage.env..."
            stage_json=$(parse_env_to_json "stage.env")
            existing_json=$(echo "$existing_json" | jq --argjson stage "$stage_json" '. + {stage: $stage}')
        fi

        if [ -f "production.env" ]; then
            echo "   解析 production.env..."
            production_json=$(parse_env_to_json "production.env")
            existing_json=$(echo "$existing_json" | jq --argjson production "$production_json" '. + {production: $production}')
        fi
    fi

    # 2. 构建英文prompt部分（包含struct-output、tools）
    echo "   读取所有agent的英文prompt/struct-output和tools..."
    prompt_json=$(build_prompt_section_en)

    # 3. 构建中文prompt部分（包含struct-output、tools）
    echo "   读取所有agent的中文prompt/struct-output和tools..."
    zh_prompt_json=$(build_prompt_section_zh)

    # 4. 只更新 prompt 和 zh_prompt 字段，保留其他所有字段
    echo "   更新 prompt 和 zh_prompt 字段..."
    final_json=$(echo "$existing_json" | jq \
        --argjson prompt "$prompt_json" \
        --argjson zh_prompt "$zh_prompt_json" \
        '. + {prompt: $prompt, zh_prompt: $zh_prompt}')

    # 5. 写入文件（原子操作）
    echo "   写入 env.json..."
    echo "$final_json" | jq '.' > env.json.tmp
    mv env.json.tmp env.json

    echo "✅ env.json 已更新（仅更新 prompt 和 zh_prompt 字段）"
}

# 执行主函数
main
