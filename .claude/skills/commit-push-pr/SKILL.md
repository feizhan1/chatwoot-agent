---
name: commit-push-pr
description: 一键完成 git commit、push 和创建 PR 的完整工作流
disable-model-invocation: true
allowed-tools: Bash(git*), Bash(gh*)
---

## 当前状态

- 当前分支: !`git branch --show-current`
- Git 状态: !`git status --short`
- 暂存和未暂存的变更: !`git diff HEAD`
- 最近的提交记录（用于匹配 commit 风格）: !`git log --oneline -10`

## 你的任务

基于上述变更，完成以下完整工作流：

### 1. 分支管理
- 如果当前在 main 或 master 分支，创建一个新的 feature 分支
- 分支命名建议：`feature/<简短描述>`（例如：`feature/add-statusline-config`）

### 2. 创建提交
- 分析所有变更（暂存和未暂存的）
- 参考最近的提交记录，匹配仓库的 commit message 风格
- 暂存相关文件（使用 `git add`）
  - ⚠️ **避免暂存敏感文件**：.env, credentials.json, *.key, *.pem
- 创建提交，commit message 格式：
  ```
  <简短标题>（不超过 70 字符）

  <可选的详细描述>

  Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
  ```
- 使用 HEREDOC 格式传递 commit message

### 3. 推送到远程
- 如果是新分支，使用 `git push -u origin <branch-name>`
- 如果已有远程分支，使用 `git push`

### 4. 创建 Pull Request
- 使用 `gh pr create` 命令
- 分析**整个分支**的所有提交（从 main 分支分叉点到当前 HEAD）
  - 运行：`git log main...HEAD --oneline`
  - 运行：`git diff main...HEAD`
- PR 描述格式：
  ```markdown
  ## Summary
  - <变更要点 1>
  - <变更要点 2>
  - <变更要点 3>

  ## Test plan
  - [ ] <测试项 1>
  - [ ] <测试项 2>
  - [ ] <测试项 3>

  🤖 Generated with [Claude Code](https://claude.com/claude-code)
  ```
- 使用 HEREDOC 格式传递 PR body

### 5. 返回结果
- 提交成功后，运行 `git status` 验证
- 显示创建的 PR URL

## 重要约束

1. **并行执行**：尽可能在单个响应中并行调用所有独立的 git 命令
2. **顺序执行**：有依赖关系的命令必须使用 `&&` 串联执行
   - 例如：`git add . && git commit -m "..." && git push`
3. **安全检查**：
   - 推送前验证变更是否合理
   - 避免提交敏感文件
   - 如果发现异常（如未预期的大量删除），先询问用户
4. **Git 安全协议**：
   - ❌ 不使用 `--force`、`--hard`、`--no-verify` 等危险选项
   - ❌ 不修改 git config
   - ✅ 使用 `-u` 标志设置上游分支
5. **错误处理**：
   - 如果 `gh pr create` 失败，检查：
     - `gh` 是否已安装并认证（`gh auth status`）
     - 是否有远程仓库
   - 如果 commit 失败（如 pre-commit hook 错误），修复问题后**创建新提交**，不使用 `--amend`

## 示例输出

执行成功后，你应该显示类似的信息：

```
✅ 已创建并切换到分支：feature/add-commit-push-pr-skill
✅ 已暂存 1 个文件
✅ 已创建提交：新增 commit-push-pr skill
✅ 已推送到远程：origin/feature/add-commit-push-pr-skill
✅ PR 已创建：https://github.com/user/repo/pull/123

完成！你可以访问上述 PR 链接进行审查。
```

## 使用方法

```bash
# 修改代码后，直接运行：
/commit-push-pr

# 或者带参数（可选，用于自定义 commit message）：
/commit-push-pr "feat: 添加新功能"
```

## 需求

- Git 已安装并配置
- GitHub CLI (`gh`) 已安装并认证：`gh auth login`
- 仓库有 origin 远程分支
- 当前目录是 git 仓库

---

**注意**：此 skill 会自动完成整个 git 工作流，请确保在运行前已经：
1. 完成代码修改和测试
2. 确认变更符合预期
3. 准备好创建 PR

如果只想提交而不创建 PR，可以使用 `/commit` 命令（如果可用）。
