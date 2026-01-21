# CLAUDE.md

本文件为 Claude Code (claude.ai/code) 在此代码库中工作时提供指导。

## 项目概述

这是一个为 TVCMALL 电商平台开发的 AI 智能客服代理系统。由 10+ 个专业化 agent 组成，处理客户交互的不同方面（产品查询、订单管理、业务咨询等）。

**核心特性**：
- 基于 n8n 的工作流编排
- 意图识别驱动的智能路由
- 使用 Claude API 的中文到英文提示词自动翻译系统
- 统一的占位符模板系统

## 系统架构

### 架构设计哲学

**"意图优先，专业分工"**

系统采用**基于意图识别的路由型多 Agent 架构**：
1. **单一入口**：所有请求通过 webhook 统一接入
2. **智能路由**：intent-agent 分析意图并分发到专业 agent
3. **专业分工**：每个 agent 专注一个领域，拥有独立工具集
4. **标准流程**：统一的处理流程（LLM → Tools → Parser）

### 数据流转路径

```
用户请求（Webhook/Telegram）
        ↓
[预处理] 提取 session_metadata, memory_bank, recent_dialogue
        ↓
[intent-agent] 意图识别与路由
        ↓
    ┌───┴───┬───────┬───────┬───────┬───────┐
    ↓       ↓       ↓       ↓       ↓       ↓
transfer  order  product business confirm  general
-to-human -agent  -agent  -agent   -again   -chat
        ↓
[OpenRouter LLM] 推理 + 工具调用
        ↓
[Structured Output Parser] 格式化输出
        ↓
[错误处理] error-handle-agent 兜底
        ↓
用户响应
```

### 核心组件

#### 1. Intent-Agent（路由中心）

**职责**：系统的"大脑"，负责意图识别和路由分发

**路由优先级**（从高到低）：
1. `handoff`（转人工）- 最高优先级，涉及投诉、强烈情绪
2. `query_user_order`（订单查询）- 私有数据，需验证登录
3. `query_product_data`（产品查询）- 实时产品数据
4. `query_knowledge_base`（知识库）- 公司政策、FAQ
5. `need_confirm_again`（二次确认）- 意图模糊时
6. `general_chat`（闲聊）- 兜底处理

**关键文件**：
- `intent-agent/system-prompt.md`（✅ 存在）
- `intent-agent/user-prompt.md`（❌ 缺失，建议补充）

#### 2. 六大专业 Agent

##### transfer-to-human-agent（转人工）
- **触发条件**：用户明确要求人工、投诉、强烈情绪
- **工具**：`handoff.tool2`
- **特点**：最高优先级，立即响应
- **无需工具调用**：直接返回转人工指令

##### order-agent（订单查询）
- **职责**：处理用户私有订单数据
- **工具集**：
  - `query_order_data`：查询订单状态
  - `query_logistics_xx`：物流追踪
  - `handoff.tool2`：必要时转人工
- **数据源**：OMS/CRM 系统
- **关键约束**：必须验证 `login_status`

##### production-agent（产品查询）
- **职责**：实时产品数据查询，系统中功能最复杂的 agent
- **工具集**（最多）：
  - `query_production_xx`：查询 SKU、规格、库存、价格
  - `query_knowledge_xx`：产品知识库
  - `相似度查询-rag推荐`：基于 RAG 的产品推荐
  - `相似图片查询`：以图搜图功能
- **个性化**：根据 `<memory_bank>` 中用户类型调整推荐
  - Dropshipper：强调无 MOQ、API 支持
  - Wholesaler：强调批量定价、定制化

##### business-consulting-agent（业务咨询）
- **职责**：公司政策、服务、物流、支付等通用信息
- **工具集**：
  - `相似度查询-rag咨询`：RAG 知识库检索
- **数据源**：静态知识库（公司政策、FAQ、服务说明）
- **特点**：纯知识检索，不涉及实时数据或私有信息

##### confirm-again-agent（二次确认）
- **职责**：处理意图模糊、信息不足的查询
- **行为**：生成澄清性问题，引导用户提供更多信息
- **示例**：
  - 用户："查一下我的订单" → "请问您能提供订单号吗？"
  - 用户："推荐个手机壳" → "您需要哪个手机型号的手机壳？"
- **无工具调用**：纯 LLM 生成澄清问题

##### no-clear-intent-agent（无明确意图）
- **职责**：处理闲聊、离题话题、社交对话
- **特点**：无工具调用，纯 LLM 对话
- **示例**："你好"、"天气真好"、"谢谢"

#### 3. 辅助 Agent

##### language-detection-agent（语言检测）
- **职责**：检测用户输入语言，返回语言名称和 ISO 代码
- **输出**：填充 `{target_language}` 和 `{language_code}`
- **在流程早期执行**：为后续 agent 提供语言信息

##### rewrite-reply-agent（回复润色）
- **职责**：在发送前润色 agent 生成的回复
- **输入**：`{draft_message}`, `{event_type}`, `{recent_dialogue}`
- **输出**：优化后的回复文本
- **用途**：统一语气、修正语法、增强友好度

##### error-handle-agent（错误处理）
- **职责**：作为系统的兜底层
- **触发条件**：上游 agent 失败、工具调用超时、解析错误
- **行为**：返回友好的错误提示，避免暴露技术细节

### 技术栈

#### LLM 服务
- **OpenRouter Chat Model**：
  - 统一的 LLM 接口，支持多提供商切换
  - 每个 agent 可配置不同模型（如 Sonnet、Opus）
  - 支持流式输出和工具调用

#### 工具层（Tools）
- **订单系统**：`query_order_data`, `query_logistics_xx`
- **产品系统**：`query_production_xx`, `query_knowledge_xx`
- **RAG 服务**：
  - `相似度查询-rag推荐`：产品推荐（向量检索）
  - `相似度查询-rag咨询`：业务咨询（知识库）
- **图片搜索**：`相似图片查询`（以图搜图）
- **人工转接**：`handoff.tool2`

#### 输出格式化
- **Structured Output Parser**：
  - 确保每个 agent 返回统一的 JSON 结构
  - 可能包含：`intent`, `message`, `next_action`, `metadata`

#### 工作流编排
- **n8n**：
  - 低代码工作流平台
  - 节点化配置，可视化编排
  - 支持环境变量和 webhook

### 提示词模板系统

**关键约定**：所有 agent 提示词使用**统一的占位符格式**：

```markdown
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
```

**标准占位符**：
- `{channel}`：用户所在渠道（telegram, web, whatsapp）
- `{login_status}`：登录状态（true/false）
- `{target_language}`：目标语言名称（"English", "中文"）
- `{language_code}`：ISO 语言代码（en, zh, es）
- `{memory_bank}`：用户长期画像（业务身份、偏好、历史）
- `{recent_dialogue}`：最近 3-5 轮对话历史
- `{user_query}`：当前用户输入

**特殊占位符**（仅特定 agent）：
- `{draft_message}`：待润色的草稿（rewrite-reply-agent）
- `{event_type}`：事件类型（rewrite-reply-agent）

**重要**：不要使用旧的 n8n 模板语法（如 `{{ $('NodeName').json.field }}`）。

### 双语提示词系统

每个 agent 有两个版本的提示词：
- `system-prompt.md` / `user-prompt.md`（中文，源文件）
- `system-prompt.en.md` / `user-prompt.en.md`（英文，自动生成）

**工作流**：
```
编辑 .md（中文）→ Git commit → 自动翻译 → 生成 .en.md → 生成 env.json
```

## 常用命令

### 翻译系统

**首次设置**：
```bash
./scripts/setup-translation.sh
```

**翻译单个文件**：
```bash
./scripts/translate-prompt.sh production-agent/system-prompt.md
```

**批量翻译所有文件**：
```bash
./scripts/batch-translate.sh
```

**提交时自动翻译**：
```bash
# 正常提交即可 - git pre-commit hook 会自动翻译
git add production-agent/system-prompt.md
git commit -m "优化产品查询提示词"

# Hook 自动执行：
# 1. 检测修改的 *-prompt.md 文件
# 2. 调用 Claude API 翻译为英文
# 3. 生成对应的 .en.md 文件
# 4. 调用 generate-env-json.sh
# 5. 添加到本次提交
```

**跳过自动翻译**：
```bash
git commit --no-verify -m "临时提交，跳过翻译"
```

### 环境配置

**生成 env.json**（用于 n8n 部署）：
```bash
./scripts/generate-env-json.sh
```

**env.json 结构**：
```json
{
  "stage": {
    "mem0_token": "...",
    "chatwoot_base_url": "...",
    "boss_api_key": "..."
  },
  "production": {
    "mem0_token": "...",
    "chatwoot_base_url": "...",
    "boss_api_key": "..."
  },
  "prompt": {
    "production-agent": {
      "system-prompt": "完整的英文提示词内容...",
      "user-prompt": "完整的英文提示词内容..."
    },
    "order-agent": { ... }
  }
}
```

**在 n8n 中使用**：
```javascript
// n8n 表达式示例
const systemPrompt = $env.prompt['production-agent']['system-prompt'];
const userPrompt = $env.prompt['production-agent']['user-prompt']
  .replace('{channel}', $('webhook').json.body.channel)
  .replace('{user_query}', $('Code').json.ask);
```

## 提示词开发工作流

### 修改提示词

1. **编辑中文版本**：
   ```bash
   # 始终编辑 .md 文件，不要编辑 .en.md
   vim production-agent/system-prompt.md
   ```

2. **保持占位符格式**：
   - ✅ 使用：`{channel}`, `{user_query}`
   - ❌ 避免：`{{ $('NodeName').json.field }}`

3. **保持 XML 结构**：
   - 标签名称精确：`<session_metadata>`, `<user_query>`
   - 翻译系统不会翻译标签名

4. **测试翻译**（可选）：
   ```bash
   ./scripts/translate-prompt.sh production-agent/system-prompt.md
   ```

5. **提交**：
   ```bash
   git add production-agent/system-prompt.md
   git commit -m "优化产品推荐逻辑"
   # 自动翻译、生成 env.json、添加到提交
   ```

### 翻译保留规则

翻译系统会**保留不变**：
- XML 标签名：`<session_metadata>`, `<user_query>`
- 占位符：`{channel}`, `{user_query}`
- 字段名：`Login Status`, `Channel`, `iso_code`
- 枚举值：`query_product_data`, `handoff`
- URL 链接
- 专有名词：`TVCMALL`, `TVC Assistant`, `MOQ`, `SKU`
- Markdown 格式：标题、列表、代码块

仅翻译**自然语言部分**：描述、说明、示例文本。

### 添加新 Agent

1. **创建目录**：
   ```bash
   mkdir new-agent
   ```

2. **创建提示词**（复制模板）：
   ```bash
   # 使用 no-clear-intent-agent 作为标准模板
   cp no-clear-intent-agent/system-prompt.md new-agent/
   cp no-clear-intent-agent/user-prompt.md new-agent/
   ```

3. **编辑提示词**：
   - 保持标准 XML 结构
   - 使用统一占位符
   - 定义 agent 的职责和工具

4. **批量翻译**：
   ```bash
   ./scripts/batch-translate.sh
   ```

5. **提交**：
   ```bash
   git add new-agent/
   git commit -m "添加新 agent: new-agent"
   # hook 会自动生成 env.json
   ```

6. **在 n8n 中配置**：
   - 添加新的 agent 节点
   - 在 intent-agent 中添加新意图路由
   - 配置工具调用（如需要）

## 部署流程

### 开发环境

1. **编辑提示词**：修改 `*-agent/*.md` 文件
2. **测试翻译**：`./scripts/translate-prompt.sh <file>`
3. **提交**：`git commit`（自动翻译 + 生成 env.json）
4. **推送**：`git push`

### 生产部署

1. **导出 env.json**：
   ```bash
   ./scripts/generate-env-json.sh
   scp env.json production-server:/path/to/n8n/
   ```

2. **在 n8n 中更新**：
   - 方式1：通过 n8n UI 导入环境变量
   - 方式2：使用 n8n CLI：`n8n import:credentials env.json`

3. **配置占位符映射**（在 n8n 工作流中）：
   ```javascript
   // 在每个 agent 节点的"Code"节点中
   const userPrompt = $env.prompt['agent-name']['user-prompt']
     .replace('{channel}', $('webhook').json.body.channel)
     .replace('{login_status}', $('Auth').json.isLogin)
     .replace('{user_query}', $('Input').json.message)
     .replace('{memory_bank}', $('Memory').json.profile)
     .replace('{recent_dialogue}', $('History').json.messages);
   ```

4. **测试工作流**：
   - 发送测试请求到 webhook
   - 验证每个 agent 的路由和响应
   - 检查工具调用是否正常

## Git Hooks

**Pre-commit hook**（`.git/hooks/pre-commit`）自动执行：

1. 检测暂存的 `*-prompt.md` 文件（排除 `.en.md`）
2. 调用 `translate-prompt.sh` 翻译每个文件
3. 将生成的 `.en.md` 添加到暂存区
4. 调用 `generate-env-json.sh`
5. 如果 `env.json` 有变化，添加到暂存区
6. 如果任何步骤失败，中止提交

**Hook 失败排查**：
```bash
# 检查 API key 配置
cat scripts/translation-config.env

# 手动测试翻译
./scripts/translate-prompt.sh production-agent/system-prompt.md

# 跳过 hook（不推荐）
git commit --no-verify -m "紧急修复"
```

## 配置文件

### 不要提交（包含敏感信息）
- `scripts/translation-config.env`（Anthropic API key）
- `.claude/settings.local.json`（本地 IDE 配置）
- `stage.env`, `production.env`（如果包含生产密钥）

### 可以提交
- `*.en.md` 文件（推荐，便于代码审查）
- `env.json`（先检查是否有敏感数据）
- 配置模板：`*.env.example`

### 敏感数据清单（确保不提交）
- API Keys：Anthropic, OpenRouter, Mem0
- 数据库凭证
- Webhook URLs（如果是私有的）
- Token 和密钥

## 调试和故障排查

### 提示词调试

**查看 agent 接收的实际输入**：
在 n8n 的 agent 节点前添加 Debug 节点，打印：
```javascript
{
  "system_prompt": $env.prompt['agent-name']['system-prompt'],
  "user_prompt": /* 替换占位符后的结果 */,
  "session_data": {
    "channel": $('webhook').json.body.channel,
    "login": $('Auth').json.isLogin
  }
}
```

**验证占位符替换**：
```bash
# 检查所有占位符是否使用正确格式
grep -r "\$(" *-agent/user-prompt.md
# 应该返回空（旧格式已全部替换）

# 检查标准占位符
grep -r "{user_query}" *-agent/user-prompt.md
```

### 翻译问题

**翻译失败**：
```bash
# 检查 API 配置
cat scripts/translation-config.env | grep ANTHROPIC_API_KEY

# 手动测试 API 连接
curl https://api.anthropic.com/v1/messages \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model":"claude-sonnet-4-5-20250929","max_tokens":100,"messages":[{"role":"user","content":"test"}]}'
```

**翻译质量问题**：
1. 检查原文是否清晰
2. 调整 `scripts/translate-prompt.sh` 中的 `TRANSLATION_SYSTEM_PROMPT`
3. 尝试更强大的模型（如 Opus）

### n8n 部署问题

**占位符未替换**：
- 检查 n8n 中的代码节点是否正确执行 `.replace()`
- 验证 `env.json` 是否成功导入
- 检查环境变量名称是否匹配

**工具调用失败**：
- 验证 API 端点配置
- 检查认证凭据
- 查看 n8n 执行日志

## 关键约定

1. **提示词修改**：
   - ✅ 始终编辑中文 `.md` 文件
   - ❌ 不要手动编辑 `.en.md`（自动生成）

2. **占位符格式**：
   - ✅ 使用 `{variable}`
   - ❌ 不用 `{{ $('NodeName').json.field }}`

3. **XML 结构**：
   - 保持标签名称精确
   - 翻译系统不会翻译标签

4. **Agent 路由**：
   - intent-agent 是唯一入口
   - 查看 `intent-agent/system-prompt.md` 了解路由逻辑
   - 优先级：handoff > 业务查询 > 确认 > 闲聊

5. **上下文优先级**：
   - `<memory_bank>`：用户长期画像
   - `<recent_dialogue>`：即时上下文
   - `<user_query>`：当前请求
   - 冲突时：recent_dialogue > memory_bank

6. **工具调用原则**：
   - 仅在需要外部数据时调用工具
   - 优先使用缓存（如适用）
   - 工具失败时有降级策略

7. **个性化策略**：
   - 从 `<memory_bank>` 提取用户类型
   - Dropshipper：强调无 MOQ、API
   - Wholesaler：强调批量、定制
   - 未知类型：提供通用信息

## 架构优势

1. ✅ **职责单一**：每个 agent 专注一个领域
2. ✅ **易于扩展**：添加新 agent 无需修改现有代码
3. ✅ **可维护性高**：提示词与代码分离
4. ✅ **国际化支持**：自动翻译系统
5. ✅ **版本控制**：所有提示词修改都有 Git 记录
6. ✅ **灵活路由**：intent-agent 集中管理路由逻辑
7. ✅ **标准化**：统一的输入输出格式
8. ✅ **个性化**：基于用户画像的动态响应

## 未来优化方向

基于当前架构，可以考虑的改进：

1. **Agent 协作**：
   - 当前是独立 agent，未来可支持多 agent 协同
   - 链式调用：confirm-again → production-agent

2. **缓存层**：
   - 高频查询结果缓存
   - 减少 API 调用成本

3. **监控与分析**：
   - 记录每个 agent 调用频率
   - 分析用户意图分布
   - 识别性能瓶颈

4. **A/B 测试**：
   - 不同 prompt 版本对比
   - 不同 LLM 模型效果评估

5. **补充 intent-agent user-prompt**：
   - 当前缺失，建议添加标准模板
   - 提高意图识别的一致性
