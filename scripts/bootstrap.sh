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
