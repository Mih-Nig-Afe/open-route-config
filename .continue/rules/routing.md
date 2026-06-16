---
name: Model Routing Strategy
alwaysApply: true
---

## When to use which model

| Task | Model |
|------|-------|
| Debugging, root-cause analysis, architecture decisions | DeepSeek R1, Nemotron Reasoning |
| Writing or modifying code, refactors, multi-file edits | Qwen Coder Pro, Qwen Next 80B, GPT-OSS |
| Explaining code, docs, summaries | Llama 3.3, Hermes 405B |
| Rate-limited or unknown task | OpenRouter Free Router |

Default for Agent mode: **Qwen Coder Pro (Primary)**.

If the user does not specify a model, recommend switching to the best fit before starting large tasks.
