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
    1. **First check <session_metadata>**. If `Login Status` is false and the user inquires about private order information, you MUST guide them to log in.
    2. **Analyze <user_query>** to detect order numbers. If none found, check <recent_dialogue> and <memory_bank> for previously mentioned order numbers.
    3. **STRICTLY follow the scenario logic in the system prompt.** DO NOT over-disclose order data.
    4. Respond to the user directly in the Target Language.
</instructions>
