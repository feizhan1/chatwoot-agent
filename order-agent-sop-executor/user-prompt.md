请使用以下分层信息来理解用户的请求。

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

<current_request>
    <user_query>
        {user_query}
    </user_query>
</current_request>

<current_system_time>{{ $now.format('yyyy-MM-dd') }}</current_system_time>

<instructions>
    1. **首先检查 <session_metadata>**。如果 `Login Status` 为 false，且用户询问私人订单信息，必须引导他们登录。
    2. **分析 <user_query>** 以检测订单号。如果未找到，检查 <recent_dialogue> 和 <memory_bank> 中先前提到的订单号。
    3. **严格遵循系统提示词中的场景逻辑。** 不得过度披露订单数据。
    4. 使用目标语言直接回答用户。
</instructions>
