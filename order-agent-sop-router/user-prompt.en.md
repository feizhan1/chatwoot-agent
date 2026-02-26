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
    1. 🚨 HIGHEST PRIORITY: Check whether <user_query> and <recent_dialogue> contain semantics related to "payment failure / payment error". If so, immediately select SOP_2 and stop all subsequent intent determination.
    2. Globally search and extract order numbers (format e.g., M25121600007, etc.). Even if not present in <user_query>, also check <recent_dialogue> and <memory_bank>.
    3. Based on <user_query>, determine what specific action the user wants to perform on the order (check status, modify address, report shipping issues, etc.).
    4. Match the most appropriate SOP.
    
    Output JSON directly. DO NOT add any additional explanatory text.
</instructions>
