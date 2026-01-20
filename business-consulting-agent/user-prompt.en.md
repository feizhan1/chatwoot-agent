Please use the following hierarchical information to understand the user's request.

<session_metadata>
    Channel: {{ $('Code in JavaScript1').first().json.channel }}
    Login Status: {{ $('Code in JavaScript1').first().json.isLogin }}
    Target Language: {{ $('language_detection_agent').first().json.output.language_name }}
    Language Code: {{ $('language_detection_agent').first().json.output.iso_code }}
</session_metadata>

<memory_bank>
    {{ $('Code in JavaScript10').first().json.final_memory_context }}
</memory_bank>

<recent_dialogue>
    {{ $('Code in JavaScript').first().json.history_context }}
</recent_dialogue>

<current_request>
    <user_query>
        {{ $('Code in JavaScript1').first().json.ask }}
    </user_query>
</current_request>

<instructions>
    1. **Analyze <user_query>** to identify business issues (e.g., shipping, payment, policy).
    2. **Consult <memory_bank>** to identify the user's **business identity** (e.g., Wholesaler, Dropshipper, Individual Buyer) or **geographic location**.
    3. **Contextualize the answer**:
       - If the user is a **Dropshipper**, emphasize "no MOQ" and "API support" when relevant.
       - If the user is a **Wholesaler**, emphasize "bulk pricing" and "customization".
    4. Respond directly in the target language. DO NOT mention XML tags.
</instructions>
