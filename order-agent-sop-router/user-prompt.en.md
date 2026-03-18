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
    ### Latest conversations
    {recent_dialogue}
</recent_dialogue>

<current_request>
    ### User is currently asking
    <user_query>{user_query}</user_query>
    ### Pictures currently provided by the user
    <image_data>{image_data}</image_data>
</current_request>

<context_priority>
    ### Context priority for routing (high -> low)
    1) current_request
    2) recent_dialogue
    3) active_context
    4) user_profile
</context_priority>

<input_normalization>
    ### Image input normalization
    The following cases are all considered "no image input": null, empty string, empty array, invalid URL, placeholder text only (e.g., "N/A").

    ### Order number extraction hints
    In order-related scenarios, prioritize extracting order numbers from <user_query>, then supplement with <recent_dialogue> and <active_context>.
    Valid order number formats:
    1) M/V/T/R/S + 11-14 digits
    2) M/V/T/R/S + 6-12 alphanumeric characters
    3) Pure 6-14 digits
    When multiple numbers exist, prioritize: "latest mention in current message > most recent user message > most recent agent-user interaction".
</input_normalization>

<current_system_time>
    ### current system time
    {current_system_time}
</current_system_time>
