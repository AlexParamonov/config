---
description: Explore codebase with intelligent chunking and parallel exploration
---

# Explore Orchestrator

You coordinate parallel file_explorer agents to explore codebases in manageable chunks.

## Input
{{args}}

---

## Workflow

### 1. Setup
- **Get commit:** `git rev-parse --short=7 HEAD`
- **Parse input:** `<topic>: <paths>` or just `<paths>` (auto-generate topic from paths)
- **Create folder:** `tasks/code-exploration/${topic}-${commit}-${timestamp}` (timestamp: `YYYYMMDD-HHMMSS`)

### 2. Discover Files
- Use glob `**/*` on each path to discover all files
- **Keep track of this list** (needed for gap detection in step 5)
- Build visual tree

### 3. Create Chunks
Group files into chunks (aim for 3-10 chunks):
- **Priority 1:** Semantic coherence (tests with implementation, controllers with routes)
- **Priority 2:** Max 50-80 files per chunk
- **Priority 3:** ~500KB source per chunk (flexible)

Output chunk definitions:
```json
[{"id": 0, "name": "auth-controller", "patterns": ["src/auth/*.ts"], "reasoning": "..."}]
```

### 4. Parallel Exploration
Spawn file_explorer agents for each chunk (all in one message):
```javascript
task({
  subagent_type: "file_explorer",
  description: `Explore chunk ${chunk.id}: ${chunk.name}`,
  prompt: `Explore files: ${chunk.patterns}. Output to: ${folder}/chunk-${chunk.id}-${chunk.name}.md`
})
```

### 5. Gap Detection
- Read all chunk files, extract explored files
- Compare against discovered files
- Log gaps, optionally explore missing files

### 6. Build Index
Create `manifest.json`:
```json
{
  "metadata": {"topic": "...", "commit": "...", "timestamp": "..."},
  "fileIndex": {"<file-path>": "chunk-<N>-<name>.md"},
  "chunks": [...],
  "summary": {"totalFiles": N, "totalChunks": N, "gaps": []}
}
```

Create `index.md`: Human-readable summary with chunk and file tables.

### 7. Report
```
✓ Exploration complete!
Topic: <topic> | Commit: <commit> | Chunks: <n> | Files: <total>
Result: ${folder}/
```

---

## Execute

Start with setup, then proceed through all steps. Show chunking reasoning.

**Key reminders:**
- Track discovered files for gap detection
- Spawn all explorers in parallel
- Build accurate file index in manifest.json

---

## Input

{{args}}
