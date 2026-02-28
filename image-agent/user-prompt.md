请使用以下上下文信息分析图片内容并识别用户意图。

<session_metadata>
    Channel: {channel}
    Login Status: {login_status}
    Target Language: {target_language}
    Language Code: {language_code}
</session_metadata>

<memory_bank>
    ### User Long-term Profile (Historical Data)
    {user_profile}

    ### Active Context (Current Session Summary)
    {active_context}
</memory_bank>

<recent_dialogue>
    {recent_dialogue}
</recent_dialogue>

<instructions>
    1. 结合 <recent_dialogue> 近期对话和图片内容判断用户要执行的业务动作
    2. 严格按系统提示词中的优先级和单一决策流程路由
    3. 仅当“可能是业务相关，但无法确定具体动作”时，才归类为 confirm_again_agent
</instructions>
