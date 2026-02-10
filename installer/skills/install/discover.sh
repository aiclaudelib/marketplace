#!/usr/bin/env bash
# Discovers available plugins by comparing registry.json against installed plugins.
# Outputs JSON ready for Claude to present via AskUserQuestion.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REGISTRY="$SCRIPT_DIR/registry.json"

if [[ ! -f "$REGISTRY" ]]; then
  echo '{"error":"registry.json not found","all_installed":false,"installed":[],"available":[],"categories":{},"marketplace":"aiclaudelib"}'
  exit 0
fi

REGISTRY_JSON=$(cat "$REGISTRY")

# Get installed plugins (non-fatal if claude CLI is missing)
INSTALLED_RAW=""
if command -v claude &>/dev/null; then
  INSTALLED_RAW=$(claude plugin list 2>&1) || INSTALLED_RAW=""
fi

export REGISTRY_JSON
export INSTALLED_RAW

exec python3 -c '
import json, os, re

registry = json.loads(os.environ["REGISTRY_JSON"])
installed_raw = os.environ.get("INSTALLED_RAW", "")
marketplace = registry.get("marketplace", "aiclaudelib")

# Parse installed plugin names from claude plugin list output
installed = set()
for line in installed_raw.splitlines():
    line = line.strip()
    if not line or line.startswith(("─", "Name", "WARN")):
        continue
    # First column is the plugin name
    name = line.split()[0] if line.split() else ""
    if name:
        installed.add(name)

available = []
categories = {}
installed_list = []

for p in registry.get("plugins", []):
    name = p["name"]
    # Exclude the marketplace plugin itself
    if name == marketplace:
        continue
    if name in installed:
        installed_list.append(name)
    else:
        entry = {"name": name, "description": p.get("description", ""), "category": p.get("category", "other")}
        available.append(entry)
        cat = entry["category"]
        categories.setdefault(cat, []).append({"name": name, "description": entry["description"]})

result = {
    "all_installed": len(available) == 0,
    "installed": installed_list,
    "available": available,
    "categories": categories,
    "marketplace": marketplace,
    "error": None,
}

print(json.dumps(result))
'
