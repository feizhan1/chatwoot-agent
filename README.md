# AI Reply Agent - 自动翻译系统

## 📖 项目简介

AI 智能客服代理系统，包含多个专业化 Agent，支持产品查询、订单管理、业务咨询等功能。

**特色功能**：提示词自动翻译系统 - 修改中文提示词时自动生成英文版本。

---

## 🚀 快速开始

### 1. 安装自动翻译系统

```bash
# 运行一键设置脚本
./scripts/setup-translation.sh
```

系统会引导您：
1. 创建配置文件
2. 输入 Anthropic API Key（[获取地址](https://console.anthropic.com/settings/keys)）
3. 验证配置

### 2. 使用方法

#### 自动模式（推荐）⭐

修改任何 `system-prompt.md` 或 `user-prompt.md` 后，直接提交：

```bash
# 修改提示词文件
vim production-agent/system-prompt.md

# 提交时自动翻译
git add .
git commit -m "更新产品查询提示词"

# 系统会自动：
# 1. 检测修改的文件
# 2. 翻译为英文
# 3. 生成 .en.md 文件
# 4. 添加到本次提交
```

#### 手动翻译单个文件

```bash
./scripts/translate-prompt.sh production-agent/system-prompt.md
```

#### 批量翻译所有文件

```bash
./scripts/batch-translate.sh
```

---

## 📂 项目结构

```
ai-reply-agent/
├── scripts/                          # 自动化脚本
│   ├── setup-translation.sh          # 一键设置脚本
│   ├── translate-prompt.sh           # 核心翻译脚本
│   ├── batch-translate.sh            # 批量翻译脚本
│   ├── translation-config.env        # 配置文件（包含 API Key）
│   └── translation-config.env.example # 配置模板
│
├── production-agent/                 # 产品查询代理
│   ├── system-prompt.md              # 系统提示词（中文）
│   ├── system-prompt.en.md           # 系统提示词（英文，自动生成）
│   ├── user-prompt.md                # 用户提示词（中文）
│   └── user-prompt.en.md             # 用户提示词（英文，自动生成）
│
├── order-agent/                      # 订单查询代理
├── business-consulting-agent/        # 业务咨询代理
├── language-detection-agent/         # 语言检测代理
├── rewrite-reply-agent/              # 回复改写代理
├── confirm-again-agent/              # 二次确认代理
├── error-handle-agent/               # 错误处理代理
├── no-clear-intent-agent/            # 未明确意图代理
├── handling-error-in-generating-suggestions/ # 错误提示翻译
└── intent-agent/                     # 意图识别代理（核心路由）
```

---

## 🔧 配置说明

### API Key 配置

配置文件位置：`scripts/translation-config.env`

```bash
# Anthropic API Key（必填）
ANTHROPIC_API_KEY=sk-ant-xxxxx

# 使用的模型（可选）
MODEL=claude-sonnet-4-5-20250929

# 最大 tokens（可选）
MAX_TOKENS=8000
```

### Git Hook 工作原理

当您运行 `git commit` 时：

1. **Pre-commit Hook** 被触发
2. 检测暂存区中的 `*-prompt.md` 文件
3. 调用 `translate-prompt.sh` 进行翻译
4. 生成对应的 `.en.md` 文件
5. 自动添加到本次提交

---

## 📝 翻译规则

系统会严格遵守以下规则：

### ✅ 保持不变的内容

- XML 标签名称：`<session_metadata>`, `<user_query>` 等
- 模板变量：`{{ $('language_detection_agent')... }}`
- 字段名/键名：`Login Status`, `Channel`, `iso_code` 等
- 意图枚举值：`query_product_data`, `handoff` 等
- URL 链接
- 专有名词：`TVCMALL`, `TVC Assistant`, `MOQ`, `SKU` 等
- Markdown 格式标记
- 换行符 `\n\n`

### 🌐 翻译的内容

- 自然语言描述
- 章节标题
- 用户话术示例
- 固定回复模板的文字内容

### 术语对照表

| 中文 | 英文 |
|------|------|
| 角色与身份 | Role & Identity |
| 核心目标 | Core Goals |
| 上下文优先级与逻辑 | Context Priority & Logic |
| 工具失败处理 | Tool Failure Handling |
| 语言策略 | Language Policy |
| 输出模板 | Output Templates |
| 场景处理规则 | Scenario Handling Rules |
| 语气与约束 | Tone & Constraints |

---

## 💡 常见问题

### Q: 如何跳过自动翻译？

```bash
git commit --no-verify -m "临时提交，跳过翻译"
```

### Q: 翻译失败怎么办？

1. 检查 API Key 是否正确
2. 检查网络连接
3. 查看错误信息
4. 手动运行翻译脚本调试：
   ```bash
   ./scripts/translate-prompt.sh <文件路径>
   ```

### Q: 是否需要将 .en.md 文件提交到仓库？

根据需求选择：
- **推荐**：提交 `.en.md` 文件，方便国际化和代码审查
- **可选**：在 `.gitignore` 中忽略 `*.en.md`，仅保留中文版本

### Q: 可以自定义翻译模型吗？

可以！在 `scripts/translation-config.env` 中修改：
```bash
MODEL=claude-opus-4-5-20251101  # 使用更强大的 Opus 模型
```

### Q: 翻译效果不理想怎么办？

1. 检查原文是否清晰规范
2. 调整翻译系统提示词（在 `scripts/translate-prompt.sh` 中的 `TRANSLATION_SYSTEM_PROMPT`）
3. 尝试使用更强大的模型（如 Opus）

---

## 🛠️ 高级用法

### 自定义翻译逻辑

编辑 `scripts/translate-prompt.sh` 中的 `TRANSLATION_SYSTEM_PROMPT` 变量，添加您的特殊要求。

### 集成到 CI/CD

```yaml
# .github/workflows/translate.yml
name: Auto Translate Prompts

on:
  push:
    paths:
      - '**/*-prompt.md'
      - '!**/*.en.md'

jobs:
  translate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Install dependencies
        run: sudo apt-get install -y jq curl
      - name: Translate
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
        run: ./scripts/batch-translate.sh
      - name: Commit changes
        run: |
          git config user.name "GitHub Actions"
          git config user.email "actions@github.com"
          git add "**/*.en.md"
          git commit -m "Auto-translate prompts to English" || true
          git push
```

---

## 📜 许可证

本项目仅供内部使用。

---

## 🙋 支持

遇到问题？
1. 查看本 README 的常见问题部分
2. 检查 `scripts/` 目录下的脚本注释
3. 联系项目维护者

---

**最后更新**: 2026-01-20
# chatwoot-agent
