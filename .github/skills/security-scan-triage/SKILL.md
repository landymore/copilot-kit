---
name: security-scan-triage
description: "Triage code scanning, Dependabot, and secret scanning alerts without exposing secrets. Use when reviewing security alerts, Dependabot pull requests, or code-scanning results."
---

# Security scan triage

Triage open alerts. Do not dismiss, close, or suppress an alert unless the user explicitly asks, and only with a written reason.

## Load alerts

```bash
gh api --paginate "/repos/{owner}/{repo}/dependabot/alerts?state=open"
gh api --paginate "/repos/{owner}/{repo}/code-scanning/alerts?state=open"
gh api --paginate "/repos/{owner}/{repo}/secret-scanning/alerts?state=open"
```

`gh` fills `{owner}` and `{repo}` from the current repository. If the API returns 403 or 404, report the missing permission and stop. Do not invent alerts.

For one Dependabot pull request, read that advisory instead of every open alert.

## Rules

- Never print secret values, raw matches, or tokens. Record the alert number, secret type, and state only.
- Do not call a secret a false positive because it looks like a sample. Say what must be rotated if it may be real.
- Prefer an upgrade or a code fix over an exception.
- An exception needs an owner, a reason, and an expiry. Do not open one with no end date.
- Do not grant yourself extra security permissions to make the API succeed.

## Classify

- **Fix now** — reachable, exploitable, or a valid secret
- **Fix soon** — real, but not on a sensitive path
- **Needs owner** — cannot tell from the repo
- **Likely noise** — only with evidence, such as a withdrawn advisory, an unused dependency, or a test fixture that is not a credential

## Output

A short table: source, alert or pull request, package or rule, classification, next action.

Then the single highest-priority fix. State which alert sources you could not read.
