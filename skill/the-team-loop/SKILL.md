---
name: the-team-loop
description: Coordinate two AI development teams on one repository through explicit ownership, short status reports, merge trains, tree certificates, and owner decisions.
license: MIT
compatibility: GitHub CLI, Git, Bash; optional BMAD
metadata:
  version: 1.0.0
---

# The Team Loop

Use this skill when two cooperating teams or agents work in one repository. Replace `Team A` and `Team B` with the configured names. The Owner is a human and is the authority for priority, merge, deploy, freeze, and policy decisions.

## Onboarding: five-minute setup

1. Copy this skill into the target repository and install the adapter for the active agent tool.
2. Copy `templates/team-loop.yml` to `.team-loop.yml`; set team names and `gate_command`.
3. Run `scripts/setup-labels.sh --repo OWNER/REPO`.
4. Have the Owner create a pinned coordination issue and one issue labelled `ready`.
5. Each team reads this file, claims at most one item, and uses the configured status header.

## Roles

- **Owner:** creates or promotes ready work; posts direct `Owner:` decisions in their own words; authorizes merges and deploys, except inside a written mandate with scope and UTC end time.
- **Team A / Team B:** build, test, review, claim, hand off, and report. Use separate GitHub identities when available.
- **Reviewer (optional):** performs a fresh-context review. Require it for configured risk paths or categories.

## Loop states

`backlog` -> `ready` -> `in-progress` -> `blocked` or `needs-owner` -> implementation PR -> `ready-for-owner` -> merged -> `deployed`.

- `backlog` is not claimable. Batch low-severity backlog work weekly for owner promotion.
- `ready` authorizes implementation, tests, and opening a PR. It never authorizes merge or deploy.
- On closing an issue, remove stale state labels such as `in-progress`, `ready`, `blocked`, and `needs-owner`.

## Claim protocol

1. Re-read labels immediately before acting. Do not claim `in-progress`, `blocked`, or non-`ready` work.
2. Run `scripts/claim.sh --repo OWNER/REPO --issue N --team "Team A" --plan "short plan"`.
3. The script adds `in-progress` and a team label, posts the claim, then rechecks state. If it loses a race, it backs off.
4. Keep work in progress at or below `wip_limit` per team. Finish, hand off, or explicitly block an item before claiming another.
5. For `team:any`, the earliest valid claim comment wins; the other team backs off. Do not resolve a tie by duplicate implementation.

## Comments and communication

Every team comment begins on its first line with:

```text
Status: <state> | Team: <configured team> | <short context>
```

Post only a claim with plan, review verdict, gate result, hand-off, question, owner-facing escalation, agreement, or release report. Do not post started, queued, still waiting, re-armed, or other ceremony comments. Keep ordinary comments to five short lines; place evidence in the PR description or collapsed details.

Only the Owner writes `Owner:` decisions. Teams must link or ask for a direct owner comment, never relay one as authority.

## Labels and routing

Use the labels in `reference/labels.md`. An unassigned ready issue defaults to Team A unless configuration says otherwise. `team:any` enables either team to claim. While idle, help the other team in this order: requested reviews, train preparation or rebasing, then weekly backlog batches. Do not conduct an open-ended bug sweep without an Owner request.

## Review, train, gate, certificate

1. Each PR runs light, focused checks and receives the review tier required by its risk.
2. A reviewer labels complete PRs `ready-for-owner`.
3. The train runner gathers reviewed PRs available at that moment. It runs:

   ```bash
   scripts/train.sh --repo OWNER/REPO --name train-YYYYMMDD-N PR_NUMBER...
   ```

4. `train.sh` adds `train-running` to every included PR, records the base and heads, performs a clash screen, constructs a temporary merge result, and invokes `gate.sh` once.
5. `gate.sh` keys the certificate to `git rev-parse HEAD^{tree}`. A matching existing certificate is successful evidence unless `--force` is used.
6. If the base or a PR head changes, or the screen/gate fails, the train is invalid. Remove or split the offending PRs, then rebuild the train. Do not merge unrelated work while `train-running` holds the train.
7. After direct owner approval or an active mandate, run `train.sh` again with `--merge --owner-authorization "Owner: ..."` to merge the recorded PR heads in order. It refuses if the base or a head changed, and verifies the protected branch's tree after every merge.

## Deploy, freeze, hold, and pause

- Deploy only the configured protected branch and only with a matching tree certificate, unless the Owner supplies a recorded exception.
- Produce one deployment report for the release. Label shipped PRs and issues `deployed`; link them to the one report rather than duplicating it.
- `freeze` stops new merges and deploys. Treat failed label reads as frozen for irreversible actions.
- A train hold blocks merges outside that train until the train exits.
- On pause, stop claims, trains, merges, and deploys. The Owner posts a restart list that names the items allowed to resume. Re-check labels, PR heads, base, and certificates before restart.

## Escalation and mandates

Use `needs-owner` when a product, security, legal, release, or ambiguous ownership decision blocks work. State the observed behavior, options, recommendation, and deadline if one exists. Continue independent work.

A mandate must state its exact scope and UTC expiration, for example:

```text
Owner: Team A may merge and deploy reviewed documentation PRs 41 and 42 until 2026-05-01T18:00:00Z.
```

Anything outside that scope or after expiry requires a fresh direct decision.

## Retrospective

At least weekly, run `scripts/scorecard.sh` and discuss the definitions in `reference/metrics.md`. Improve one measurable bottleneck at a time. Review gate runs per merged PR, claim latency, cycle time, queue net change, mean batch size, certified share, and change-failure rate.

Read `reference/rules.md` for the normative numbered rules and `reference/comment-templates.md` before posting status.
