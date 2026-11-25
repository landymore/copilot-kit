#!/usr/bin/env bash
# Install or upgrade the dev tools for this kit. Safe to re-run.
# Homebrew only. Does not sign in to GitHub or Azure.
set -u

failed=()

note() { printf '%s\n' "$*"; }
fail() { failed+=("$1"); printf 'FAILED: %s\n' "$1" >&2; }

if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew is not installed. Install it from https://brew.sh and re-run." >&2
  exit 1
fi

export PATH="$(brew --prefix)/bin:$PATH"

install_or_upgrade() {
  local name="$1"
  local rc=0
  if brew list --formula "$name" >/dev/null 2>&1; then
    brew upgrade "$name" || rc=$?
  elif brew list --cask "$name" >/dev/null 2>&1; then
    brew upgrade --cask "$name" || rc=$?
  else
    brew install "$name" || rc=$?
  fi
  if [[ $rc -ne 0 ]]; then
    fail "$name"
    return 1
  fi
  note "OK $name"
}

install_cask() {
  local name="$1"
  local rc=0
  if brew list --cask "$name" >/dev/null 2>&1; then
    brew upgrade --cask "$name" || rc=$?
  else
    brew install --cask "$name" || rc=$?
  fi
  if [[ $rc -ne 0 ]]; then
    fail "$name"
    return 1
  fi
  note "OK $name"
}

install_or_upgrade git || true
install_or_upgrade gh || true
install_cask azure-cli || true
# An old homebrew-core formula can keep /opt/homebrew/bin/az after the cask installs.
# That formula is gone from core. Remove it so the cask binary is the one on PATH.
if brew list --formula azure-cli >/dev/null 2>&1; then
  note "Replacing outdated azure-cli formula with the cask"
  brew uninstall --formula azure-cli || fail "azure-cli formula"
  brew reinstall --cask azure-cli || fail "azure-cli"
fi
install_or_upgrade dotnet || true
install_or_upgrade node || true
install_or_upgrade awscli || true

# PowerShell 7 is on an untrusted tap. Do not auto-trust it.
# If pwsh is already installed, a refused upgrade is a warning, not a failed setup.
if command -v pwsh >/dev/null 2>&1; then
  if brew upgrade powershell; then
    note "OK powershell"
  else
    note "PowerShell is installed, but brew will not upgrade it until the tap is trusted."
    note "To upgrade: brew trust powershell/tap && brew upgrade powershell"
  fi
elif ! install_or_upgrade powershell; then
  note "PowerShell 7 was not installed. If brew refused an untrusted tap, run: brew trust powershell/tap"
  note "Then re-run this script."
fi

# Terraform is not in homebrew-core. The HashiCorp tap is the brew install path.
# A tap failure is not fatal if the install command taps and installs successfully.
if brew list --formula terraform >/dev/null 2>&1; then
  brew upgrade terraform || fail "terraform"
else
  brew tap hashicorp/tap || note "brew tap hashicorp/tap failed; install will retry the tap"
  brew install hashicorp/tap/terraform || fail "terraform"
fi

# Homebrew has no Bicep formula. Azure CLI installs the official binary to ~/.azure/bin.
# A failed download can leave a zero-byte file that makes later installs skip.
bicep_bin="${HOME}/.azure/bin/bicep"
if [[ -e "$bicep_bin" && ! -x "$bicep_bin" ]]; then
  rm -f "$bicep_bin"
fi
if command -v az >/dev/null 2>&1; then
  if [[ -x "$bicep_bin" ]]; then
    az bicep upgrade && note "OK bicep" || fail "bicep"
  else
    az bicep install && note "OK bicep" || fail "bicep"
  fi
  if [[ -x "$bicep_bin" ]]; then
    mkdir -p "${HOME}/.local/bin"
    ln -sfn "$bicep_bin" "${HOME}/.local/bin/bicep"
  fi
else
  fail "bicep (Azure CLI not on PATH)"
fi

note "Versions:"
for cmd in git gh az dotnet pwsh bicep node terraform aws; do
  if command -v "$cmd" >/dev/null 2>&1; then
    printf '%s: ' "$cmd"
    "$cmd" --version 2>&1 | head -1
  elif [[ "$cmd" == "bicep" ]] && command -v az >/dev/null 2>&1; then
    az bicep version 2>&1 | head -1 || true
  else
    note "MISSING $cmd"
  fi
done

if [[ ${#failed[@]} -gt 0 ]]; then
  note "Tool setup failed for: ${failed[*]}"
  exit 1
fi
