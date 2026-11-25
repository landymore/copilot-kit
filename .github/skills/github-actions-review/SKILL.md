---
name: github-actions-review
description: "Review GitHub Actions workflow changes for permissions, pinning, secrets handling, and CI hygiene. Use when editing or reviewing .github/workflows, composite actions, reusable workflows, or workflow permissions."
---

# GitHub Actions review

Review workflow changes. Do not weaken a check to make a run pass.

## Scope

1. List changed files under `.github/workflows/` and `.github/actions/`, plus any `action.yml`.
2. Read the diff and the surrounding job, not only the changed lines.
3. Note the runner OS before recommending a shell command.

## Check

- **Permissions.** Prefer an explicit top-level `permissions` block, usually `contents: read`. Add write scopes only on the job that needs them. Flag a missing block and `permissions: write-all`.
- **Triggers.** Flag `pull_request_target` combined with a checkout of pull request code, and untrusted code that can read secrets.
- **Pinning.** Pin third-party actions to a commit SHA. A major tag is acceptable for first-party `actions/*` only when the repo already uses that pattern. Flag floating tags and `curl | sh` installs.
- **Secrets.** Secrets come from environments or GitHub secrets, never from committed files. Flag steps that echo secrets, and deploy jobs with no environment.
- **Hygiene.** `timeout-minutes` on long jobs. `concurrency` on deploy jobs. Do not pass secrets to untrusted fork workflows.
- **Cross-platform.** `windows-*` defaults to PowerShell. Do not recommend bash-only syntax there unless `shell: bash` is set. Quote paths.

## Output

Lead with merge risk: block, fix before merge, or no issues.

Then list:

- Severity: high, medium, or low
- Location: `path:line` only when you have read that line
- The issue and the smallest fix

If the change is fine, say so and list what you checked. Do not invent line numbers.
