#!/usr/bin/env bash
# Install the-team-loop instructions into a target repository.
set -euo pipefail

tool=""
target=""
dry_run=0

usage() {
  printf '%s\n' "Usage: $0 --tool claude|cursor|copilot|codex|generic|all --target PATH [--dry-run]"
}

copy_file() {
  local source="$1" destination="$2"
  if [ "$dry_run" -eq 1 ]; then
    printf 'Would copy %s -> %s\n' "$source" "$destination"
    return
  fi
  mkdir -p "$(dirname "$destination")"
  cp "$source" "$destination"
  printf 'Installed %s\n' "$destination"
}

copy_tree() {
  local source="$1" destination="$2"
  if [ "$dry_run" -eq 1 ]; then
    printf 'Would copy directory %s -> %s\n' "$source" "$destination"
    return
  fi
  mkdir -p "$destination"
  cp -R "$source/." "$destination"
  printf 'Installed %s\n' "$destination"
}

write_file() {
  local destination="$1" content="$2"
  if [ "$dry_run" -eq 1 ]; then
    printf 'Would write %s\n' "$destination"
    return
  fi
  mkdir -p "$(dirname "$destination")"
  printf '%s\n' "$content" > "$destination"
  printf 'Installed %s\n' "$destination"
}

write_agents() {
  local destination="$1" content="$2"
  if [ "$dry_run" -eq 1 ]; then
    printf 'Would add the-team-loop instructions to %s\n' "$destination"
    return
  fi
  mkdir -p "$(dirname "$destination")"
  if [ -f "$destination" ] && grep -q '<!-- the-team-loop:start -->' "$destination"; then
    printf 'Already installed %s\n' "$destination"
    return
  fi
  if [ ! -f "$destination" ]; then
    printf '# Agent instructions\n\n' > "$destination"
  fi
  printf '\n<!-- the-team-loop:start -->\n%s\n<!-- the-team-loop:end -->\n' "$content" >> "$destination"
  printf 'Installed %s\n' "$destination"
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --tool) tool="${2:-}"; shift 2 ;;
    --target) target="${2:-}"; shift 2 ;;
    --dry-run) dry_run=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) usage >&2; exit 2 ;;
  esac
done

case "$tool" in claude|cursor|copilot|codex|generic|all) ;; *) usage >&2; exit 2 ;; esac
[ -n "$target" ] || { usage >&2; exit 2; }
[ -d "$target" ] || { printf 'Target does not exist: %s\n' "$target" >&2; exit 2; }

root="$(cd "$(dirname "$0")" && pwd)"
target="$(cd "$target" && pwd)"
skill_source="$root/skill/the-team-loop"

install_claude() {
  copy_tree "$skill_source" "$target/.claude/skills/the-team-loop"
  write_file "$target/.claude/CLAUDE-the-team-loop.md" "Read .claude/skills/the-team-loop/SKILL.md. Two teams use explicit labels and concise Status comments; only the human Owner makes merge/deploy decisions unless a scoped, expiring mandate exists."
}

install_cursor() {
  copy_tree "$skill_source" "$target/.cursor/skills/the-team-loop"
  write_file "$target/.cursor/rules/the-team-loop.mdc" "---"$'\n'"description: Two-team repository coordination"$'\n'"alwaysApply: true"$'\n'"---"$'\n\n'"Read .cursor/skills/the-team-loop/SKILL.md. Two teams use explicit labels and concise Status comments; only the human Owner makes merge/deploy decisions unless a scoped, expiring mandate exists."
}

install_copilot() {
  copy_tree "$skill_source" "$target/the-team-loop"
  write_file "$target/.github/copilot-instructions.md" "Read the-team-loop/SKILL.md. Two teams use explicit labels and concise Status comments; only the human Owner makes merge/deploy decisions unless a scoped, expiring mandate exists."
  write_file "$target/.github/instructions/the-team-loop.instructions.md" "---"$'\n'"applyTo: \"**\""$'\n'"---"$'\n\n'"Read the-team-loop/SKILL.md. Two teams use explicit labels and concise Status comments; only the human Owner makes merge/deploy decisions unless a scoped, expiring mandate exists."
  write_file "$target/.github/copilot-coding-agent.md" "Coding agents: read the-team-loop/SKILL.md before claiming, reviewing, or preparing a merge train."
}

install_codex() {
  copy_tree "$skill_source" "$target/.codex/skills/the-team-loop"
  write_agents "$target/AGENTS.md" "Read .codex/skills/the-team-loop/SKILL.md. Two teams use explicit labels and concise Status comments; only the human Owner makes merge/deploy decisions unless a scoped, expiring mandate exists."
}

install_generic() {
  copy_tree "$skill_source" "$target/the-team-loop"
  write_agents "$target/AGENTS.md" "Read the-team-loop/SKILL.md. Two teams use explicit labels and concise Status comments; only the human Owner makes merge/deploy decisions unless a scoped, expiring mandate exists."
}

case "$tool" in
  claude) install_claude ;;
  cursor) install_cursor ;;
  copilot) install_copilot ;;
  codex) install_codex ;;
  generic) install_generic ;;
  all) install_claude; install_cursor; install_copilot; install_codex ;;
esac
