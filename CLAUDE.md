# CLAUDE.md

Follow `AGENTS.md` as the canonical repository instruction file.

When working here:

1. Inspect `docs/architecture/multiversion-strategy.md` before changing build files.
2. Inspect `docs/architecture/revit-api-boundary.md` before changing Revit API adapters.
3. Inspect `docs/architecture/runtime-ai.md` before changing AI or MCP behavior.
4. Prefer a short plan before implementation.
5. Summarize changed files, tests run, risks, and assumptions.

Never call Revit API from modeless UI, WebView2, MCP server, background threads, or AI gateway code. Route through `ExternalEvent`.
