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
    请严格遵循系统提示词中的规则，分析上述提供的 XML 数据上下文。
    
    执行步骤：
    1. 检查 <recent_dialogue> 判断是否存在“转人工/商务定制”意图的延续。
    2. 分析 <current_request> 中的 <user_query> 和 <image_data>。
    3. 结合 <session_metadata> 和 <memory_bank> 确认上下文关联。
    4. 匹配最合适的 SOP。
    
    请直接输出 JSON，不要添加任何额外的解释性文字。
</instructions>