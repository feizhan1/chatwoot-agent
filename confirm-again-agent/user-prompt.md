请使用以下上下文信息来处理用户的请求。

<session_metadata>
    Channel: {channel}
    Login Status: {login_status}
    Target Language: {target_language}
    Language Code: {language_code}
    missing info: {missing_info}
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
    1. 分析 <user_query> 和 <recent_dialogue>，识别**具体缺少什么信息**。
    2. 检查 <session_metadata> 以个性化语气（例如：如果已登录，可根据情况引用其账户上下文）。
    3. **暂不回答业务问题。**
    4. 根据缺少的信息，生成一个**有帮助的后续问题**来澄清用户意图。
       （例如："请问您能提供订单号吗？"或"您指的是哪个具体产品型号？"）
</instructions>
