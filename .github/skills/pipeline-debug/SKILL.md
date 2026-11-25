---
name: pipeline-debug
description: "Diagnose a failing GitHub Actions or CI run and propose the smallest fix. Use when a workflow, required check, or pipeline is failing."
---

# Pipeline debug

Find the failing step and the smallest fix. Do not rerun a job until you know why it failed.

## Gather

Use `gh`. It works the same on macOS and Windows.

```bash
gh run list --limit 15
gh run view <run-id> --json conclusion,status,name,url,displayTitle,event,headBranch,jobs
gh run view <run-id> --log-failed
```

Use the run id from the user's URL when they passed one. If `gh` is not authenticated, say so and stop. Do not scrape the website for logs.

## Diagnose

1. Name the failed job and step. Ignore green jobs.
2. Classify: product bug, test, workflow config, permission, dependency, runner image, or flake.
3. Read the workflow file and the recent diff that touched it.
4. If logs contain a secret, token, or connection string, redact it. Do not repeat the value.

## Cross-platform failures

- `windows-*` uses PowerShell unless `shell:` says otherwise. Bash syntax there is a common break.
- Case-sensitive paths pass on Ubuntu and fail on macOS or Windows.
- Do not assume `python` and `python3` are the same, or that every runner has `npm`.

## Fix

- Propose the smallest change that addresses the failed step.
- Do not disable the check, add `continue-on-error`, or pin a green SHA to hide the failure.
- If it looks flaky, say what a single rerun would prove and what to fix if it repeats.
- Edit the repo only when the user asked for a code change. Otherwise report the cause and the patch.

## Output

- Failed check, job, and step
- Cause in one or two sentences
- Evidence (command or redacted log line)
- Smallest fix
- What you did not verify
