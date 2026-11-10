# A worked day: two teams, one sample service

This example uses a generic web service with Team A and Team B. The owner has configured a gate command and a WIP limit of two per team.

## Morning intake

The owner files three issues:

| Issue | Labels | Result |
|---|---|---|
| Improve error message | `ready`, `team:any`, `severity:low` | Either team may claim. |
| Add audit record | `ready`, `team:b`, `severity:medium` | Team B work. |
| Investigate rare visual mismatch | `backlog`, `severity:low` | Not claimable today. |

Team A claims the error-message issue:

```text
Status: claimed | Team: Team A | Issue [copy-improvement]
Plan: update copy, add a focused test, and open a PR.
Checks: repository test command for the affected package.
Dependency: none.
```

Team B sees that the audit-record issue is assigned to it and claims it. Neither team touches the backlog issue.

## Review and train

Team A opens the copy PR. Team B opens the audit PR. Both run focused checks. The audit change touches a configured risk path, so Team A gives it a fuller review. Both PRs become `ready-for-owner`.

The train runner starts:

```bash
skill/the-team-loop/scripts/train.sh \
  --repo example/service \
  --name 2026-05-01-1 \
  --gate-command "make test" \
  <PR_NUMBER_1> <PR_NUMBER_2>
```

The script adds `train-running` to both PRs. Its clash screen sees no shared files, makes a temporary merge result, and runs `make test` once. The result is a certificate for the merged tree.

```text
Status: tested-green | Team: Team A | train 2026-05-01-1 tree 6f3a91c
Gate: make test passed.
Certificate: .team-loop/certificates/6f3a91c...
Next: owner merge decision required.
```

## Owner action and deployment

The owner posts directly:

```text
Owner: merge the recorded copy and audit pull requests in train order and deploy the resulting main tree today.
```

The authorized team merges the recorded heads in order, verifies the final tree equals the certified tree, deploys the protected branch, and posts one release report. Both PRs receive `deployed` and link to that report.

## Afternoon pause

The owner applies `freeze` before a planned event. Teams stop starting trains, merging, and deploying. They may still document evidence and review. Later the owner posts:

```text
Owner: restart list: the named urgent pull request only, after a fresh gate on its current main merge result.
```

The teams verify the current head and base, build a new one-PR train, gate its tree, and resume only the named item.

## Weekly retrospective

The teams run the scorecard. They observe one gate for two merged PRs, low claim latency, and no change failure. They retain the workflow and move the visual-mismatch backlog issue into a weekly batch for owner prioritization.
