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
    STRICTLY follow the rules defined in the system prompt and analyze the XML data context provided above.
    
    Execution Steps:
    1. Check <recent_dialogue> to determine if there is a continuation of "handoff / business customization" intent.
    2. Analyze the <user_query> and <image_data> within <current_request>.
    3. Cross-reference <session_metadata> and <memory_bank> to confirm contextual relevance.
    4. Match the most appropriate SOP.
    
    Output JSON directly. DO NOT add any additional explanatory text.
</instructions>
