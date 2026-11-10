# Label contract

Create these labels with `scripts/setup-labels.sh`. Names may be overridden through `TEAM_LOOP_*_LABEL` environment variables where a script documents one.

| Label | Applies to | Meaning | Set by |
|---|---|---|---|
| `ready` | issue | Owner authorizes implementation work. | Owner |
| `backlog` | issue | Low-severity finding awaiting weekly batching. | Either team |
| `team:a` | issue/PR | Routed to Team A. | Owner or team |
| `team:b` | issue/PR | Routed to Team B. | Owner or team |
| `team:any` | issue | Either team may claim; first valid claim wins. | Owner or team |
| `in-progress` | issue | A team owns active work. | Claiming team |
| `blocked` | issue/PR | Waiting on a named dependency. | Either team |
| `needs-owner` | issue/PR | Waiting on a direct owner decision. | Either team |
| `ready-for-owner` | PR | Required review and gate evidence are complete. | Team |
| `train-running` | PR | Included in an active train; a merge hold. | Train runner |
| `freeze` | issue/PR/repository convention | Merges and deploys stop until explicit restart. | Owner |
| `deployed` | issue/PR | Included in a reported deployment. | Deploying team |
| `severity:low` | issue | Batch into backlog by default. | Either team |
| `severity:medium` | issue | Normal prioritization. | Either team |
| `severity:high` | issue | Owner should prioritize; may be ready when fix is clear. | Either team |
| `severity:critical` | issue | Urgent owner attention. | Either team |

Use labels as state, not repetitive comments. Clean temporary state labels when a PR merges or an issue closes.
