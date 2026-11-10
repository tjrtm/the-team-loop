# Claude Code

Install into a repository:

```bash
./install.sh --tool claude --target ../my-repo
```

This creates `.claude/skills/the-team-loop/SKILL.md` and a short Claude instruction snippet. Reference that snippet from an existing `CLAUDE.md` if the repository already has one; do not overwrite project-specific instructions.

Claude Code agents should read the skill before claiming work or preparing a train. Keep the owner as the authority for merges and deploys.
