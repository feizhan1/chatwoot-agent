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
    1. 🚨 最高优先级：检查 <user_query> 和 <recent_dialogue> 中是否包含“支付失败/支付异常”的语义。如果是，立即选定 SOP_2，停止后续意图判断。
    2. 全局搜索并提取订单号（格式如 M25121600007 等），即使 <user_query> 中没有，也要检查 <recent_dialogue> 和 <memory_bank>。
    3. 根据 <user_query> 确定用户具体想对订单进行什么操作（查询状态、修改地址、反馈物流异常等）。
    4. 匹配最合适的 SOP。
    
    请直接输出 JSON，不要添加任何额外的解释性文字。
</instructions>