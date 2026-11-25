# Agent instructions

Guidance for Copilot CLI, VS Code, and Copilot cloud agent. Prefer this file for how to work. Put repo facts and checklists in `.github/copilot-instructions.md`.

## Machine setup

If the user asks to set up this machine, bootstrap Copilot, or install this kit how they like it, follow the `bootstrap-machine` skill. Assume the kit is not cloned yet. Clone it to `~/source/copilot-kit`, or `%USERPROFILE%\source\copilot-kit` on Windows, after creating that source directory if needed. Then run the bootstrap script. That installs the user profile, upgrades the dev tools, and imports `memories.jsonl`. Do not copy this kit into other repositories. Do not run `gh auth login` or `az login` unless the user asks.

## Defaults

- Prefer GitHub-native tools: `gh`, pull requests, Actions, environments, rulesets, Dependabot, code scanning, and OIDC. Do not add a second CI system or ticketing flow when GitHub already covers it.
- Make small, reviewable changes. One concern per pull request. No drive-by refactors.
- Follow conventions already in the repository. If this kit was copied into a client repo, client rules win.
- Use a project skill for a multi-step procedure instead of improvising. Skills live in `.github/skills/<name>/SKILL.md`.
- Least privilege. Do not widen `GITHUB_TOKEN`, cloud roles, rulesets, or branch protection unless the user asks.
- Do not force-push, disable checks, or apply infrastructure (`terraform apply`, `terraform destroy`, Bicep deployments) unless the user explicitly asks.
- Never print, commit, or log secrets, tokens, or connection strings.

## Cross-platform

- Use repo-relative paths. Do not hardcode `/Users`, `/home`, or `C:\`.
- Quote paths that may contain spaces.
- Do not assume bash. `windows-*` runners default to PowerShell unless `shell:` is set.
- Prefer `git` and `gh` over OS-specific one-liners.
- Do not mass-rewrite line endings or file permissions.

## Before editing

- Read the files you will change, plus nearby workflows or modules.
- Record only commands and conventions you have seen. If a build or test command is not in the repo, say it is not verified.
- If `AGENTS.md` or `.github/copilot-instructions.md` already has client-specific rules, edit them. Do not replace them with this kit's generic text.
