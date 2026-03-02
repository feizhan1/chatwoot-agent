请基于以下结构化上下文识别图片意图，并仅输出最终文案。

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
    1. 严格按 system-prompt 规则判断，不要回答业务问题。
    2. 若 <user_query> 非空：以 user_query 作为主判定输入；recent_dialogue 和 active_context 仅用于补全实体与消歧。
    3. 若 <user_query> 为空：禁止从 user_query 提取诉求；从 recent_dialogue 最近 1-2 轮 获取诉求。
    4. 输出只允许两种：
       - 用户可能想xxx，需要向用户澄清
       - 用户无明确意图
    5. 不要输出 JSON、不要输出解释、不要输出其他文本。
</instructions>
