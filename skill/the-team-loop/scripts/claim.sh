#!/usr/bin/env bash
# Claim a ready GitHub issue with a label-first, comment-second protocol.
set -euo pipefail

repo=""
issue=""
team=""
team_key=""
plan=""
dry_run=0

usage() {
  printf '%s\n' "Usage: $0 --repo OWNER/REPO --issue N --team NAME --team-key a|b [--plan TEXT] [--dry-run]"
}

run() {
  if [ "$dry_run" -eq 1 ]; then
    printf '+'
    printf ' %q' "$@"
    printf '\n'
  else
    "$@"
  fi
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --repo) repo="${2:-}"; shift 2 ;;
    --issue) issue="${2:-}"; shift 2 ;;
    --team) team="${2:-}"; shift 2 ;;
    --team-key) team_key="${2:-}"; shift 2 ;;
    --plan) plan="${2:-}"; shift 2 ;;
    --dry-run) dry_run=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) usage >&2; exit 2 ;;
  esac
done

case "$issue" in ''|*[!0-9]*) usage >&2; exit 2 ;; esac
case "$team_key" in a|b) ;; *) usage >&2; exit 2 ;; esac
[ -n "$repo" ] && [ -n "$team" ] || { usage >&2; exit 2; }

if [ "$dry_run" -eq 1 ]; then
  printf 'Would claim issue #%s for %s with team:%s and in-progress.\n' "$issue" "$team" "$team_key"
  exit 0
fi

labels="$(gh issue view "$issue" --repo "$repo" --json labels --jq '.labels[].name')"
case "
$labels
" in
  *$'\n'in-progress$'\n'*|*$'\n'blocked$'\n'*)
    printf 'SKIP: issue #%s is already unavailable\n' "$issue"
    exit 4
    ;;
esac
case "
$labels
" in
  *$'\n'ready$'\n'*) ;;
  *)
    printf 'SKIP: issue #%s is not ready\n' "$issue"
    exit 4
    ;;
esac

run gh issue edit "$issue" --repo "$repo" --add-label "in-progress" --add-label "team:$team_key"
body="$(printf 'Status: claimed | Team: %s | Issue #%s\nPlan: %s' "$team" "$issue" "${plan:-implement, validate, and open a pull request}")"
run gh issue comment "$issue" --repo "$repo" --body "$body"

labels_after="$(gh issue view "$issue" --repo "$repo" --json labels --jq '.labels[].name')"
case "
$labels_after
" in
  *$'\n'in-progress$'\n'*) printf 'WON: issue #%s claimed by %s\n' "$issue" "$team" ;;
  *) printf 'LOST: issue #%s state changed during claim\n' "$issue"; exit 3 ;;
esac
