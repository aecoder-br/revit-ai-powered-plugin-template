# CLAUDE.md

Follow `AGENTS.md` as the canonical repository instruction file.

When working here:

1. Inspect `docs/architecture/multiversion-strategy.md` before changing build files.
2. Inspect `docs/architecture/revit-api-boundary.md` before changing Revit API adapters.
3. Inspect `docs/architecture/runtime-ai.md` before changing AI or MCP behavior.
4. Inspect `docs/ai/ai-tooling-setup.md` before changing Claude Code, Cursor, Codex, or Copilot adapters.
5. Prefer a short plan before implementation.
6. Summarize changed files, tests run, risks, and assumptions.

Claude Code subagents live in `.claude/agents`. Claude skill mirrors live in `.claude/skills` and are generated from `.agents/skills` by:

```powershell
./scripts/setup-ai-tools.ps1 -Tools Claude -Mode Copy -Validate
```

Do not edit mirrored skill content as the source of truth. Update `.agents/skills` first, then regenerate mirrors.

For parallel work, use `.agents/workflows/branch-isolation.md` and the agent worktree scripts before assigning overlapping tasks. Do not let two agents edit the same path unless ownership is explicitly handed off.

Never call Revit API from modeless UI, WebView2, MCP server, background threads, or AI gateway code. Route through `ExternalEvent`.
