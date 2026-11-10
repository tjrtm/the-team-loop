#!/usr/bin/env bash
# Create the portable label set. Requires gh authentication with label access.
set -euo pipefail

dry_run=0
repo=""

usage() {
  printf '%s\n' "Usage: $0 --repo OWNER/REPO [--dry-run]"
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
    --dry-run) dry_run=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) usage >&2; exit 2 ;;
  esac
done

[ -n "$repo" ] || { usage >&2; exit 2; }

create_label() {
  local name="$1" color="$2" description="$3"
  run gh label create "$name" --repo "$repo" --color "$color" \
    --description "$description" --force
}

create_label ready 0e8a16 "Owner-authorized implementation work"
create_label backlog cfd3d7 "Low-severity work waiting for a weekly batch"
create_label team:a 1d76db "Routed to Team A"
create_label team:b 5319e7 "Routed to Team B"
create_label team:any 6f42c1 "Either team may claim"
create_label in-progress fbca04 "Actively owned work"
create_label blocked b60205 "Waiting on a named dependency"
create_label needs-owner d93f0b "Waiting for an owner decision"
create_label ready-for-owner 0e8a16 "Review and gate evidence complete"
create_label train-running f9d0c4 "Included in a running merge train"
create_label freeze b60205 "Freeze merges and deploys"
create_label deployed 006b75 "Included in a reported deployment"
create_label severity:low cfd3d7 "Low severity"
create_label severity:medium fef2c0 "Medium severity"
create_label severity:high fbca04 "High severity"
create_label severity:critical b60205 "Critical severity"
