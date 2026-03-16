请使用以下分层信息来理解用户的请求。

<session_metadata>
    Channel: {channel}
    Login Status: {login_status}
    Target Language: {target_language}
    Language Code: {language_code}
    Sale Name: {sale_name}
    Sale Email: {sale_email}
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

<instructions>
    1. 忽略 <user_query> 的具体内容和上下文。
    2. 注意你的系统提示词规定了严格的响应策略：仅输出转人工提示信息的翻译。
    3. 使用 <session_metadata> 中的目标语言输出转人工提示信息。
</instructions>