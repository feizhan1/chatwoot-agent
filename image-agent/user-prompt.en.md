Please use the following context information to analyze the image content and identify user intent.

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

<instructions>
    1. Combine <recent_dialogue> recent conversation and image content to determine the business action the user wants to execute
    2. Strictly route according to the priority and single decision flow in the system prompt
    3. Only categorize as confirm_again_agent when "possibly business-related but unable to determine specific action"
</instructions>
