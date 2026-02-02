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
    1. **First check <session_metadata>**. If the user needs to download images but Login Status is false, regardless of other memory, guide them to log in.
    2. **Analyze <recent_dialogue>** to understand the immediate flow. If the user says "that one" or "no, the other one," use this raw conversation to resolve.
    3. **Consult <memory_bank>** for personalization.
       - If the user query is broad (e.g., "recommend a phone case"), use preferences from <memory_bank> (e.g., "likes red") to filter results.
       - Note: If information in <recent_dialogue> conflicts with <memory_bank>, trust <recent_dialogue> as it is the most current.
    4. Respond to the user directly in the target language.
</instructions>
