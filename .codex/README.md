# Codex Adapter

Codex uses `AGENTS.md`, `.agents/skills`, `.agents/workflows`, and `.codex/config.toml`.

`.agents/skills` is the canonical source for repository skills. Do not create a separate Codex-only skills source.

`.codex/config.toml` contains conservative profiles and defaults only. Keep permissions restricted and require confirmation before destructive operations, dependency installation, worktree deletion, or MCP write-tool execution.
