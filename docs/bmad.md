# BMAD mapping

The Team Loop is a coordination layer, not a replacement for BMAD. It applies the same repository-level controls whether work is represented as BMAD stories or ordinary GitHub issues.

| Team Loop | BMAD equivalent | Without BMAD |
|---|---|---|
| `ready` issue | Approved story ready for implementation | Issue with acceptance criteria |
| Claim | Developer takes a story | Team takes an issue |
| Plan comment | Story implementation plan | Short issue plan |
| Risk review | Architecture or code-review checkpoint | Fresh-context reviewer |
| Merge train | Sprint integration batch | Reviewed PR batch |
| Tree certificate | Integration test evidence | Configured repository gate |
| Owner decision | Product-owner decision | Human owner comment |
| Weekly scorecard | Retrospective | Repository retrospective |

## With BMAD

Keep BMAD artifacts as the source of truth inside an active epic. Link the relevant issue or story from the PR, preserve the Team Loop labels, and use the loop for cross-team routing, merge holds, gate evidence, and owner authority. The owner can make a group of approved stories ready together; teams still claim individual work within their WIP limits.

Do not use a coordination discussion as a substitute for an owner decision. Record the owner decision directly on the GitHub issue or PR, then update the BMAD artifact if that project treats it as canonical.

## Without BMAD

Use GitHub issues, pull requests, labels, and the supplied templates. The required minimum is:

1. A short outcome and acceptance criteria in each issue.
2. `ready` only when the owner wants implementation to begin.
3. A concise claim comment and an `in-progress` label.
4. A PR that links the issue and records checks.
5. A reviewed train gate and tree certificate before merge or deploy.

No command syntax, agent hierarchy, or planning framework is required.
