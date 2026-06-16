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

echo ""
echo "✔ Installed Pro Dev Agent config to ${CONTINUE_DIR}/"
echo "✔ Models: 13 free OpenRouter models with routing"
echo "✔ Rules: agent + routing + safety"
echo "✔ Prompts: /analyze-codebase, /plan-changes, /verify-changes"
echo ""
echo "Next: Restart Cursor → Agent mode → Qwen Coder Pro (Primary)"
echo "Reload: Continue sidebar → config gear → Reload Config"
