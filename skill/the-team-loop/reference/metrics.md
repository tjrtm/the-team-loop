# Scorecard

Run:

```bash
scripts/scorecard.sh --repo OWNER/REPO --since 2026-01-01 --until 2026-01-08
```

The script uses GitHub CLI JSON output and reports a reproducible subset. It is intentionally conservative: labels, comments, and deployment failures vary by repository and may require a local reporting export.

| Metric | Definition | How to compute |
|---|---|---|
| Gate runs per merged PR | Full gate certificates in the window divided by merged PRs. | Count certificate files or published certificate notes; divide by `gh pr list --state merged`. |
| Claim latency | Median time from issue creation to first `Status: claimed` comment. | `gh issue list` plus `gh api repos/OWNER/REPO/issues/N/comments`; subtract timestamps. |
| PR cycle time | Median and p90 from PR creation to merge. | `gh pr list --state merged --json createdAt,mergedAt`. |
| Issue cycle time | Median and p90 from issue creation to close. | `gh issue list --state closed --json createdAt,closedAt`. |
| Queue net change | Issues opened minus issues closed in the window. | Compare `gh issue list` counts by timestamps. |
| Mean batch size | PRs in completed trains divided by train count. | Count `train-*.env` manifests, or train status comments. |
| Certified share | Merged PRs whose merged tree has a certificate divided by merged PRs. | Resolve merge commit trees with `git`, then check certificate store or notes. |
| Change-failure rate | Deployments needing rollback, incident, or hotfix divided by deployments. | Maintain a release label or incident link; do not infer failures from ordinary follow-ups. |

## Suggested weekly review

1. Post the scorecard to the coordination issue.
2. Compare against the previous window, noting work mix and freezes.
3. Select one constraint to improve, such as claim latency or gate reuse.
4. Record the expected result and check it at the next retrospective.

## Direct GitHub CLI examples

```bash
# Merged PR timestamps
gh pr list --repo OWNER/REPO --state merged --limit 100 \
  --json number,createdAt,mergedAt,mergeCommit

# Closed issues and timestamps
gh issue list --repo OWNER/REPO --state closed --limit 100 \
  --json number,createdAt,closedAt,labels

# Claim comments for one issue
gh api repos/OWNER/REPO/issues/123/comments --paginate \
  --jq '.[] | select(.body | startswith("Status: claimed")) | [.created_at, .body] | @tsv'
```
