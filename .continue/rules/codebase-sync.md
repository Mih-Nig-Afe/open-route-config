---
name: Always Fresh Codebase Context
alwaysApply: true
---

## Every prompt must use fresh codebase state

The codebase index updates automatically on:
- IDE open / project start
- git pull, merge, or branch switch
- file save (including AI edits)

**You must still re-query context on every user message** because:
- The index may have updated since your last reply
- Conversation history is NOT a substitute for current code
- The user expects answers based on the latest files, not stale memory

### Required behavior (every prompt)

1. Start by querying @codebase (or reading relevant files) for the user's topic
2. If the task involves editing, also scan @folder for affected modules
3. If git just changed (pull/branch), treat ALL prior context as invalid
4. After you edit files, re-read changed files before claiming success

### Never

- Answer architecture questions from memory without querying the repo
- Assume file contents match an earlier message in the chat
- Skip context gathering because "you already looked at this"
