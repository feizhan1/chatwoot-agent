# Intent-Agent 指代解析问题修复方案

## 问题症状
用户反复触发 `confirm-again-agent`，即使前一轮对话已经提供了必要的上下文信息（如订单号、产品信息）。

## 根本原因

### 1. Context Data 格式缺陷
当前格式将所有对话历史挤压成一长串文本，LLM 无法准确识别对话轮次和时间顺序。

**当前格式（有问题）**：
```markdown
### Current Session Context (Recent Interaction)
- User provided order number V25121000001 and requests payment information for that order
- User requests to be transferred t preference for red phone cases, is interested in iPhone 17 cases specifically red soft TPU cases for iPhone 17 Pro/Pro Max, wants shipping within 1-3 business days, and is seeking cheaper logistics options than DHL due to cost concerns.
```

**问题**：
- 没有对话轮次结构
- 无法区分时间先后
- 用户指代词（"那个订单"）无法准确解析

### 2. Intent-Agent 缺少明确的指代解析指令
虽然 system-prompt 提到"从 Context Data 中找指代"，但没有具体的操作规则。

---

## 完整解决方案

### Step 1: 在 n8n 中改进 Context Data 格式

**目标**：提供结构化的对话历史，明确标记时间顺序和关键实体。

**新格式**：
```markdown
# Context Data

## User Long-term Profile
- User ID: user_12345
- Name: Zhanfei
- Location: Shenzhen, China
- Business Type: Dropshipper
- Language Preference: Chinese (Simplified)
- Historical Preferences:
  * Prefers red color products
  * Interested in iPhone accessories
  * Cost-sensitive on logistics

## Recent Dialogue History (Chronological, Last 3 Turns)

### Turn N-2 (2 minutes ago)
**User**: "有没有红色的 iPhone 17 手机壳？"
**Agent** [production-agent]: "我们有5款红色 iPhone 17 手机壳，包括：
1. 软TPU材质 - SKU: IP17-RED-TPU-001, 价格: $5.99
2. 硅胶材质 - SKU: IP17-RED-SIL-002, 价格: $6.99
..."
**Extracted Entities**:
- product_category: iPhone 17 case
- color_preference: red
- material_interest: soft TPU

### Turn N-1 (30 seconds ago)
**User**: "查询订单 V25121000001 的付款信息"
**Agent** [order-agent]: "订单 V25121000001 详情：
- 付款方式：PayPal
- 金额：$150.00
- 状态：已支付
- 下单时间：2026-01-20 10:30"
**Extracted Entities**:
- order_number: V25121000001
- payment_method: PayPal
- order_status: paid

### Turn N (CURRENT - Just Now)
**User**: "那个订单什么时候发货？"
**Agent**: [待处理]

## Active Entities (Most Relevant for Current Turn)
- **Primary**: order_number = V25121000001 (mentioned in Turn N-1)
- **Secondary**: product_interest = iPhone 17 case (red, soft TPU) (mentioned in Turn N-2)

## Conversation Context Summary
User is currently focused on order V25121000001. Previous topic was about iPhone 17 cases.
```

**实现方式（n8n 伪代码）**：
```javascript
// 在 n8n 的 "Prepare Context Data" 节点中
function buildContextData(userProfile, dialogueHistory, currentUserInput) {
  // 提取最近 3 轮对话
  const recentTurns = dialogueHistory.slice(-3);

  // 从历史中提取关键实体
  const entities = extractEntities(recentTurns);

  // 构建结构化 Context Data
  return `
# Context Data

## User Long-term Profile
${formatUserProfile(userProfile)}

## Recent Dialogue History (Chronological, Last ${recentTurns.length} Turns)

${recentTurns.map((turn, i) => `
### Turn ${i+1} (${turn.timestamp})
**User**: "${turn.user_input}"
**Agent** [${turn.agent_used}]: "${turn.agent_response}"
**Extracted Entities**: ${JSON.stringify(turn.entities)}
`).join('\n')}

### Turn N (CURRENT - Just Now)
**User**: "${currentUserInput}"
**Agent**: [待处理]

## Active Entities (Most Relevant for Current Turn)
${formatActiveEntities(entities)}

## Conversation Context Summary
${generateContextSummary(recentTurns)}
`;
}
```

---

### Step 2: 增强 intent-agent 的 system-prompt

在 `intent-agent/system-prompt.md` 的 `# Context Data` 部分之后，添加：

```markdown
# Context Data (新增板块)
**以下是该用户的长期画像和当前会话上下文，如果用户输入中包含代词（如"这个"、"它"、"那个订单"），请优先从这里寻找指代对象：**

{final_memory_context}

---

## 指代解析规则 (CRITICAL - 必须严格遵守)

当用户使用指代词或省略主语时，**必须首先尝试从 Context Data 中补全信息**，而不是立即归类为 `need_confirm_again`。

### 规则 1: 订单相关指代
- **指代词**: "那个订单"、"这个订单"、"我的订单"、"刚才那个"
- **解析方法**:
  1. 查看 Recent Dialogue History 中 **Turn N-1**（最近一轮）是否提到订单号
  2. 如果 Turn N-1 是 order-agent 的回复，提取其中的订单号
  3. 如果 Active Entities 中有 order_number，使用该值
- **示例**:
  ```
  Turn N-1: User: "查询订单 V25121000001"
  Turn N: User: "那个订单什么时候到？"
  → 解析为: query_user_order, order_number=V25121000001
  ```

### 规则 2: 产品相关指代
- **指代词**: "这个"、"那个产品"、"它"、"刚才看的"
- **解析方法**:
  1. 查看 Recent Dialogue History 中最近提到的产品 SKU 或产品类别
  2. 检查 Active Entities 中的 product_interest 或 sku
  3. 如果有明确的产品上下文，视为意图明确
- **示例**:
  ```
  Turn N-1: Agent [production-agent]: "这款 SKU: IP17-RED-TPU-001 的价格是 $5.99"
  Turn N: User: "这个有库存吗？"
  → 解析为: query_product_data, sku=IP17-RED-TPU-001
  ```

### 规则 3: 时间连续性判断
- **触发条件**: 用户的问题看似缺少主语，但与上一轮对话高度相关
- **判断标准**:
  - Turn N-1 的 agent 刚回复了某个查询结果
  - Turn N 的用户问题是对该结果的追问（如"什么时候"、"多少钱"、"在哪里"）
  - 时间间隔 < 2分钟
- **操作**: 将 Turn N-1 的主题实体继承到 Turn N
- **示例**:
  ```
  Turn N-1: Agent: "订单 V25121000001 已发货"
  Turn N (10秒后): User: "什么时候到？"
  → 不是 need_confirm_again，而是 query_user_order (订单号=V25121000001)
  ```

### 规则 4: 省略主语的追问
常见的追问模式：
- "多少钱？" → 如果 Turn N-1 讨论了产品，继承产品信息
- "什么时候到？" → 如果 Turn N-1 讨论了订单或物流，继承订单信息
- "有库存吗？" → 继承产品SKU
- "支持退货吗？" → 如果 Turn N-1 讨论了产品，归为 query_knowledge_base（产品退货政策）

### 规则 5: 仅在确实无法补全时才归类为 need_confirm_again
**必须同时满足以下条件**才归类为 `need_confirm_again`：
1. 用户问题确实缺少关键信息（如订单号、SKU）
2. **且** Recent Dialogue History 的最近 2 轮对话中**完全没有**相关上下文
3. **且** Active Entities 中**没有**可用的实体信息
4. **且** 用户问题的时间与上一轮对话**间隔超过 5 分钟**（说明不是连续对话）

**反例（不应该归类为 need_confirm_again）**:
```
Turn N-1: User: "查询订单 V25121000001"
Turn N-1: Agent: "订单已发货，快递单号: SF123456"
Turn N (20秒后): User: "什么时候到？"
→ 这是明确的 query_user_order，订单号=V25121000001
```

---

## 指代解析决策流程图

```
用户输入 Turn N
    ↓
是否包含指代词？（"那个"、"这个"、"它"、省略主语）
    ↓ 是
检查 Turn N-1 (最近一轮对话)
    ↓
Turn N-1 是否讨论了订单/产品/政策？
    ↓ 是
提取 Turn N-1 的关键实体（订单号/SKU/主题）
    ↓
将实体应用到 Turn N 的意图识别
    ↓
归类为 query_user_order / query_product_data / query_knowledge_base
    ↓
输出：明确意图 + 补全的实体信息

    ↓ 否（Turn N-1 无相关上下文）
检查 Active Entities
    ↓
是否有可用实体？
    ↓ 是
使用 Active Entities 补全
    ↓
归类为明确意图

    ↓ 否
最终归类为 need_confirm_again
```

---

## 输出格式要求

当成功从 Context Data 补全信息后，intent-agent 应该在输出中明确标注：

```json
{
  "intent": "query_user_order",
  "confidence": 0.95,
  "entities": {
    "order_number": "V25121000001"
  },
  "resolution_method": "resolved_from_turn_n_minus_1",
  "context_used": "Turn N-1: User mentioned order V25121000001"
}
```

---

## 测试用例

### 测试 1: 订单号指代
**Context**:
```
Turn N-1: User: "查询订单 V25121000001"
Turn N-1: Agent: "订单 V25121000001，状态：已发货"
```
**Turn N Input**: "那个订单什么时候到？"
**Expected Output**:
```json
{
  "intent": "query_user_order",
  "order_number": "V25121000001",
  "resolution": "resolved_from_context"
}
```
**Not**: `need_confirm_again`

### 测试 2: 产品SKU指代
**Context**:
```
Turn N-1: User: "SKU: IP17-RED-TPU-001 多少钱？"
Turn N-1: Agent: "SKU: IP17-RED-TPU-001 价格 $5.99"
```
**Turn N Input**: "这个有库存吗？"
**Expected Output**:
```json
{
  "intent": "query_product_data",
  "sku": "IP17-RED-TPU-001",
  "resolution": "resolved_from_context"
}
```

### 测试 3: 时间连续追问
**Context**:
```
Turn N-1: Agent [order-agent]: "订单 V25121000001 已通过 DHL 发货"
```
**Turn N Input** (5秒后): "运费多少？"
**Expected Output**:
```json
{
  "intent": "query_user_order",
  "order_number": "V25121000001",
  "query_type": "shipping_cost"
}
```

### 测试 4: 确实应该 confirm-again 的情况
**Context**:
```
Turn N-2: User: "你好"
Turn N-1: Agent: "您好！有什么可以帮您？"
```
**Turn N Input** (10分钟后): "那个订单什么时候到？"
**Expected Output**:
```json
{
  "intent": "need_confirm_again",
  "reason": "no_order_context_in_recent_history"
}
```

---

## 实施步骤

### Phase 1: 修改 n8n 工作流（1-2天）
1. 创建新的 "Build Context Data" 节点
2. 实现结构化的对话历史格式
3. 提取并维护 Active Entities
4. 测试 Context Data 生成逻辑

### Phase 2: 更新 intent-agent system-prompt（1天）
1. 在 `intent-agent/system-prompt.md` 添加"指代解析规则"章节
2. 运行翻译脚本生成英文版本
3. 部署到 n8n

### Phase 3: 测试与优化（2-3天）
1. 准备 20 个真实用户对话案例
2. 逐个测试指代解析准确率
3. 调整规则和阈值
4. 监控 confirm-again-agent 的触发率（目标：降低 50%+）

### Phase 4: 监控与迭代（持续）
1. 记录所有 need_confirm_again 的触发案例
2. 分析哪些本应该被解析但没有被解析
3. 持续优化 Context Data 格式和解析规则

---

## 预期效果

**Before**（当前状态）:
- 用户连续对话时，60-70% 的追问被误判为 `need_confirm_again`
- 用户体验差，需要反复提供订单号/SKU
- confirm-again-agent 触发率高

**After**（优化后）:
- 90%+ 的指代能被正确解析
- confirm-again-agent 触发率降低 50-70%
- 用户可以自然地连续对话
- 仅在真正缺少信息时才要求澄清

---

## 关键成功因素

1. ✅ **Context Data 必须有清晰的对话轮次结构**
2. ✅ **明确标记时间顺序（Turn N-2, N-1, N）**
3. ✅ **提取并维护 Active Entities**
4. ✅ **intent-agent 必须有明确的指代解析规则**
5. ✅ **测试驱动：准备充分的测试用例**

---

## 附录：n8n 工作流建议架构

```
[Webhook] 接收用户输入
    ↓
[Load User Profile] 加载长期画像
    ↓
[Load Dialogue History] 加载最近 3-5 轮对话
    ↓
[Extract Active Entities] 提取关键实体
    ↓
[Build Context Data] 构建结构化 Context Data
    ↓
[intent-agent] 意图识别（使用新的指代解析规则）
    ↓
[Route to Specialized Agent]
    ↓
[Save Dialogue Turn] 保存当前对话轮次到历史
    ↓
[Update Active Entities] 更新活跃实体
    ↓
[Return Response]
```

**关键节点**：
- **Save Dialogue Turn**: 每次对话后，必须保存完整的对话轮次（用户输入+agent回复+提取的实体）
- **Update Active Entities**: 维护一个"热实体池"，包含最近讨论的订单号、SKU、产品类别等
- **Build Context Data**: 将对话历史格式化为结构化的 Markdown 文本
