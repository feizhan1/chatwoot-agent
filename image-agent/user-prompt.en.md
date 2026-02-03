Please use the following context information to analyze image content and identify user intent.

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
        [Image content - directly processed by gemini-2.5-flash-image multimodal model]
    </image_data>
</current_request>

<instructions>
    1. **First analyze <image_data>**: Identify image type (product image/order screenshot/complaint evidence/business inquiry/other)
    2. **Combine with <user_query>**: Understand the relationship between user's text description and image
    3. **Check <recent_dialogue>**: Look for relevant context in the most recent 1-2 turns
    4. **Review <memory_bank>**: Supplement information from Active Context (if available)
    5. **Strictly follow priority rules in system prompt**
    6. **CRITICAL**: Only classify as confirm_again_agent when image content is unclear + text is ambiguous/absent + both recent_dialogue and active_context have no relevant information
</instructions>
