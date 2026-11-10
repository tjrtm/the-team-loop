# Comment templates

Replace bracketed text. Put `Status:` on the first line and do not add ceremony replies.

## Claim

```text
Status: claimed | Team: [Team A] | Issue #[N]
Plan: [one or two concrete steps].
Checks: [focused checks].
Dependency: [none or named dependency].
```

## Review

```text
Status: review-approved | Team: [Team B] | PR #[N] @ [short-sha]
Verdict: [approved / changes requested].
Findings: [severity and concise actionable detail, if any].
```

## Gate

```text
Status: tested-green | Team: [Team A] | train [name] tree [short-tree]
Gate: [configured command] passed.
Certificate: [certificate path or shared evidence].
Next: owner merge decision required.
```

## Hand-off or block

```text
Status: blocked | Team: [Team A] | Issue #[N]
Waiting on: [specific dependency or question].
Unblocked work: [what continues now].
```

## Owner escalation

```text
Status: needs-owner | Team: [Team B] | Issue #[N]
Decision: [behavior that needs choosing].
Options: [A] ...; [B] ...
Recommendation: [option and reason].
```

## Mandate record

```text
Status: mandate-recorded | Team: [Team A]
Owner: [owner's exact words, including scope and UTC end time].
```

## Release report

```text
Status: deployed | Team: [Team B] | [branch] @ [short-sha]
Previous: [short-sha or unknown]. Gate: [certificate evidence].
Smoke: [result]. Included PRs: [links].
Report: [single canonical release report link].
```
