---
name: onboard-repo-to-copilot
description: "Create or improve AGENTS.md and .github/copilot-instructions.md for an existing repository. Use when onboarding a repo to Copilot or refreshing its agent instructions."
---

# Onboard a repository to Copilot

Add the instructions Copilot needs for this repository. Do not paste a generic DevOps kit over client rules.

## Inspect first

Read these before writing. Do not guess.

- `README.md`, `AGENTS.md`, `.github/copilot-instructions.md`
- CI workflows and any build, test, and lint commands they already run
- Manifests such as `package.json`, `pyproject.toml`, `go.mod`, `*.csproj`, `*.sln`, and Terraform or Bicep roots

Record only commands you found. If a command is unclear, write "not verified".

## Write

Create a missing file. If the file exists, edit it and keep client-specific rules.

`AGENTS.md` at the repo root — how to work:

- Prefer existing conventions and GitHub-native tools
- Small, reviewable changes
- Use project skills for multi-step procedures
- Least privilege; no secrets in commits or logs
- Cross-platform path and shell notes when the repo supports more than one OS

`.github/copilot-instructions.md` — always-on facts:

- What the repo is
- Verified build, test, and lint commands
- Naming and pull request expectations already used here
- CI and infrastructure cautions that match this repo
- Which docs to update when behavior changes

Keep both short. Remove duplicate paragraphs. Do not add a README section unless the user asked.

## Cross-platform

Use repo-relative paths. Do not hardcode `/Users`, `C:\`, or a specific shell. If workflows use both `windows-*` and `ubuntu-*`, say so.

## Output

Summarize what you added or changed, which commands are verified, and what you left alone because it was already client-specific.
