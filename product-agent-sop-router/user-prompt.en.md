<session_metadata>
    Login Status: {{ $('Code in JavaScript1').first().json.isLogin }}
</session_metadata>

<memory_bank>
    ### User Long-term Profile (Historical Data)
    {{ $('Code in JavaScript10').first().json.user_profile || '无' }}

    ### Active Context (Current Session Summary)
    {{ $('Code in JavaScript10').first().json.active_context || '无' }}
</memory_bank>

<recent_dialogue>
    {{ $('Code in JavaScript').first().json.history_context || '无' }}
</recent_dialogue>

<current_request>
    <user_query>
        {{ $('Code in JavaScript1').first().json.ask }}
    </user_query>
    <image_data>
        {image_data}
    </image_data>
</current_request>

<instructions>
    STRICTLY follow the rules defined in the system prompt and analyze the XML data context provided above.
    
    Execution Steps:
    1. Check <recent_dialogue> to determine if there is a continuation of "handoff to human agent / business customization" intent.
    2. Analyze the <user_query> and <image_data> within <current_request>.
    3. Cross-reference <session_metadata> and <memory_bank> to confirm contextual relevance.
    4. Match the most appropriate SOP.
    
    Output JSON directly. DO NOT add any additional explanatory text.
</instructions>
