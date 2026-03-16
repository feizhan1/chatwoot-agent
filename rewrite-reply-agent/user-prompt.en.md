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

<draft_message>
    {draft_message}
</draft_message>

<event_type>
    {event_type}
</event_type>

<instructions>
    1. Carefully review the draft content in <draft_message>.
    2. Reference <recent_dialogue> to understand the conversational context.
    3. Determine whether to add personalization or directly rewrite based on <event_type>.
    4. Optimize message content and tone according to the rewrite mode defined in the system prompt.
</instructions>
