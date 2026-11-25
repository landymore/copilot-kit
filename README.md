# Copilot Kit

Portable GitHub Copilot starter kit for DevOps enablement and GitHub transformation. The same files work in Copilot CLI, VS Code, and Copilot cloud agent, on macOS and Windows.

The repo is the bootstrap source. After you run setup, Copilot loads the installed copy from your user profile on every repo. You do not copy these files into each project.

## What you get

| Path | Role |
| --- | --- |
| `AGENTS.md` | How Copilot should work in this repo |
| `.github/copilot-instructions.md` | Always-on rules for CI, IaC, docs, and cross-platform edits |
| `.github/skills/` | Project skills. Each folder has a `SKILL.md` |
| `.github/agents/devops-enablement.agent.md` | Custom agent for enablement work |
| `scripts/bootstrap.sh` | macOS / Linux install into `~/.copilot` |
| `scripts/bootstrap.ps1` | Windows install into `%USERPROFILE%\.copilot` |
| `SETUP.md` | What the scripts copy, plus MCP config |
| `LICENSE` | MIT |

Skills:

- `github-actions-review` — workflow permissions, pinning, secrets
- `iac-review` — Terraform and Bicep
- `pipeline-debug` — a failing Actions run
- `release-notes` — notes since the last tag
- `security-scan-triage` — Dependabot, code scanning, secret scanning
- `onboard-repo-to-copilot` — create or improve `AGENTS.md` and `copilot-instructions.md` for an existing repo
- `bootstrap-machine` — install this kit into the user profile on the current machine

In Copilot CLI each skill is also `/<name>`.

## How to use it

On a new machine, open Copilot and paste:

```text
Clone https://github.com/landymore/copilot-kit into ~/source/copilot-kit
if it is not there (Windows: %USERPROFILE%\source\copilot-kit).
Then follow .github/skills/bootstrap-machine/SKILL.md and set up this machine.
```

The repo will not be on the machine yet. Copilot creates `~/source` or `%USERPROFILE%\source` if needed, clones the kit there, and runs the bootstrap script. That copies skills, the agent, and instructions into your user profile, upgrades the dev tools, and imports `memories.jsonl`. Start a new Copilot session after that. The installed copy then loads in every repo on that machine.

You can run the same install yourself.

macOS or Linux:

```bash
mkdir -p "$HOME/source"
git clone https://github.com/landymore/copilot-kit.git "$HOME/source/copilot-kit"
"$HOME/source/copilot-kit/scripts/bootstrap.sh"
```

Windows PowerShell:

```powershell
$dest = Join-Path $env:USERPROFILE "source\copilot-kit"
New-Item -ItemType Directory -Force -Path (Split-Path $dest) | Out-Null
git clone https://github.com/landymore/copilot-kit.git $dest
& (Join-Path $dest "scripts\bootstrap.ps1")
```

The script copies skills, the agent, and instructions into `$COPILOT_HOME`, or `~/.copilot` when that is unset. On Windows that is `%USERPROFILE%\.copilot`. It upgrades Git, GitHub CLI, Azure CLI, the .NET SDK, PowerShell 7, Bicep, Node.js, Terraform, and AWS CLI with Homebrew or winget. It imports `memories.jsonl`. Re-run the script after you change this repo. It does not sign in to GitHub or Azure, and it does not copy MCP config.

Then, from any repo:

```bash
copilot --agent devops-enablement
```

Copilot cloud agent on GitHub does not read your laptop profile. It only sees files committed in the repository it is working on.

## Project skills vs personal skills

| | Project skills | Personal skills |
| --- | --- | --- |
| Path | `.github/skills/<name>/SKILL.md` | `~/.copilot/skills/<name>/SKILL.md` or `~/.agents/skills/<name>/SKILL.md` |
| Who gets them | Anyone using Copilot in that repo, including cloud agent | That user, on that machine, in every repo |
| Use for | The source copy in this kit, and cloud agent if you commit them | What you use day to day, in every repo on that machine |

This CLI lists project locations before personal ones. When two skills share a name, the first match wins. Do not reuse a project skill name for a personal copy unless you have confirmed which one loads.

Cloud agent on GitHub sees skills committed to the repository. It does not see `~/.copilot/skills` on your laptop.

`$COPILOT_HOME` replaces `~/.copilot` when it is set. On Windows, `~` is `%USERPROFILE%`.

## Where the installed copy lives

| Item | macOS / Linux | Windows |
| --- | --- | --- |
| Skills | `~/.copilot/skills/` | `%USERPROFILE%\.copilot\skills\` |
| Agent | `~/.copilot/agents/` | `%USERPROFILE%\.copilot\agents\` |
| Always-on instructions | `~/.copilot/copilot-instructions.md` | `%USERPROFILE%\.copilot\copilot-instructions.md` |
| Working rules | `~/.copilot/instructions/agents.instructions.md` | same path under `%USERPROFILE%\.copilot` |
| MCP config | `~/.copilot/mcp-config.json` | `%USERPROFILE%\.copilot\mcp-config.json` |

This CLI also scans `~/.agents/skills/` for skills. The bootstrap script does not write there. Use `~/.copilot` unless you have set `COPILOT_HOME`.

Details and MCP setup are in [SETUP.md](SETUP.md).

## EMU and enterprise clients

Enterprise Managed Users sign in to the enterprise, not a personal github.com account. A public copy of this kit still works:

1. Keep the public repo free of client names, tokens, and MCP config.
2. Clone or download it over HTTPS. No github.com login is required for a public repo. If the network blocks github.com, mirror a tagged release into an internal repository and pin that tag.
3. Clone or copy this kit, then run `scripts/bootstrap.sh` or `scripts/bootstrap.ps1`. That installs into the user profile on that machine. Do not copy the kit into each client repo.
4. Organization-wide agents are not the same path. Org owners publish them from the organization's `.github` or `.github-private` repository, in `agents/` at that repository root. Enterprise agents live in the enterprise `.github-private` repository the same way. Confirm the current admin docs before a wide rollout.
5. Personal skills and `mcp-config.json` stay on the laptop. They are not synced by the EMU account. Recreate MCP servers with `copilot mcp add`.
6. Cloud agent, MCP, and third-party tools still follow enterprise policy. This kit does not turn on features an admin has disabled.

## Next steps after cloning

1. Skim `AGENTS.md` and `.github/copilot-instructions.md`. Edit them in this repo, then re-run the bootstrap script.
2. Run the bootstrap script once per machine.
3. In a repo that is not this kit, run `copilot skill list` and `copilot instruction list`.
4. Start with `copilot --agent devops-enablement`.
5. Recreate MCP servers with `copilot mcp add`. Do not commit `mcp-config.json`.
6. Tag a release if other machines should bootstrap from a known version.
