Please use the following hierarchical information to understand the user's request.

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
    1. Ignore the specific content and context of <user_query>.
    2. Note that your system prompt specifies a strict response policy: only output the translation of the handoff prompt message.
    3. Use the target language from <session_metadata> to output the handoff prompt message.
</instructions>
