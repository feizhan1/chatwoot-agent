Please identify the image intent based on the following structured context, and output only the final text.

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
    1. Strictly judge according to system-prompt rules, DO NOT answer business questions.
    2. If <user_query> is not empty: use user_query as the primary judgment input; recent_dialogue and active_context are only used for entity completion and disambiguation.
    3. If <user_query> is empty: DO NOT extract intent from user_query; retrieve intent from the most recent 1-2 turns in recent_dialogue.
    4. Only two output formats are allowed:
       - The user may want to xxx, need to clarify with the user
       - The user has no clear intent
    5. DO NOT output JSON, DO NOT output explanations, DO NOT output any other text.
</instructions>
