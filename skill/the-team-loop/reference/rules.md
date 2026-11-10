# Normative rules

1. Every change is tracked by an issue or pull request.
2. Only an issue labelled `ready` begins ordinary implementation. `backlog` is not directly claimable.
3. Re-read labels immediately before claiming. Use the claim script or an equivalent atomic label-and-comment procedure.
4. A claim comment begins with `Status:` and includes a short plan. The fastest valid `team:any` claim wins.
5. Teams respect the configured WIP limit. Block, hand off, or finish before expanding active work.
6. Comments report a meaningful state transition only: claim, review, test, hand-off, question, decision, agreement, or deployment.
7. Teams never present relayed owner words as authority. Only the owner posts `Owner:` decisions.
8. Owner mandates name exact scope and an explicit UTC end time. A mandate cannot authorize unrelated work.
9. Low-severity findings receive `backlog`; batch them weekly. High, critical, security, or clearly actionable urgent work may be made `ready`.
10. Idle teams help reviews, train readiness, and backlog batching. They do not run an unbounded bug sweep without owner instruction.
11. Review depth follows risk: full independent review for configured risk paths or categories; concise fresh-context review otherwise.
12. Train only reviewed pull requests. Mark every included PR `train-running` before a full gate.
13. No unrelated merge moves the protected branch while a train is running. A changed base or head invalidates its evidence.
14. Run a quick clash screen before a multi-PR full gate. Split a train when overlap or failure identifies a suspect change.
15. A full gate certifies a Git tree hash. Reuse valid evidence for an identical tree; do not rerun solely because its commit ID differs.
16. Merge only after direct owner approval or an unexpired mandate, and verify the merged tree matches the certified tree.
17. Deploy only the protected branch with a matching certificate, except for a direct, recorded owner exception.
18. Publish exactly one detailed report per deployment. Link included issues and PRs instead of duplicating the report.
19. `freeze` stops irreversible actions. Pause is restarted only from an owner-provided explicit restart list.
20. Close work cleanly: remove stale state labels and record residual risk as fix-now, accepted rationale, or one non-duplicate issue.
21. Run a weekly retrospective from the scorecard; change process rules only with evidence and owner approval.
