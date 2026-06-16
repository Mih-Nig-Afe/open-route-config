#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONTINUE_DIR="${HOME}/.continue"
ENV_FILE="${REPO_ROOT}/.env"

# Load .env if present
if [[ -f "${ENV_FILE}" ]]; then
  set -a
  # shellcheck disable=SC1090
  source "${ENV_FILE}"
  set +a
  echo "Loaded ${ENV_FILE}"
fi

OPENROUTER_KEY="${OPENROUTER_API_KEY:-}"

if [[ -z "${OPENROUTER_KEY}" || "${OPENROUTER_KEY}" == "your_openrouter_key_here" ]]; then
  read -r -s -p "Enter your OpenRouter API key: " OPENROUTER_KEY
  echo
fi

mkdir -p "${CONTINUE_DIR}/rules" "${CONTINUE_DIR}/prompts"
chmod +x "${REPO_ROOT}/scripts/continue-reindex.sh"
chmod +x "${REPO_ROOT}/.githooks/"* 2>/dev/null || true

cp "${REPO_ROOT}/.continue/config.yaml" "${CONTINUE_DIR}/config.yaml"
cp "${REPO_ROOT}/.continue/rules/"*.md "${CONTINUE_DIR}/rules/"
cp "${REPO_ROOT}/.continue/prompts/"*.md "${CONTINUE_DIR}/prompts/"

# Fix rule/prompt paths for global config (absolute home paths)
RULES_DIR="${CONTINUE_DIR}/rules"
PROMPTS_DIR="${CONTINUE_DIR}/prompts"
if [[ "$(uname)" == "Darwin" ]]; then
  sed -i '' "s|\${OPENROUTER_API_KEY}|${OPENROUTER_KEY}|g" "${CONTINUE_DIR}/config.yaml"
  sed -i '' "s|file://.continue/rules/|file://${RULES_DIR}/|g" "${CONTINUE_DIR}/config.yaml"
  sed -i '' "s|file://.continue/prompts/|file://${PROMPTS_DIR}/|g" "${CONTINUE_DIR}/config.yaml"
else
  sed -i "s|\${OPENROUTER_API_KEY}|${OPENROUTER_KEY}|g" "${CONTINUE_DIR}/config.yaml"
  sed -i "s|file://.continue/rules/|file://${RULES_DIR}/|g" "${CONTINUE_DIR}/config.yaml"
  sed -i "s|file://.continue/prompts/|file://${PROMPTS_DIR}/|g" "${CONTINUE_DIR}/config.yaml"
fi

# Create .env from example if missing
if [[ ! -f "${ENV_FILE}" ]]; then
  cp "${REPO_ROOT}/.env.example" "${ENV_FILE}"
  if [[ "$(uname)" == "Darwin" ]]; then
    sed -i '' "s|your_openrouter_key_here|${OPENROUTER_KEY}|g" "${ENV_FILE}"
  else
    sed -i "s|your_openrouter_key_here|${OPENROUTER_KEY}|g" "${ENV_FILE}"
  fi
  echo "Created ${ENV_FILE} (gitignored — not committed)"
fi

# Install git hooks for auto re-index on pull/merge/checkout
if git -C "${REPO_ROOT}" rev-parse --git-dir >/dev/null 2>&1; then
  git -C "${REPO_ROOT}" config core.hooksPath .githooks
  echo "✔ Git hooks installed (post-merge, post-checkout → reindex)"
fi

echo ""
echo "✔ Installed Pro Dev Agent config to ${CONTINUE_DIR}/"
echo "✔ Codebase embedder: transformers.js (local, no API key)"
echo "✔ Auto re-index: IDE open, git pull, branch switch, file save"
echo "✔ Rules: fresh @codebase context on every prompt"
echo ""
echo "Next: Restart Cursor → allow automatic tasks → Agent mode → Qwen Coder Pro"
echo "Reload: Continue sidebar → config gear → Reload Config"
echo ""
echo "Configuring Cursor OpenRouter (Agent chat)..."
python3 "${REPO_ROOT}/scripts/setup-cursor-openrouter.py" || {
  echo "Cursor setup skipped or failed — run: python3 scripts/setup-cursor-openrouter.py"
}
