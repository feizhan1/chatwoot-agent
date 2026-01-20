# 🚀 快速开始指南

## 一键设置（仅需一次）

```bash
./scripts/setup-translation.sh
```

按提示输入 Anthropic API Key（[获取地址](https://console.anthropic.com/settings/keys)）

---

## 使用方法

### 方式 1：自动翻译（推荐）⭐

```bash
# 1. 修改提示词
vim production-agent/system-prompt.md

# 2. 正常提交
git add .
git commit -m "更新提示词"

# ✨ 系统自动翻译并生成 .en.md 文件
```

### 方式 2：手动翻译单个文件

```bash
./scripts/translate-prompt.sh production-agent/system-prompt.md
```

### 方式 3：批量翻译所有文件

```bash
./scripts/batch-translate.sh
```

---

## 文件说明

| 文件 | 说明 | 是否手动编辑 |
|------|------|------------|
| `system-prompt.md` | 中文系统提示词 | ✅ 手动维护 |
| `system-prompt.en.md` | 英文系统提示词 | ❌ 自动生成 |
| `user-prompt.md` | 中文用户提示词 | ✅ 手动维护 |
| `user-prompt.en.md` | 英文用户提示词 | ❌ 自动生成 |

---

## 常用命令

```bash
# 测试系统是否正常
./scripts/test-translation.sh

# 跳过自动翻译（紧急情况）
git commit --no-verify -m "临时提交"

# 重新配置 API Key
./scripts/setup-translation.sh

# 查看详细文档
cat README.md
```

---

## 翻译规则

✅ **保持不变**: XML标签、模板变量、字段名、URL
🌐 **翻译内容**: 自然语言描述、章节标题、用户话术

---

## 需要帮助？

1. 运行测试脚本：`./scripts/test-translation.sh`
2. 查看完整文档：`README.md`
3. 检查脚本注释：`scripts/translate-prompt.sh`

---

**提示**: `.en.md` 文件由 AI 自动生成，请勿手动编辑。如需修改，请编辑中文版本后重新生成。
