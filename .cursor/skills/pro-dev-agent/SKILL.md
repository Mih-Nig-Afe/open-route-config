---
name: pro-dev-agent
description: >-
  Pro Dev Agent workflow for Cursor — analyze codebase, plan safe edits, verify
  results. Use when implementing features, debugging, or refactoring with
  OpenRouter models.
---

# Pro Dev Agent Workflow

Use this skill for structured autonomous coding in Cursor Agent mode.

## When to use

- Multi-file features or refactors
- Debugging with root-cause analysis
- Any task where wrong assumptions break the repo

## Workflow

1. **Analyze** — search/read codebase; map architecture and affected files
2. **Plan** — list changes, risks, verification steps; wait for approval on large work
3. **Execute** — minimal safe diffs only
4. **Verify** — run tests/build/linter if available
5. **Improve** — suggest follow-ups (do not auto-commit)

## Model picks (OpenRouter)

- Reasoning/debug → OR: DeepSeek R1 / Nemotron Reasoning
- Coding → OR: Qwen Coder Pro (default)
- Explain → OR: Llama 3.3 / Hermes 405B
- Fallback → OR: Free Router

## Git

Never commit or push unless the user explicitly asks.
