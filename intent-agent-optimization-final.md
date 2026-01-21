# Intent-Agent 优化方案（最终版）

## 🎯 采用的方案

基于用户建议，采用**统一 XML 结构 + 增强指代解析规则**的方案。

---

## ✅ 方案优势

### 1. 保持架构一致性
所有 agent 使用相同的 XML 结构：
```xml
<session_metadata> ... </session_metadata>
<memory_bank> ... </memory_bank>
<recent_dialogue> ... </recent_dialogue>
<current_request> ... </current_request>
```

### 2. recent_dialogue 格式清晰
```
ai: "订单 V25121000001 已发货，快递单号 SF123456"
human: "什么时候到？"
ai: "预计 3-5 个工作日送达"
human: "运费多少？"
```
- 清晰的对话轮次
- LLM 容易识别最近的上下文
- 支持指代解析

### 3. 最小化修改
- 不需要大幅重构 n8n 工作流
- 复用现有的 prompt 模板系统
- 只需调整数据格式和增加指代解析规则

---

## 📝 完整的 Prompt 模板

### intent-agent/user-prompt.md

```markdown
请使用以下分层信息来理解用户的请求。

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
    {recent_dialogue}
</recent_dialogue>

<current_request>
    <user_query>
        {user_query}
    </user_query>
</current_request>

<instructions>
    1. **首先检查 <recent_dialogue>**：如果用户使用指代词（"那个订单"、"这个产品"、"它"）或省略主语，请从最近 1-2 轮对话中寻找被指代的实体。
    2. **分析 <user_query>**：结合对话历史，识别用户的真实意图。
    3. **查阅 <memory_bank>**：了解用户的长期偏好和当前会话的活跃主题。
    4. **严格遵循优先级**：安全检测 → 明确意图（含从上下文补全）→ 模糊意图 → 闲聊。
    5. **关键原则**：仅当 recent_dialogue 和 active_context 中**都没有**相关信息时，才归类为 `need_confirm_again`。
</instructions>
```

### intent-agent/system-prompt.md 关键新增部分

已在 system-prompt 中添加了详细的**指代解析规则**，包括：

1. **规则 1**: 订单相关指代
2. **规则 2**: 产品相关指代
3. **规则 3**: 连续追问判断
4. **规则 4**: 从 Active Context 补全信息
5. **规则 5**: 仅在真正无法补全时才归类为 need_confirm_again

（详见 `intent-agent/system-prompt.md` 的"指代解析规则"章节）

---

## 🔧 在 n8n 中的实现

### 关键节点：Build Context Data

```javascript
// n8n "Prepare Context for Intent Agent" 节点

function prepareIntentAgentContext(webhookData, userProfile, dialogueHistory) {
  // 1. 提取最近 3-5 轮对话
  const recentTurns = dialogueHistory.slice(-5);

  // 2. 格式化 recent_dialogue
  const recentDialogueText = recentTurns.map(turn => {
    return `ai: "${turn.agent_response}"\nhuman: "${turn.user_input}"`;
  }).join('\n');

  // 3. 提取 Active Context（从最近对话中提取关键实体）
  const activeContext = extractActiveContext(recentTurns);

  // 4. 格式化 Active Context
  const activeContextText = formatActiveContext(activeContext);

  // 5. 构建完整的 prompt
  const userPrompt = userPromptTemplate
    .replace('{channel}', webhookData.channel)
    .replace('{login_status}', webhookData.isLogin ? 'This user is already logged in.' : 'This user is not logged in.')
    .replace('{target_language}', webhookData.language_name)
    .replace('{language_code}', webhookData.language_code)
    .replace('{user_profile}', userProfile.long_term_summary)
    .replace('{active_context}', activeContextText)
    .replace('{recent_dialogue}', recentDialogueText)
    .replace('{user_query}', webhookData.current_message);

  return {
    system_prompt: systemPrompt,
    user_prompt: userPrompt
  };
}

// 提取 Active Context 的函数
function extractActiveContext(recentTurns) {
  const context = {
    activeOrders: [],
    activeProducts: [],
    sessionTheme: null
  };

  // 从最近的对话中提取实体
  recentTurns.forEach(turn => {
    // 提取订单号
    const orderMatches = turn.user_input.match(/[A-Z]\d{11}/g) ||
                         turn.agent_response.match(/[A-Z]\d{11}/g) || [];
    context.activeOrders.push(...orderMatches);

    // 提取产品 SKU
    const skuMatches = turn.agent_response.match(/SKU[:\s]+([A-Z0-9-]+)/gi) || [];
    context.activeProducts.push(...skuMatches.map(m => m.split(/[:\s]+/)[1]));

    // 识别会话主题
    if (turn.intent) {
      context.sessionTheme = turn.intent;
    }
  });

  // 去重
  context.activeOrders = [...new Set(context.activeOrders)];
  context.activeProducts = [...new Set(context.activeProducts)];

  return context;
}

// 格式化 Active Context
function formatActiveContext(context) {
  let text = '';

  if (context.activeOrders.length > 0) {
    text += `- Active Orders: ${context.activeOrders.join(', ')}\n`;
  }

  if (context.activeProducts.length > 0) {
    text += `- Active Products (SKU): ${context.activeProducts.join(', ')}\n`;
  }

  if (context.sessionTheme) {
    text += `- Session Theme: ${context.sessionTheme}\n`;
  }

  if (text === '') {
    text = '- No active context in current session\n';
  }

  return text;
}
```

### 示例输出

**Context Data（传递给 intent-agent）**：

```markdown
请使用以下分层信息来理解用户的请求。

<session_metadata>
    Channel: telegram
    Login Status: This user is already logged in.
    Target Language: Chinese (Simplified)
    Language Code: zh
</session_metadata>

<memory_bank>
    ### User Long-term Profile (Historical Data)
    - User Zhanfei, a resident of Shenzhen, China
    - Works at Shenzhen Zhenzhi Technology Co., Ltd.
    - Interests: programming, photography, digital technology
    - Business Type: Dropshipper
    - Preference: Red phone cases, fast shipping (1-3 days)

    ### Active Context (Current Session Summary)
    - Active Orders: V25121000001, M26011500001
    - Active Products (SKU): IP17-RED-TPU-001
    - Session Theme: Order tracking and product inquiry
</memory_bank>

<recent_dialogue>
ai: "订单 M26011500001 当前未支付，请先完成付款。"
human: "帮我查下订单 V25121000001"
ai: "订单 V25121000001 已支付，金额 $150，状态：已发货，快递单号 SF123456"
human: "什么时候到？"  ← 当前请求
</recent_dialogue>

<current_request>
    <user_query>
        什么时候到？
    </user_query>
</current_request>

<instructions>
    1. **首先检查 <recent_dialogue>**：如果用户使用指代词（"那个订单"、"这个产品"、"它"）或省略主语，请从最近 1-2 轮对话中寻找被指代的实体。
    2. **分析 <user_query>**：结合对话历史，识别用户的真实意图。
    3. **查阅 <memory_bank>**：了解用户的长期偏好和当前会话的活跃主题。
    4. **严格遵循优先级**：安全检测 → 明确意图（含从上下文补全）→ 模糊意图 → 闲聊。
    5. **关键原则**：仅当 recent_dialogue 和 active_context 中**都没有**相关信息时，才归类为 `need_confirm_again`。
</instructions>
```

**Intent-Agent 输出**：

```json
{
  "intent": "query_user_order",
  "entities": {
    "order_number": "V25121000001",
    "query_type": "delivery_estimate"
  },
  "resolution_source": "recent_dialogue_turn_n_minus_1",
  "confidence": 0.95,
  "reasoning": "用户问'什么时候到？'，从 recent_dialogue 的上一轮提取到订单号 V25121000001，这是对该订单发货状态的追问。"
}
```

---

## 🧪 测试用例

### Test Case 1: 订单号指代（从 recent_dialogue 补全）

**输入**：
```
<recent_dialogue>
human: "查询订单 V25121000001 的付款信息"
ai: "订单 V25121000001 已支付，金额 $150"
human: "那发货了吗？"
</recent_dialogue>
```

**预期输出**：
```json
{
  "intent": "query_user_order",
  "order_number": "V25121000001",
  "resolution_source": "recent_dialogue_turn_n_minus_1"
}
```

**不应该输出**：`need_confirm_again` ❌

---

### Test Case 2: 产品SKU指代

**输入**：
```
<recent_dialogue>
ai: "这款 iPhone 17 红色手机壳（SKU: IP17-RED-TPU-001）价格 $5.99"
human: "有库存吗？"
</recent_dialogue>
```

**预期输出**：
```json
{
  "intent": "query_product_data",
  "sku": "IP17-RED-TPU-001",
  "resolution_source": "recent_dialogue_turn_n_minus_1"
}
```

---

### Test Case 3: 从 Active Context 补全

**输入**：
```
<memory_bank>
### Active Context
- Active Orders: V25121000001
- Session Theme: Order tracking
</memory_bank>

<recent_dialogue>
human: "你好"
ai: "您好！有什么可以帮您？"
human: "那个订单发货了吗？"
</recent_dialogue>
```

**预期输出**：
```json
{
  "intent": "query_user_order",
  "order_number": "V25121000001",
  "resolution_source": "active_context"
}
```

---

### Test Case 4: 确实应该 confirm-again

**输入**：
```
<memory_bank>
### Active Context
- No active orders in current session
- No recent product inquiries
</memory_bank>

<recent_dialogue>
human: "你好"
ai: "您好！有什么可以帮您？"
human: "我想查物流"
</recent_dialogue>
```

**预期输出**：
```json
{
  "intent": "need_confirm_again",
  "reason": "用户想查物流但未提供订单号，且上下文中无活跃订单",
  "resolution_source": "unable_to_resolve"
}
```

---

## 📊 预期效果对比

| 指标 | Before（当前）| After（优化后）|
|------|--------------|----------------|
| confirm-again 误判率 | 60-70% | <10% |
| 指代解析准确率 | ~30% | >90% |
| 用户连续对话体验 | 差，需反复提供信息 | 流畅，自然对话 |
| confirm-again-agent 触发次数 | 高 | 降低 70%+ |

---

## 🚀 实施步骤

### Phase 1: 更新 Prompt（1天）

1. ✅ 创建 `intent-agent/user-prompt.md`（已完成）
2. ✅ 更新 `intent-agent/system-prompt.md` 添加指代解析规则（已完成）
3. 🔄 运行翻译脚本生成英文版本：
   ```bash
   ./scripts/translate-prompt.sh intent-agent/user-prompt.md
   ./scripts/translate-prompt.sh intent-agent/system-prompt.md
   ```
4. 🔄 提交到 git：
   ```bash
   git add intent-agent/
   git commit -m "优化 intent-agent 指代解析能力"
   ```

### Phase 2: 修改 n8n 工作流（1-2天）

1. 创建新节点 "Extract Active Context"
   - 从最近对话中提取订单号、SKU
   - 识别会话主题

2. 修改节点 "Build Context for Intent Agent"
   - 格式化 recent_dialogue（ai/human 交替）
   - 添加 Active Context 到 memory_bank
   - 使用新的 user-prompt 模板

3. 测试数据流
   - 验证 Context Data 格式正确
   - 检查占位符替换完整

### Phase 3: 测试与验证（2-3天）

1. 准备 20 个真实对话案例
2. 逐个测试指代解析准确率
3. 调整 Active Context 提取逻辑
4. 监控 confirm-again-agent 触发率

### Phase 4: 上线与监控（持续）

1. 部署到生产环境
2. 记录所有 need_confirm_again 触发案例
3. 分析误判情况
4. 持续优化指代解析规则

---

## 🎯 关键成功因素

1. ✅ **统一 XML 结构**（session_metadata, memory_bank, recent_dialogue）
2. ✅ **清晰的对话历史格式**（ai/human 交替，易于识别轮次）
3. ✅ **Active Context 机制**（维护当前会话的活跃实体）
4. ✅ **明确的指代解析规则**（5条规则 + 决策流程图）
5. ✅ **充分的测试用例**（覆盖各种指代场景）

---

## 💡 额外建议

### 1. 增强 Active Context 的时效性

```javascript
// 为每个实体添加时间戳和轮次信息
{
  activeOrders: [
    { order_number: "V25121000001", mentioned_at_turn: 3, timestamp: "2026-01-21 10:30:15" }
  ],
  activeProducts: [
    { sku: "IP17-RED-TPU-001", mentioned_at_turn: 2, timestamp: "2026-01-21 10:28:42" }
  ]
}

// 如果时间间隔超过 5 分钟，降低该实体的权重
```

### 2. 增加 resolution_source 的可见性

在返回给用户的消息中（内部调试模式），显示：
```
[DEBUG] 订单号从上一轮对话中自动提取：V25121000001
```

### 3. 监控和优化循环

```javascript
// 记录每次意图识别
logIntentResolution({
  user_input: "什么时候到？",
  intent: "query_user_order",
  resolution_source: "recent_dialogue_turn_n_minus_1",
  entities_extracted: { order_number: "V25121000001" },
  confidence: 0.95
});

// 如果触发了 need_confirm_again，记录原因
logConfirmAgainTrigger({
  user_input: "我想查物流",
  reason: "no_order_in_context",
  recent_dialogue_summary: "用户刚打招呼，未讨论任何订单"
});
```

---

## 📖 总结

采用**统一 XML 结构 + 增强指代解析规则**的方案，可以：

1. ✅ 保持与其他 agent 的架构一致性
2. ✅ 充分利用 recent_dialogue 的清晰格式
3. ✅ 通过 Active Context 维护会话状态
4. ✅ 用明确的规则指导 LLM 进行指代解析
5. ✅ 大幅降低 confirm-again-agent 的误判率

**预期效果**：用户可以自然地进行连续对话，系统能够准确理解指代关系，confirm-again-agent 触发率降低 70% 以上。
