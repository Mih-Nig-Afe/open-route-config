---
name: Change Safety Loop
alwaysApply: true
---

## Safety rules

1. **Plan before edit** — list every file to touch and why
2. **Minimal diffs** — smallest change that solves the problem
3. **No drive-by refactors** — do not rename or reformat unrelated code
4. **Verify after change** — run tests, linter, or build when available
5. **Self-correct** — if verification fails, debug and fix before declaring done

## Destructive actions

- Ask before deleting files, dropping tables, or removing features
- Ask before changing public APIs or config that affects deployment
- Never run `rm -rf`, `git reset --hard`, or force-push without explicit user approval

## Terminal use

- Run commands only when needed for verification or setup
- Prefer read-only inspection before mutating commands
