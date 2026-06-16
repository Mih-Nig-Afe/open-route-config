# Open Route Config — Continue + OpenRouter

Workspace template for running [Continue](https://continue.dev) as a Cursor-level AI coding agent powered by [OpenRouter](https://openrouter.ai) free models.

## Models

| Model | Role |
|-------|------|
| DeepSeek R1 (free) | Reasoning / planning |
| DeepSeek Chat (free) | General coding |
| Qwen3 Coder (free) | Primary dev / agent |
| Llama 3.3 70B (free) | Fast assistant |
| OpenRouter Auto | Smart routing fallback |

## Quick setup

1. Install the **Continue** extension in Cursor (`continue.continue`).
2. Export your OpenRouter key (never commit it):

```bash
export OPENROUTER_API_KEY="your-key-here"
```

3. Run the installer:

```bash
chmod +x setup.sh
./setup.sh
```

4. Open this folder in Cursor. Continue should focus automatically (Cmd+L opens chat if not).
5. In Continue, switch to **Agent** mode and pick **Qwen Coder (Best for Dev)**.

## Agent behavior

- Full workspace context (file, code, folder, codebase, terminal)
- Multi-file edits via Agent mode
- System rules: analyze → plan → execute → verify
- Tool use enabled on all OpenRouter models

## Files

- `continue/config.yaml` — shareable config template (uses `${OPENROUTER_API_KEY}`)
- `.continue/rules/agent.md` — autonomous agent instructions
- `.vscode/settings.json` — Continue + auto-task settings
- `.vscode/tasks.json` — focuses Continue when workspace opens
- `setup.sh` — copies config to `~/.continue/` on your machine

## Security

Do **not** commit API keys. Use `setup.sh` or set `OPENROUTER_API_KEY` in your shell profile. Rotate any key that was ever pasted into chat.

## Reload config

After editing config: Continue sidebar → config dropdown → **Reload Config**.
