# Contributing

Thank you for improving the Team Loop.

## Scope

Keep this repository universal. Do not add customer data, hostnames, credentials, internal paths, proprietary workflows, or assumptions about a programming language or deployment platform.

## Changes

1. Open an issue describing the behavior, evidence, and compatibility impact.
2. Keep documentation and scripts aligned. Protocol changes update `SKILL.md`, relevant reference files, and README diagrams when needed.
3. Shell scripts must remain Bash, Git, and GitHub CLI based; support `--dry-run`; and pass ShellCheck.
4. Run the local checks listed in the README.
5. Use concise, direct comments and preserve the human Owner authority boundary.

## Protocol design

Prefer a measurable rule over ceremony. A new rule should identify the failure it prevents, its observable state, and how it can be evaluated in the weekly scorecard. Avoid introducing background polling, stack-specific commands, or implicit authorization.

## Code of conduct

Be respectful, specific, and collaborative. Report security concerns privately through the repository's configured security channel when one exists.
