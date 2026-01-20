Please use the following layered information to understand the user's request.

<session_metadata>
    Channel: {channel}
    Login Status: {login_status}
    Target Language: {target_language}
    Language Code: {language_code}
</session_metadata>

<memory_bank>
    {memory_bank}
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
    1. **Analyze <user_query>** to identify business issues (e.g., shipping, payment, policies).
    2. **Consult <memory_bank>** to identify the user's **business identity** (e.g., Wholesaler, Dropshipper, Individual Buyer) or **geographic location**.
    3. **Contextualize the answer**:
       - If the user is a **Dropshipper**, emphasize "No MOQ" and "API Support" when relevant.
       - If the user is a **Wholesaler**, emphasize "Bulk Pricing" and "Customization".
    4. Respond directly in the target language. DO NOT mention XML tags.
</instructions>
