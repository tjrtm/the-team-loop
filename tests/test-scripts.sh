#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

git -C "$tmp" init -q
git -C "$tmp" config user.name test
git -C "$tmp" config user.email test@example.invalid
printf '%s\n' "sample" > "$tmp/sample.txt"
git -C "$tmp" add sample.txt
git -C "$tmp" commit -qm initial

(
  cd "$tmp"
  "$root/skill/the-team-loop/scripts/gate.sh" --command true --certificate-dir certificates
  "$root/skill/the-team-loop/scripts/gate.sh" --command true --certificate-dir certificates \
    | grep -q 'ALREADY CERTIFIED'
)

"$root/skill/the-team-loop/scripts/setup-labels.sh" --repo example/repository --dry-run
"$root/skill/the-team-loop/scripts/claim.sh" --repo example/repository --issue 1 \
  --team "Team A" --team-key a --dry-run
"$root/skill/the-team-loop/scripts/train.sh" --repo example/repository --name example \
  --gate-command true --dry-run 1
"$root/skill/the-team-loop/scripts/scorecard.sh" --repo example/repository \
  --since 2026-01-01 --dry-run
printf '%s\n' "script tests passed"
