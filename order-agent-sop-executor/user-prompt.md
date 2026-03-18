请使用以下分层信息来理解用户的请求。
<session_metadata>
    Channel: {channel}
    Login Status: {login_status}
    Target Language: {target_language}
    Language Code: {language_code}
    sale name: {sale_name}
    sale email: {sale_email}
    tvcmall_web_baseUrl: {tvcmall_web_baseUrl}
</session_metadata>

<memory_bank>
    ### User Long-term Profile (Historical Data)
    {user_profile}

    ### Active Context (Current Session Summary)
    {active_context}
</memory_bank>

<recent_dialogue>
    ### Latest conversations
    {recent_dialogue}
</recent_dialogue>

<current_request>
    ### User is currently asking
    <user_query>{user_query}</user_query>
    ### Pictures currently provided by the user
    <image_data>{image_data}</image_data>
</current_request>

<current_system_time>
    ### current system time
    {current_system_time}
</current_system_time>

<instructions>
    1. 严格执行系统提示词中分配的SOP，不得跨SOP执行或自行改变流程。
    2. 涉及时间判断时，仅使用 `<current_system_time>` 推理，不使用模型内置时间。
</instructions>
