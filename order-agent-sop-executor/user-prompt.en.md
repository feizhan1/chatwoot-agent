Please use the following layered information to understand the user's request.

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

<current_system_time>
    {current_system_time}
</current_system_time>

<instructions>
    1. **Check <session_metadata> first.** If `Login Status` is false and the user asks about private order information, you MUST guide them to log in.
    2. **Analyze <user_query>** to detect order numbers. If none found, check <recent_dialogue> and <memory_bank> for previously mentioned order numbers.
    3. **STRICTLY follow the scenario logic in the system prompt.** DO NOT over-disclose order data.
    4. Respond to the user directly in the target language.
</instructions>
