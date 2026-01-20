请使用以下分层信息来理解用户的请求。

<session_metadata>
    Channel: {{ $('Code in JavaScript1').first().json.channel }}
    Login Status: {{ $('Code in JavaScript1').first().json.isLogin }}
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
    1. **首先检查 <session_metadata>**。如果 `Login Status` 为 false，且用户询问私人订单信息，必须引导他们登录。
    2. **分析 <user_query>** 以检测订单号。如果未找到，检查 <recent_dialogue> 和 <memory_bank> 中先前提到的订单号。
    3. **严格遵循系统提示词中的场景逻辑。** 不得过度披露订单数据。
    4. 使用目标语言直接回答用户。
</instructions>
