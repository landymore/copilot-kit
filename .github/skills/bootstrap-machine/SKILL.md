---
name: bootstrap-machine
description: "Set up this machine from the kit: Copilot user profile, dev tools, and memory import. Use when asked to set up this machine, bootstrap Copilot, or install the kit how the user likes it. Assume the repo is not cloned yet."
---

# Bootstrap this machine

The kit is not on the machine until you clone it. Install into the user profile. Do not copy it into other repositories.

## Clone

Use the URL the user gave. If they did not give one, stop and ask. Do not guess the owner.

Checkout path:

- macOS or Linux: `~/source/copilot-kit`
- Windows: `%USERPROFILE%\source\copilot-kit`

Create `~/source` or `%USERPROFILE%\source` if it is missing.

If that checkout already exists, use it. Do not delete it and do not clone a second copy elsewhere.

```bash
mkdir -p "$HOME/source"
git clone <url> "$HOME/source/copilot-kit"
```

```powershell
$dest = Join-Path $env:USERPROFILE "source\copilot-kit"
New-Item -ItemType Directory -Force -Path (Split-Path $dest) | Out-Null
git clone <url> $dest
```

A public repo does not need `gh` auth. Use `git clone`.

## Install

From the checkout, run the script. Do not reimplement the copy.

macOS, Linux, or Git Bash:

```bash
"$HOME/source/copilot-kit/scripts/bootstrap.sh"
```

Windows PowerShell:

```powershell
& (Join-Path $env:USERPROFILE "source\copilot-kit\scripts\bootstrap.ps1")
```

The script writes the Copilot profile under `$COPILOT_HOME`, or `~/.copilot` when that is unset. On Windows that is `%USERPROFILE%\.copilot`. It also installs or upgrades dev tools and imports `memories.jsonl`.

Profile copy:

- `.github/skills/` to `skills/`
- `.github/agents/` to `agents/`
- `.github/copilot-instructions.md` to `copilot-instructions.md`
- `AGENTS.md` to `instructions/agents.instructions.md`

Tools, via Homebrew on macOS and winget on Windows: Git, GitHub CLI, Azure CLI, latest stable .NET SDK, PowerShell 7, Bicep, Node.js, Terraform, and AWS CLI. Upgrade if already installed. On macOS, Azure CLI is the cask. If an old formula still owns `az`, the script replaces it. If PowerShell is already installed but its tap is untrusted, warn and continue. Do not run `brew trust` unless the user asks.

If Homebrew or winget is missing, stop and tell the user how to install that manager. Do not use `curl | sh`.

Memory: the script dry-runs `copilot memories import`, then imports with `--on-conflict skip`. Do not print memory contents if the command fails with a secret. Do not invent extra memories.

Re-running is safe. Profile files are overwritten from the kit. Tools upgrade. Existing memories are skipped on conflict.

## Do not

- Do not clone into the home directory, `/tmp`, or a client repo.
- Do not copy these files into the repo you were in before the kit.
- Do not commit `~/.copilot`.
- Do not create or overwrite `mcp-config.json` unless the user gives you a source file and asks. Never print tokens from that file.
- Do not set `COPILOT_HOME` unless it is already set.
- Do not run `gh auth login` or `az login` unless the user asks.

## Check

From a directory that is not the kit:

```bash
copilot skill list
copilot instruction list
```

Confirm the kit skills are personal, and personal instructions are listed. Report the version line for git, gh, az, dotnet, pwsh, bicep, node, terraform, and aws. Say which tools failed. Tell the user to start a new session and run `copilot --agent devops-enablement`.

A session that was already open will not see the new files until it restarts.
