# Pro Dev Agent — Continue + OpenRouter

Cursor-style autonomous coding with [Continue](https://continue.dev) and free [OpenRouter](https://openrouter.ai) models.

## What this gives you (~80–90% of paid-agent UX)

- Multi-file Agent mode with tool use
- Full repo context (@codebase, folder, terminal)
- Model routing (reasoning vs coding vs explanation)
- Safety loop: analyze → plan → edit → verify
- Git guardrails: never auto-commit/push

## Models (all free tier)

| Role | Models |
|------|--------|
| 🧠 Reasoning / debug | DeepSeek R1, Nemotron Reasoning, Nemotron Super 120B |
| ⚙️ Coding / edits | Qwen Coder Pro, Qwen Next 80B, DeepSeek Chat, GPT-OSS 120B/20B, Dolphin Mistral |
| 💬 Explain / docs | Llama 3.3 70B, Llama 3.2 3B, Hermes 405B |
| 🔀 Fallback | OpenRouter Free Router |

**Default for Agent mode:** Qwen Coder Pro (Primary)

## Setup

```bash
cp .env.example .env          # add your key
chmod +x setup.sh && ./setup.sh
```

Or export the key:

```bash
export OPENROUTER_API_KEY="your-key"
./setup.sh
```

Open this folder in Cursor → allow automatic tasks → switch to **Agent** mode.

## Slash commands

Type `/` in Continue chat:

| Command | Purpose |
|---------|---------|
| `/analyze-codebase` | Scan repo before editing |
| `/plan-changes` | Plan diffs before execution |
| `/verify-changes` | Run post-edit verification |

## Recommended workflow

```
/analyze-codebase  →  describe task  →  /plan-changes  →  approve  →  edit  →  /verify-changes
```

## Files

```
.continue/
  config.yaml          ← committed (no secrets)
  rules/               ← agent, routing, safety
  prompts/             ← slash commands
.env                   ← your key (gitignored)
.env.example           ← template
setup.sh               ← installs to ~/.continue/
```

## Security

Never commit `.env` or API keys. Rotate any key exposed in chat.

## Reload config

Continue sidebar → config dropdown → **Reload Config**
