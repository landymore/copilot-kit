# Setup

This repo is the bootstrap source. The installed copy lives in the Copilot user profile, so it applies to every repo on that machine.

On a new machine, open Copilot and paste:

```text
Clone https://github.com/landymore/copilot-kit into ~/source/copilot-kit
if it is not there (Windows: %USERPROFILE%\source\copilot-kit).
Then follow .github/skills/bootstrap-machine/SKILL.md and set up this machine.
```

Assume the repo is not cloned. The skill creates `~/source` or `%USERPROFILE%\source`, clones the kit there, then runs the bootstrap script. That script installs the Copilot profile, the cloud engineering org from `library/cloud-engineering-org`, upgrades dev tools, and imports `memories.jsonl`. Re-run it to update. Do not commit the user profile. Do not sign in to GitHub or Azure unless you mean to.

Personal files live under `$COPILOT_HOME`, or `~/.copilot` when that variable is unset.

| Item | macOS / Linux | Windows |
| --- | --- | --- |
| Personal skills | `~/.copilot/skills/<name>/SKILL.md` | `%USERPROFILE%\.copilot\skills\<name>\SKILL.md` |
| Also scanned | `~/.agents/skills/` | `%USERPROFILE%\.agents\skills\` |
| MCP config | `~/.copilot/mcp-config.json` | `%USERPROFILE%\.copilot\mcp-config.json` |
| Personal agents | `~/.copilot/agents/` | `%USERPROFILE%\.copilot\agents\` |

Day-to-day use is the user profile. The `.github/` files in this repo are the source the script copies from.

## Install

macOS, Linux, or Git Bash:

```bash
./scripts/bootstrap.sh
```

Windows PowerShell:

```powershell
.\scripts\bootstrap.ps1
```

Tool install uses Homebrew on macOS and winget on Windows. Three exceptions, because those packages are not in the default catalogs:

- PowerShell 7 on macOS may need `brew trust powershell/tap` before brew will install or upgrade it. If `pwsh` is already installed, bootstrap warns and continues.
- Terraform on macOS uses the `hashicorp/tap` tap.
- Azure CLI is the Homebrew cask. If an old `azure-cli` formula still owns `az`, the script uninstalls that formula and reinstalls the cask.
- Bicep on macOS is installed with `az bicep install` after Azure CLI, then linked from `~/.azure/bin` to `~/.local/bin`. Windows uses `Microsoft.Bicep`.

If Homebrew or winget is missing, the script stops. It does not install the package manager.

## Copy MCP config to a new machine

`copilot mcp add` writes `mcp-config.json`. Copying the file is fine when you are moving machines. Recreating servers is safer, because the file may contain tokens in `env` or `headers`.

On the old machine, copy the file to an encrypted store, not to this git repo:

```bash
# macOS / Linux
cp "${COPILOT_HOME:-$HOME/.copilot}/mcp-config.json" /path/to/secure/mcp-config.json
```

```powershell
# Windows
$root = if ($env:COPILOT_HOME) { $env:COPILOT_HOME } else { Join-Path $env:USERPROFILE ".copilot" }
Copy-Item (Join-Path $root "mcp-config.json") "$env:USERPROFILE\Documents\secure\mcp-config.json"
```

On the new machine:

```bash
root="${COPILOT_HOME:-$HOME/.copilot}"
mkdir -p "$root"
cp /path/to/secure/mcp-config.json "$root/mcp-config.json"
```

```powershell
$root = if ($env:COPILOT_HOME) { $env:COPILOT_HOME } else { Join-Path $env:USERPROFILE ".copilot" }
New-Item -ItemType Directory -Force -Path $root | Out-Null
Copy-Item "$env:USERPROFILE\Documents\secure\mcp-config.json" (Join-Path $root "mcp-config.json")
```

Review `env` and `headers` before you keep the copy. Prefer `copilot mcp add` so secrets are not left in a second file. The CLI expects strict JSON and a top-level `mcpServers` object:

```json
{
  "mcpServers": {
    "my-local": {
      "type": "local",
      "command": "npx",
      "args": ["-y", "some-mcp"],
      "env": { "KEY": "value" }
    },
    "my-remote": {
      "type": "http",
      "url": "https://example.com/mcp",
      "headers": { "X-Key": "value" }
    }
  }
}
```

Copilot CLI does not read `.vscode/mcp.json`. To reuse a VS Code server, copy that file to `mcp-config.json` (user) or `.mcp.json` (repo), rename `servers` to `mcpServers`, and remove comments and trailing commas. Do not commit tokens.

OAuth tokens are not in `mcp-config.json`. Sign in again on the new machine with `/mcp` or `copilot mcp`.

Do not copy this kit into each client repo. Copilot cloud agent still cannot see `~/.copilot`; it only sees files committed in the repo it is working on.

## Check

```bash
copilot skill list
copilot instruction list
copilot mcp list
```
