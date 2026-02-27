# Repository Guidelines

## Project Structure & Modules
- Core agents live in peer directories (e.g., `order-agent-sop-executor/`, `product-agent-sop-router/`, `business-consulting-agent/`). Each contains prompt files and agent-specific assets.
- Shared automation scripts sit in `scripts/` (`setup-translation.sh`, `translate-prompt.sh`, `batch-translate.sh`, helper configs).
- Environment bundles: `env.json` (generated), `production.env` / `stage.env` for deployment-time values.
- Reference material and scenarios: `test-scenarios/`, `QUICKSTART.md`, `README.md`.

## Build, Test, and Development
- Install dependencies (Node ≥18): `npm install` (only `@openrouter/sdk` today).
- Set up translation toolchain: `./scripts/setup-translation.sh` (creates `scripts/translation-config.env` and verifies Anthropic key).
- Translate a single prompt manually: `./scripts/translate-prompt.sh <path/to/*-prompt.md>`.
- Translate all prompts: `./scripts/batch-translate.sh`.
- Commit-time automation: running `git commit` will auto-translate changed `*-prompt.md` files, generate `.en.md` mirrors, update `env.json`, and stage them.

## Coding Style & Naming
- Prompt files: Markdown with XML-like blocks; keep tags/handlebars untouched. English counterparts follow the same name plus `.en.md` suffix.
- Scripts: POSIX shell; prefer readable pipelines and set `-euo pipefail` when editing existing scripts.
- JSON: 2-space indentation; maintain key order when possible to minimize diffs.
- Directory and file names use kebab-case; new agents should follow `<agent-name>-agent` or `<domain>-agent-*` patterns.

## Testing Guidelines
- No formal test suite yet; before committing, ensure translation scripts succeed and `env.json` regenerates without errors.
- For JSON validation: `jq . env.json`.
- If adding code that hits external APIs, provide minimal mock data or comments for reviewers to reproduce.

## Commit & Pull Request Guidelines
- Commit messages: prefer concise Conventional Commit prefixes (`feat:`, `chore:`, `fix:`). Recent history also uses short "update" messages—aim for the clearer style.
- Let the pre-commit hook finish; avoid `--no-verify` unless debugging.
- PRs should summarize scope, list affected agents, and mention whether translation output (`*.en.md`, `env.json`) changed. Include reproduction steps or screenshots for UX-facing tweaks.

## Security & Configuration Tips
- Never commit real API keys; copy `scripts/translation-config.env.example` and keep secrets local.
- `env.json` is generated—review diffs for unintended prompt exposure before pushing.

## 请使用中文回复
