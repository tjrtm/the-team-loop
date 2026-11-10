#!/usr/bin/env bash
# Produce a lightweight weekly scorecard from GitHub metadata and certificates.
set -euo pipefail

repo=""
since=""
until=""
certificate_dir="${TEAM_LOOP_CERTIFICATE_DIR:-.team-loop/certificates}"
dry_run=0

usage() {
  printf '%s\n' "Usage: $0 --repo OWNER/REPO --since YYYY-MM-DD [--until YYYY-MM-DD] [--certificate-dir DIR] [--dry-run]"
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --repo) repo="${2:-}"; shift 2 ;;
    --since) since="${2:-}"; shift 2 ;;
    --until) until="${2:-}"; shift 2 ;;
    --certificate-dir) certificate_dir="${2:-}"; shift 2 ;;
    --dry-run) dry_run=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) usage >&2; exit 2 ;;
  esac
done
[ -n "$repo" ] && [ -n "$since" ] || { usage >&2; exit 2; }
until="${until:-$(date -u '+%Y-%m-%d')}"

if [ "$dry_run" -eq 1 ]; then
  printf 'Would query %s from %s through %s and inspect %s.\n' "$repo" "$since" "$until" "$certificate_dir"
  exit 0
fi

prs="$(gh pr list --repo "$repo" --state merged --search "merged:$since..$until" \
  --limit 1000 --json number,createdAt,mergedAt)"
issues_opened="$(gh issue list --repo "$repo" --state all --search "created:$since..$until" \
  --limit 1000 --json number)"
issues_closed="$(gh issue list --repo "$repo" --state closed --search "closed:$since..$until" \
  --limit 1000 --json number)"

merged_count="$(jq 'length' <<<"$prs")"
opened_count="$(jq 'length' <<<"$issues_opened")"
closed_count="$(jq 'length' <<<"$issues_closed")"
cycle="$(jq -r '
  [ .[] | ((.mergedAt | fromdateiso8601) - (.createdAt | fromdateiso8601)) / 60 ] | sort |
  if length == 0 then "n/a|n/a"
  else "\(.[length / 2 | floor])|\(.[((length - 1) * 0.9) | floor])" end
' <<<"$prs")"
median="${cycle%%|*}"
p90="${cycle#*|}"

certificates=0
if [ -d "$certificate_dir" ]; then
  certificates="$(find "$certificate_dir" -type f -name '[0-9a-f]*' -print | wc -l | tr -d ' ')"
fi
if [ "$merged_count" -gt 0 ]; then
  gates_per_pr="$(awk -v gates="$certificates" -v merged="$merged_count" 'BEGIN { printf "%.2f", gates / merged }')"
else
  gates_per_pr="n/a"
fi

printf '| Metric | Value | Method |\n'
printf '|---|---:|---|\n'
printf '| Merged PRs | %s | GitHub merged date search |\n' "$merged_count"
printf '| PR cycle median / p90 (minutes) | %s / %s | createdAt to mergedAt |\n' "$median" "$p90"
printf '| Issues opened / closed | %s / %s | GitHub created and closed date searches |\n' "$opened_count" "$closed_count"
printf '| Queue net change | %s | opened minus closed |\n' "$((opened_count - closed_count))"
printf '| Gate runs per merged PR | %s | local certificate files / merged PRs |\n' "$gates_per_pr"
printf '| Mean train size | manual | completed train manifests are retained locally |\n'
printf '| Claim latency | manual | query first Status: claimed comment per ready issue |\n'
printf '| Certified share | manual | compare merged tree hashes against certificates or shared evidence |\n'
printf '| Change-failure rate | manual | releases with rollback, incident, or hotfix / releases |\n'
