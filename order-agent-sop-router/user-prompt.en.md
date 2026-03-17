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
    In order-related scenarios, extract order numbers from <user_query> first, then supplement with <recent_dialogue> and <active_context>.
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

<instructions>
    Strictly follow the rules in the system prompt, analyze the above XML data and match the most appropriate SOP.

    Channel priority rules:
    1) If Channel = Channel::WebWidget and user is not logged in, and asking about any order-related data (order status, logistics, order details, cancel/modify, refund/return, invoice, shipping cost, etc.), MUST route to SOP_13.
    2) If Channel = Channel:TwilioSms and asking about order-related scenarios, do not enforce login check, continue normal routing.

    Order number rules:
    - SOPs requiring order number: SOP_2 / SOP_4 / SOP_5 / SOP_7.
    - Note: SOP_3 is fixed guidance to order list page, does not rely on order query tool, therefore order number not mandatory.
    - If matching above "order number required" SOPs but no valid order number exists, or multiple numbers conflict with no determinable active order number, MUST route to SOP_1 with extracted_order_number = null.

    Output requirements:
    - Output JSON only.
    - Do not output explanatory text.
</instructions>
