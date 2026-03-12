---
name: git-push-dual-remote
description: 在当前 Git 仓库配置并执行“一次 push 同步两个仓库”。当用户要求“同时推送到两个远程 / 主仓库+GitHub 镜像 / 一次推送双仓同步”时使用。默认将 origin 的 push 同步到当前 origin 仓库与 https://github.com/feizhan1/chatwoot-agent.git，也支持按用户提供的镜像地址覆盖。
---

# Git 双仓同步推送技能

## 概览
用于在当前仓库把 `origin` 配置为双 push 目标，然后通过一次 `git push origin <branch>` 同时推送到两个仓库。

## 执行步骤
1. 识别目标仓库与分支。
- 默认镜像仓库：`https://github.com/feizhan1/chatwoot-agent.git`
- 若用户提供其他镜像地址，优先使用用户地址。
- 若用户未指定分支，使用 `git branch --show-current`。

2. 检查当前远程配置。
- 运行：
  - `git remote -v`
  - `git remote get-url origin`
  - `git remote get-url --push --all origin`

3. 配置 `origin` 的双 push URL。
- 先将主仓库设为唯一主 push 地址，避免旧配置干扰：
  - `primary_url="$(git remote get-url origin)"`
  - `git remote set-url --push origin "$primary_url"`
- 再追加镜像仓库（仅当不存在时）：
  - `git remote get-url --push --all origin | rg -F "$mirror_url" >/dev/null || git remote set-url --push --add origin "$mirror_url"`

4. 执行一次推送。
- `git push origin <branch>`

5. 校验并回传结果。
- 运行：
  - `git remote get-url --push --all origin`
  - `git status --short`
- 明确回传：
  - 推送分支
  - 两个 push URL
  - push 是否成功
  - 是否有残留未提交改动

## 故障处理
- 鉴权失败：提示用户分别完成两个远程仓库的认证（SSH key 或 token）。
- 分支不存在：提示先创建或切换到目标分支后重试。
- `origin` 不存在：提示用户先配置 `origin`，或明确指定要操作的远程名再执行。

## 回退到单仓推送
当用户要求取消双仓同步时：
- `primary_url="$(git remote get-url origin)"`
- `git remote set-url --push origin "$primary_url"`
- 校验：`git remote get-url --push --all origin`

## 安全提示
- 推送到公开仓库前，先检查敏感信息（如 token、密钥、内网地址）是否已移除或脱敏。
