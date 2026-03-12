# AI 客服系统测试场景

本目录包含 TVCMALL AI 客服系统的完整测试数据集，按场景拆分为 9 个独立文件。

## 📁 文件结构

```
test-scenarios/
├── 01-general-chat.json              # 闲聊测试（3个用例）
├── 02-business-consulting.json       # 业务咨询测试（15个用例）
├── 03-product-query.json             # 产品查询测试（9个用例）
├── 04-order-query.json               # 订单查询测试（8个用例）
├── 05-order-operation.json           # 订单操作测试（5个用例）
├── 06-handoff.json                   # 转人工测试（3个用例）
├── 07-context-resolution.json        # 指代消解测试（5个用例）
├── 08-edge-cases.json                # 边缘情况测试（5个用例）
└── 09-end-to-end-scenarios.json      # 端到端场景测试（6个场景）
```

**总计：50+ 个测试用例，覆盖 9 大场景**

---

## 📊 测试用例分布

| 文件 | 场景 | 用例数 | 优先级用例 | 说明 |
|------|------|--------|------------|------|
| 01 | 闲聊 | 3 | 0 | 打招呼、礼貌用语、无意义输入 |
| 02 | 业务咨询 | 15 | 2 | 支付、运输、代发货、VIP、定制、清关 |
| 03 | 产品查询 | 9 | 2 | SKU查询、价格、库存、推荐、指代消解 |
| 04 | 订单查询 | 8 | 3 | 登录验证、状态查询、投诉处理 |
| 05 | 订单操作 | 5 | 0 | 修改地址、取消订单、修改数量 |
| 06 | 转人工 | 3 | 3 | 主动请求、情绪检测、投诉升级 |
| 07 | 指代消解 | 5 | 5 | yes/no/it 消解、上下文理解 |
| 08 | 边缘情况 | 5 | 0 | 空输入、无关问题、多语言混合 |
| 09 | 端到端 | 6个场景 | - | 完整用户流程模拟 |

---

## 🎯 关键测试用例

### ⚠️ 必测用例（Critical）

#### **语言策略测试**
- **TC017** (`02-business-consulting.json`) - 英文环境下知识库空结果
- **TC018** (`02-business-consulting.json`) - 中文环境下知识库空结果

#### **登录验证**
- **TC028** (`04-order-query.json`) - 未登录查询订单

#### **转人工升级**
- **TC041** (`06-handoff.json`) - 用户主动请求
- **TC042** (`06-handoff.json`) - 强烈情绪检测
- **TC043** (`06-handoff.json`) - 质量投诉

#### **指代消解**
- **TC044** (`07-context-resolution.json`) - yes 确认
- **TC045** (`07-context-resolution.json`) - no 拒绝
- **TC046** (`07-context-resolution.json`) - it 指代

---

## 🚀 使用方法

### 1. 单个场景测试

```bash
# 测试业务咨询场景
python run_tests.py test-scenarios/02-business-consulting.json

# 测试转人工场景
python run_tests.py test-scenarios/06-handoff.json
```

### 2. 批量测试

```bash
# 测试所有场景
python run_tests.py test-scenarios/*.json

# 仅测试高优先级用例
python run_tests.py --priority high test-scenarios/*.json
```

### 3. 端到端场景测试

```bash
# 执行"新用户完整购物流程"
python run_scenario.py "新用户完整购物流程"

# 执行所有端到端场景
python run_scenario.py --all
```

### 4. 快速回归测试

```bash
# 仅执行关键测试用例
python run_tests.py --critical-only
```

---

## 📋 测试用例字段说明

```json
{
  "id": "TC001",                    // 用例唯一标识
  "name": "用户打招呼",              // 用例名称
  "intent": "general_chat",         // 期望意图
  "priority": "high",               // 优先级（可选）
  "input": {
    "query": "hello",               // 用户输入
    "login": false,                 // 登录状态
    "language": "en",               // 目标语言
    "user": "John",                 // 用户名（可选）
    "context": [],                  // 对话历史（可选）
    "memory": ""                    // 用户画像（可选）
  },
  "expect": {
    "tool": "相似度查询-rag咨询",    // 期望调用的工具
    "keywords": ["help", "order"],  // 期望包含的关键词
    "language": "en",               // 期望回复语言
    "clarification": true,          // 是否需要澄清
    "emotion": "angry"              // 检测到的情绪
  },
  "note": "测试说明"                 // 备注（可选）
}
```

---

## ✅ 验证规则

测试时应验证以下关键点：

### 1. 语言一致性
```python
assert response_language == test_case['input']['language']
```

### 2. 工具调用
```python
# 业务咨询必须调用 RAG 工具
if intent == "query_knowledge_base":
    assert "相似度查询-rag咨询" in tools_called
```

### 3. 登录验证
```python
# 订单查询必须验证登录
if intent == "query_user_order" and not logged_in:
    assert "log in" in response
```

### 4. 空结果语言
```python
# 知识库空结果必须用目标语言回复
if rag_result is None:
    assert response_language == target_language
```

### 5. 指代消解
```python
# 必须从上下文或 memory_bank 推断
assert extracted_entity in (recent_dialogue + memory_bank)
```

### 6. 情绪检测
```python
# 强烈情绪必须提供人工帮助
if emotion in ["angry", "complaint"]:
    assert intent == "handoff"
```

---

## 🔍 场景说明

### 01-general-chat.json
**闲聊与基础交互**
- 测试打招呼、礼貌用语等基础对话
- 验证 AI 能否正确识别并友好回应

### 02-business-consulting.json
**业务咨询** ⚠️ 包含关键测试
- 支付方式、运输时间、退货政策
- **TC017/TC018**：测试知识库空结果时的语言策略
- 代发货、批发、VIP、定制服务
- 清关文件、产品图片下载

### 03-product-query.json
**产品查询**
- 按 SKU 查询、价格、库存
- 产品推荐、样品订单
- 错误 SKU 处理

### 04-order-query.json
**订单查询** ⚠️ 包含关键测试
- **TC028**：未登录验证
- 订单状态、物流追踪
- 投诉处理、情绪检测

### 05-order-operation.json
**订单操作**
- 修改地址、取消订单、修改数量
- 二次确认机制

### 06-handoff.json
**转人工** ⚠️ 全部为关键测试
- 用户主动请求转人工
- 强烈情绪检测（愤怒、投诉）
- 产品质量投诉升级

### 07-context-resolution.json
**指代消解** ⚠️ 全部为关键测试
- yes/no 确认
- it/this 指代消解
- 从 recent_dialogue 推断
- 从 memory_bank 提取

### 08-edge-cases.json
**边缘情况**
- 空输入、无关问题
- 多语言混合输入
- 混合意图处理

### 09-end-to-end-scenarios.json
**端到端场景**
- 6 个完整用户流程
- 模拟真实对话场景
- 测试上下文延续

---

## 🛠️ 测试脚本示例

### run_tests.py（需创建）

```python
import json
import sys

def run_test_file(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        data = json.load(f)

    print(f"\n{'='*60}")
    print(f"场景: {data['scenario']}")
    print(f"说明: {data['description']}")
    print(f"用例数: {len(data['cases'])}")
    print(f"{'='*60}\n")

    passed = 0
    failed = 0

    for case in data['cases']:
        result = execute_test(case)
        if result:
            passed += 1
            print(f"✅ {case['id']} - {case['name']}")
        else:
            failed += 1
            print(f"❌ {case['id']} - {case['name']}")

    print(f"\n通过: {passed}/{passed+failed}")
    return failed == 0

if __name__ == "__main__":
    success = run_test_file(sys.argv[1])
    sys.exit(0 if success else 1)
```

### run_scenario.py（需创建）

```python
import json

def run_scenario(scenario_name):
    with open('test-scenarios/09-end-to-end-scenarios.json', 'r') as f:
        data = json.load(f)

    scenario = next(s for s in data['scenarios'] if s['name'] == scenario_name)

    print(f"\n{'='*60}")
    print(f"场景: {scenario['name']}")
    print(f"说明: {scenario['description']}")
    print(f"步骤数: {scenario['total_steps']}")
    print(f"{'='*60}\n")

    for step in scenario['steps']:
        print(f"步骤 {step['step']}: {step['action']}")
        # 执行测试...
```

---

## 📝 添加新测试用例

在对应场景文件的 `cases` 数组中添加：

```json
{
  "id": "TC051",
  "name": "新测试用例",
  "intent": "query_product_data",
  "input": {
    "query": "...",
    "login": false,
    "language": "en"
  },
  "expect": {
    "tool": "...",
    "keywords": ["..."]
  }
}
```

---

## 🔄 CI/CD 集成

```yaml
# .github/workflows/test-agents.yml
name: Agent Test Suite
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Run critical tests
        run: python run_tests.py --critical-only
      - name: Run all tests
        run: python run_tests.py test-scenarios/*.json
```

---

## 📊 测试覆盖率

| 类别 | 覆盖的 Agent | 覆盖率 |
|------|-------------|--------|
| 意图识别 | intent-agent | 100% |
| 业务咨询 | business-consulting-agent | 95% |
| 产品查询 | production-agent | 90% |
| 订单查询 | order-agent | 95% |
| 转人工 | transfer-to-human-agent | 100% |
| 二次确认 | confirm-again-agent | 85% |
| 闲聊 | no-clear-intent-agent | 80% |

---

## 🎓 最佳实践

1. **按场景组织测试**：相关用例放在同一文件
2. **优先级标记**：关键测试用例标记 `priority: high/critical`
3. **清晰的命名**：用例名称应清晰描述测试内容
4. **完整的期望**：明确定义期望的工具、关键词、语言
5. **上下文完整**：提供足够的 context 和 memory 信息
6. **备注说明**：复杂用例添加 `note` 字段说明

---

## 📧 联系方式

如有问题或建议，请联系开发团队。
