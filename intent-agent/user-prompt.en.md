Please use the following hierarchical information to understand the user's request.

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
    ### User is currently asking
    {user_query}
    ### Pictures currently provided by the user
    {image_data}
</current_request>

<instructions>
    1. **First check <recent_dialogue>**: If the user uses pronouns ("that order", "this product", "it") or omits the subject, look for the referenced entity in the most recent 1-2 rounds of dialogue.
    2. **Analyze <recent_dialogue>**: Identify the user's true intent.
    3. **Consult <memory_bank>**: Understand the user's long-term preferences and active topics in the current session.
    4. **Strictly follow priority**: Safety detection → Clear intent (including completion from context) → Ambiguous intent → Casual chat.
    5. **Key principle**: Only classify as `confirm_again_agent` when there is **no** relevant information in both recent_dialogue and active_context.
</instructions>
