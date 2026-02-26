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
   <image_data>
        {image_data}
    </image_data>
</current_request>

<current_system_time>
    {current_system_time}
</current_system_time>

<instructions>
    1. **首先检查 <session_metadata>**。如果用户需要下载图片但 Login Status 为 false，无论其他记忆如何，都要引导他们登录。
    2. **分析 <recent_dialogue>** 以理解即时流程。如果用户说"那个"或"不，另一个"，使用此原始对话来解决。
    3. **查阅 <memory_bank>** 进行个性化。
       - 如果用户查询宽泛（例如："推荐一个手机壳"），使用 <memory_bank> 中的偏好（例如："喜欢红色"）来过滤结果。
       - 注意：如果 <recent_dialogue> 中的信息与 <memory_bank> 冲突，信任 <recent_dialogue>，因为它是最新的。
    4. 使用目标语言直接回答用户。
</instructions>
