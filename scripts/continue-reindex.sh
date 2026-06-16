#!/usr/bin/env bash
# Trigger Continue codebase re-index after git events or IDE startup.
# Safe to run when Cursor is closed — index rebuilds automatically on next open.

set -euo pipefail

REPO_ROOT="${1:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
SYNC_FILE="${REPO_ROOT}/.continue/.last-sync"
CURSOR_BIN="/Applications/Cursor.app/Contents/Resources/app/bin/cursor"

mkdir -p "${REPO_ROOT}/.continue"
date -Iseconds > "${SYNC_FILE}"

# Cursor not running — Continue will full-index on next workspace open
if ! pgrep -xq "Cursor" 2>/dev/null; then
  exit 0
fi

# macOS: run Continue "Rebuild codebase index" via command palette
if [[ "$(uname)" == "Darwin" ]]; then
  osascript <<'APPLESCRIPT' 2>/dev/null || true
tell application "Cursor" to activate
delay 0.4
tell application "System Events"
  keystroke "p" using {command down, shift down}
  delay 0.7
  keystroke "Rebuild codebase index"
  delay 0.2
  keystroke return
end tell
APPLESCRIPT
  exit 0
fi

# Linux/Windows fallback: reopen workspace to nudge extension re-index
if [[ -x "${CURSOR_BIN}" ]]; then
  "${CURSOR_BIN}" -r "${REPO_ROOT}" >/dev/null 2>&1 || true
fi
