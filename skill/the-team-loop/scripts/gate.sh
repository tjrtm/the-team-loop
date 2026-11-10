#!/usr/bin/env bash
# Run a configured gate once per Git tree and record a portable certificate.
set -euo pipefail

command_value="${TEAM_LOOP_GATE_COMMAND:-}"
certificate_dir="${TEAM_LOOP_CERTIFICATE_DIR:-.team-loop/certificates}"
force=0
dry_run=0

usage() {
  printf '%s\n' "Usage: $0 --command 'TEST COMMAND' [--certificate-dir DIR] [--force] [--dry-run]"
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --command) command_value="${2:-}"; shift 2 ;;
    --certificate-dir) certificate_dir="${2:-}"; shift 2 ;;
    --force) force=1; shift ;;
    --dry-run) dry_run=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) usage >&2; exit 2 ;;
  esac
done

[ -n "$command_value" ] || { printf '%s\n' "gate: --command or TEAM_LOOP_GATE_COMMAND is required" >&2; exit 2; }
tree="$(git rev-parse 'HEAD^{tree}')"
commit="$(git rev-parse HEAD)"
certificate="$certificate_dir/$tree"

if [ "$dry_run" -eq 1 ]; then
  printf 'Would run %s for tree %s and write %s\n' "$command_value" "$tree" "$certificate"
  exit 0
fi

if [ "$force" -eq 0 ] && [ -f "$certificate" ] && grep -qx "tree=$tree" "$certificate" \
  && grep -qx 'result=passed' "$certificate"; then
  printf 'RESULT: ALREADY CERTIFIED tree=%s certificate=%s\n' "$tree" "$certificate"
  exit 0
fi

if ! bash -c "$command_value"; then
  printf 'RESULT: FAILED tree=%s\n' "$tree" >&2
  exit 1
fi

umask 077
mkdir -p "$certificate_dir"
tmp="$(mktemp "$certificate_dir/.certificate.XXXXXX")"
{
  printf 'tree=%s\n' "$tree"
  printf 'commit=%s\n' "$commit"
  printf 'result=passed\n'
  printf 'tested_at=%s\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
  printf 'gate_command=%s\n' "$command_value"
} > "$tmp"
mv "$tmp" "$certificate"
printf 'RESULT: PASSED tree=%s certificate=%s\n' "$tree" "$certificate"
