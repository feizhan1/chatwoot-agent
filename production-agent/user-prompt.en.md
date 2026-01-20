Please use the following layered information to understand the user's request.

<session_metadata>
    Channel: {{ $('Code in JavaScript1').first().json.channel }}
    Login Status: {{ $('Code in JavaScript1').first().json.isLogin }}
    Target Language: {{ $('language_detection_agent').first().json.output.language_name }}
    Language Code: {{ $('language_detection_agent').first().json.output.iso_code }}
</session_metadata>

<memory_bank>
    {{ $('Code in JavaScript10').item.json.final_memory_context }}
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
    1. **Check <session_metadata> first**. If the user needs to download images but Login Status is false, guide them to log in regardless of other memory.
    2. **Analyze <recent_dialogue>** to understand the immediate flow. If the user says "that one" or "no, the other one," use this raw conversation to resolve.
    3. **Consult <memory_bank>** for personalization.
       - If the user query is broad (e.g., "recommend a phone case"), use preferences from <memory_bank> (e.g., "likes red") to filter results.
       - Note: If information in <recent_dialogue> conflicts with <memory_bank>, trust <recent_dialogue> as it is most recent.
    4. Respond to the user directly in the target language.
</instructions>
