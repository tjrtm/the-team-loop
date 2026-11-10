# OpenAI Codex

For a repository-local installation:

```bash
./install.sh --tool codex --target ../my-repo
```

This writes `AGENTS.md` and `.codex/skills/the-team-loop/SKILL.md`. For a user-wide setup, copy the skill directory to `~/.codex/skills/the-team-loop/` and add the same concise instruction to the repository's `AGENTS.md`.

Repository-local instructions take precedence when they differ from a user-wide installation.
