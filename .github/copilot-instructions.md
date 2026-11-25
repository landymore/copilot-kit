# Copilot instructions

Always-on rules for this kit and for repositories that copy it. Keep this file short. Operating style lives in `AGENTS.md`.

## Naming and changes

- Use clear, specific names: kebab-case for workflow files, skills, and agents; descriptive job and resource names.
- Change only what the task needs. Do not rename or reformat unrelated files.
- Generated commit and PR text should say what changed and why, not "update files".

## GitHub Actions

- Set explicit `permissions`. Default to `contents: read`. Add write scopes only on the job that needs them.
- Pin third-party actions to a commit SHA. First-party `actions/*` may follow the repo's existing tag pattern.
- Set `timeout-minutes` on long jobs and `concurrency` on deploy jobs.
- Do not use `pull_request_target` with a checkout of pull request code.
- Do not hide failures with `continue-on-error` or by deleting a required check.
- `windows-*` runners use PowerShell by default. Set `shell:` when a step must be bash.

## Infrastructure as code

- Review Terraform and Bicep statically unless the user asks for a plan or what-if.
- Do not apply or destroy infrastructure unless the user explicitly asks.
- No secrets in `.tf`, `.bicep`, committed tfvars, or outputs. No committed state or plan files.
- Prefer OIDC or managed identity over long-lived keys. Call out public exposure and broad roles (`Owner`, `Contributor`, `*Admin`).
- Pin module sources. Flag replacements of data, network, or identity resources.

## Documentation

- Update the doc that a change makes wrong. Do not add new markdown files unless the user asks or the change is user-facing and undocumented.
- Do not invent build, test, or deploy commands. Quote commands that exist in the repo.
- Keep client names, tenant ids, and internal hostnames out of examples unless they are already public in that repo.

## Cross-platform

- Instructions and scripts must be valid on macOS and Windows, or name the OS they require.
- Use repo-relative paths. Avoid hardcoded home directories and drive letters.
- Do not assume case-sensitive paths or that `python` and `python3` are the same command.
