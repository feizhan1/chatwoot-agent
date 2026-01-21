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

<instructions>
    1. **First check <recent_dialogue>**: If the user uses pronouns ("that order", "this product", "it") or omits the subject, look for the referenced entity in the most recent 1-2 turns of conversation.
    2. **Analyze <user_query>**: Identify the user's true intent by combining conversation history.
    3. **Consult <memory_bank>**: Understand the user's long-term preferences and active topics in the current session.
    4. **Strictly follow priority**: Security detection → Clear intent (including completion from context) → Ambiguous intent → Chitchat.
    5. **CRITICAL principle**: Only classify as `need_confirm_again` when there is **NO** relevant information in both recent_dialogue and active_context.
</instructions>
