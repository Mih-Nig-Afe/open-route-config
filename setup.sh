#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONTINUE_DIR="${HOME}/.continue"
OPENROUTER_KEY="${OPENROUTER_API_KEY:-}"

if [[ -z "${OPENROUTER_KEY}" ]]; then
  read -r -s -p "Enter your OpenRouter API key: " OPENROUTER_KEY
  echo
fi

mkdir -p "${CONTINUE_DIR}/rules"
cp "${REPO_ROOT}/continue/config.yaml" "${CONTINUE_DIR}/config.yaml"
cp "${REPO_ROOT}/.continue/rules/agent.md" "${CONTINUE_DIR}/rules/agent.md"

# Replace env placeholder with the actual key for local use.
if [[ "$(uname)" == "Darwin" ]]; then
  sed -i '' "s|\${OPENROUTER_API_KEY}|${OPENROUTER_KEY}|g" "${CONTINUE_DIR}/config.yaml"
else
  sed -i "s|\${OPENROUTER_API_KEY}|${OPENROUTER_KEY}|g" "${CONTINUE_DIR}/config.yaml"
fi

# Persist key in shell profile if not already exported.
if ! grep -q 'OPENROUTER_API_KEY' "${HOME}/.zshrc" 2>/dev/null; then
  {
    echo ''
    echo '# OpenRouter API key for Continue AI'
    echo "export OPENROUTER_API_KEY=\"${OPENROUTER_KEY}\""
  } >> "${HOME}/.zshrc"
  echo "Added OPENROUTER_API_KEY to ~/.zshrc"
fi

echo "Continue config installed to ${CONTINUE_DIR}/config.yaml"
echo "Reload Continue in Cursor: open Continue chat → config gear → Reload Config"
echo "Or restart Cursor to pick up changes."
