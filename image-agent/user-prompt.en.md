Please identify the image intent based on the following structured context and output only the final text.

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


<instructions>
    1. Judge strictly according to system-prompt rules; DO NOT answer business questions.
    2. If <current_request><user_query> is non-empty: use user_query as the primary input for determination; recent_dialogue and active_context are only for entity completion and disambiguation.
    3. If <current_request><user_query> is empty: DO NOT extract intent from user_query; determine intent in the order of recent_dialogue (last 1-2 turns) → image_data → "specific information".
    4. Only two types of output are allowed:
       - The user may want to xxx, needs clarification from the user
       - The user has no clear intent
    5. DO NOT output JSON, DO NOT output explanations, DO NOT output any other text.
</instructions>
