#!/usr/bin/env bash
# Copy this kit into the Copilot user profile. Safe to re-run.
# Run this from a checkout. Cloning belongs to the bootstrap-machine skill.
set -euo pipefail

kit="$(cd "$(dirname "$0")/.." && pwd)"
root="${COPILOT_HOME:-$HOME/.copilot}"

mkdir -p "$root/skills" "$root/agents" "$root/instructions"

cp -R "$kit/.github/skills/." "$root/skills/"
cp -R "$kit/.github/agents/." "$root/agents/"
cp "$kit/.github/copilot-instructions.md" "$root/copilot-instructions.md"
cp "$kit/AGENTS.md" "$root/instructions/agents.instructions.md"

org="$kit/library/cloud-engineering-org"
if [[ -d "$org/agents" ]]; then
  cp -R "$org/agents/." "$root/agents/"
  rm -rf "$root/agent-memory"
  cp -R "$org/agent-memory" "$root/agent-memory"
  for dir in "$org/skills"/*.skill; do
    [[ -d "$dir" ]] || continue
    name="$(basename "$dir" .skill)"
    if [[ -d "$root/skills/$name" ]]; then
      echo "Kept kit skill $name"
      continue
    fi
    rm -rf "$root/skills/$name"
    mkdir -p "$root/skills/$name"
    cp -R "$dir/." "$root/skills/$name/"
  done
  python3 - "$root" << 'PY'
import sys
from pathlib import Path
root = Path(sys.argv[1])
mem = root / "agent-memory"
needle = "./agent-memory/"
replacement = str(mem) + "/"
for path in (root / "agents").glob("*.agent.md"):
    text = path.read_text()
    if needle in text:
        path.write_text(text.replace(needle, replacement))
note = root / "instructions" / "cloud-engineering-org.instructions.md"
note.write_text(
    "\n".join([
        "# Cloud engineering org",
        "",
        "The cloud engineering agents in the user profile call each other by display name. Keep the whole set installed.",
        f"Their knowledge files are in `{mem}`.",
        "If an agent says `./agent-memory/`, read that path under the user profile, not the current repo.",
        "Use the kit skill `iac-review`. Do not look for a second skill with that name.",
        "Archie is the default lead. Archie routes Microsoft cloud work and does work that has no specialist.",
        "Some listed tools are VS Code or MCP only. Skip a tool that is not available.",
        "",
    ])
)
print(f"Installed cloud engineering org into {root}")
PY
fi

python3 - "$root/settings.json" << 'PY' || echo "Could not enable memory in settings.json" >&2
import json, sys
from pathlib import Path
path = Path(sys.argv[1])
data = json.loads(path.read_text()) if path.exists() else {}
if data.get("memory") is not True:
    data["memory"] = True
    path.write_text(json.dumps(data, indent=2) + "\n")
    print(f"Enabled memory in {path}")
else:
    print(f"Memory already enabled in {path}")
PY

echo "Installed Copilot profile from $kit"
echo "User profile: $root"

tools_rc=0
"$kit/scripts/setup-tools.sh" || tools_rc=$?

mem_rc=0
mem="$kit/memories.jsonl"
if [[ -f "$mem" ]]; then
  if copilot memories import --dry-run --on-conflict skip "$mem"; then
    copilot memories import --on-conflict skip "$mem" || mem_rc=$?
  else
    echo "Memory dry run failed; skipped import." >&2
    mem_rc=1
  fi
else
  echo "No memories.jsonl at $mem" >&2
  mem_rc=1
fi

echo "Open a new Copilot session, then run: copilot skill list"
if [[ $tools_rc -ne 0 || $mem_rc -ne 0 ]]; then
  exit 1
fi
