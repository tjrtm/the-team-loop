#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
target="$(mktemp -d)"
trap 'rm -rf "$target"' EXIT

"$root/install.sh" --tool all --target "$target"

test -f "$target/.claude/skills/the-team-loop/SKILL.md"
test -f "$target/.claude/skills/the-team-loop/scripts/train.sh"
test -f "$target/.cursor/skills/the-team-loop/SKILL.md"
test -f "$target/.cursor/skills/the-team-loop/reference/rules.md"
test -f "$target/.cursor/rules/the-team-loop.mdc"
test -f "$target/.github/copilot-instructions.md"
test -f "$target/.github/instructions/the-team-loop.instructions.md"
test -f "$target/.github/copilot-coding-agent.md"
test -f "$target/the-team-loop/templates/team-loop.yml"
test -f "$target/.codex/skills/the-team-loop/SKILL.md"
test -f "$target/AGENTS.md"

"$root/install.sh" --tool all --target "$target"
test "$(grep -c '<!-- the-team-loop:start -->' "$target/AGENTS.md")" -eq 1
"$root/install.sh" --tool cursor --target "$target" --dry-run
generic_target="$target/generic"
mkdir "$generic_target"
"$root/install.sh" --tool generic --target "$generic_target"
test -f "$generic_target/the-team-loop/SKILL.md"
test -f "$generic_target/AGENTS.md"
printf '%s\n' "install test passed"
