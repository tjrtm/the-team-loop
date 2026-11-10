#!/usr/bin/env bash
# Assemble a reviewed PR train, hold it, screen clashes, and gate one tree.
set -euo pipefail

repo=""
name=""
branch="${TEAM_LOOP_PROTECTED_BRANCH:-main}"
gate_command="${TEAM_LOOP_GATE_COMMAND:-}"
certificate_dir="${TEAM_LOOP_CERTIFICATE_DIR:-.team-loop/certificates}"
screen_command="${TEAM_LOOP_SCREEN_COMMAND:-}"
dry_run=0
merge_after_gate=0
owner_authorization=""
prs=()
held_prs=()

usage() {
  printf '%s\n' "Usage: $0 --repo OWNER/REPO --name NAME --gate-command 'COMMAND' [--merge --owner-authorization TEXT] PR [PR ...] [--dry-run]"
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --repo) repo="${2:-}"; shift 2 ;;
    --name) name="${2:-}"; shift 2 ;;
    --branch) branch="${2:-}"; shift 2 ;;
    --gate-command) gate_command="${2:-}"; shift 2 ;;
    --certificate-dir) certificate_dir="${2:-}"; shift 2 ;;
    --screen-command) screen_command="${2:-}"; shift 2 ;;
    --merge) merge_after_gate=1; shift ;;
    --owner-authorization) owner_authorization="${2:-}"; shift 2 ;;
    --dry-run) dry_run=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) prs+=("$1"); shift ;;
  esac
done

[ -n "$repo" ] && [ -n "$name" ] && [ -n "$gate_command" ] && [ "${#prs[@]}" -gt 0 ] || {
  usage >&2
  exit 2
}
[ "$merge_after_gate" -eq 0 ] || [ -n "$owner_authorization" ] || {
  printf '%s\n' "train: --merge requires recorded --owner-authorization text" >&2
  exit 2
}
case "$name" in *[!A-Za-z0-9._-]*|'') printf '%s\n' "train: unsafe name" >&2; exit 2 ;; esac
for pr in "${prs[@]}"; do
  case "$pr" in *[!0-9]*|'') printf '%s\n' "train: PR numbers must be numeric" >&2; exit 2 ;; esac
done

if [ "$dry_run" -eq 1 ]; then
  printf 'Would hold PRs: %s\n' "${prs[*]}"
  printf 'Would assemble train %s on origin/%s, screen clashes, and run one gate.\n' "$name" "$branch"
  if [ "$merge_after_gate" -eq 1 ]; then
    printf 'Would merge only after validating the recorded base, heads, and certificate.\n'
  fi
  exit 0
fi

root="$(git rev-parse --show-toplevel)"
state_dir="$root/.team-loop/trains"
mkdir -p "$state_dir"
manifest="$state_dir/$name.env"
case "$certificate_dir" in
  /*) ;;
  *) certificate_dir="$root/$certificate_dir" ;;
esac
mkdir -p "$certificate_dir"
certificate_dir="$(cd "$certificate_dir" && pwd)"
worktree="$(mktemp -d "${TMPDIR:-/tmp}/team-loop-train.XXXXXX")"
rmdir "$worktree"

release_holds() {
  local pr
  for pr in "${held_prs[@]}"; do
    gh pr edit "$pr" --repo "$repo" --remove-label train-running >/dev/null 2>&1 || true
  done
  git -C "$root" worktree remove --force "$worktree" >/dev/null 2>&1 || rm -rf "$worktree"
}
trap release_holds EXIT INT TERM

git fetch origin "$branch"
base="$(git rev-parse "origin/$branch")"
for pr in "${prs[@]}"; do
  gh pr view "$pr" --repo "$repo" --json state,baseRefName,headRefOid \
    --jq 'select(.state == "OPEN" and .baseRefName == "'"$branch"'") | .headRefOid' \
    > "$state_dir/$name.$pr.head"
  head_sha="$(cat "$state_dir/$name.$pr.head")"
  [ -n "$head_sha" ] || { printf 'train: PR #%s is not open against %s\n' "$pr" "$branch" >&2; exit 4; }
  gh pr edit "$pr" --repo "$repo" --add-label train-running >/dev/null
  held_prs+=("$pr")
done

git worktree add --detach "$worktree" "$base" >/dev/null
all_files="$state_dir/$name.files"
: > "$all_files"
for pr in "${prs[@]}"; do
  head_sha="$(cat "$state_dir/$name.$pr.head")"
  git -C "$worktree" fetch origin "$head_sha" >/dev/null 2>&1 || git -C "$worktree" fetch origin "refs/pull/$pr/head" >/dev/null
  git -C "$worktree" diff --name-only "$base...$head_sha" >> "$all_files"
done
overlap="$(sort "$all_files" | uniq -d || true)"
if [ -n "$overlap" ]; then
  printf 'train: clash screen found overlapping files:\n%s\n' "$overlap"
  if [ -n "$screen_command" ]; then
    (cd "$worktree" && bash -c "$screen_command")
  fi
fi

{
  printf 'name=%s\nbase=%s\n' "$name" "$base"
  for pr in "${prs[@]}"; do
    head_sha="$(cat "$state_dir/$name.$pr.head")"
    git -C "$worktree" -c user.name=team-loop -c user.email=team-loop@invalid \
      merge --no-ff --no-edit "$head_sha" >/dev/null
    printf 'pr_%s_head=%s\n' "$pr" "$head_sha"
    printf 'pr_%s_tree=%s\n' "$pr" "$(git -C "$worktree" rev-parse 'HEAD^{tree}')"
  done
  printf 'tree=%s\n' "$(git -C "$worktree" rev-parse 'HEAD^{tree}')"
} > "$manifest"

(cd "$worktree" && bash "$root/skill/the-team-loop/scripts/gate.sh" \
  --command "$gate_command" --certificate-dir "$certificate_dir")
if [ "$merge_after_gate" -eq 1 ]; then
  printf 'owner_authorization=%s\n' "$owner_authorization" >> "$manifest"
  git fetch origin "$branch"
  [ "$(git rev-parse "origin/$branch")" = "$base" ] || {
    printf '%s\n' "train: protected branch moved; refusing merge" >&2
    exit 5
  }
  for pr in "${prs[@]}"; do
    expected_head="$(cat "$state_dir/$name.$pr.head")"
    current_head="$(gh pr view "$pr" --repo "$repo" --json state,headRefOid \
      --jq 'select(.state == "OPEN") | .headRefOid')"
    [ "$current_head" = "$expected_head" ] || {
      printf 'train: PR #%s changed or closed; refusing merge\n' "$pr" >&2
      exit 5
    }
    gh pr merge "$pr" --repo "$repo" --merge
    git fetch origin "$branch"
    expected_tree="$(sed -n "s/^pr_${pr}_tree=//p" "$manifest")"
    actual_tree="$(git rev-parse "origin/$branch^{tree}")"
    [ "$actual_tree" = "$expected_tree" ] || {
      printf 'train: tree mismatch after PR #%s; stop and investigate\n' "$pr" >&2
      exit 6
    }
  done
  printf 'RESULT: TRAIN MERGED name=%s tree=%s\n' "$name" "$(git rev-parse "origin/$branch^{tree}")"
fi
printf 'RESULT: TRAIN PASSED name=%s manifest=%s\n' "$name" "$manifest"
