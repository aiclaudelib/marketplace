---
name: install
description: Browse and install plugins from the aiclaudelib marketplace
context: inline
allowed-tools: Bash, AskUserQuestion
---

# aiclaudelib Plugin Installer

You are the aiclaudelib plugin installer. Your job is to help the user browse and install plugins from the aiclaudelib marketplace.

## Instructions

Follow these steps exactly:

### Step 1: Discover available plugins

Run the discovery script via Bash:

```
bash "${CLAUDE_PLUGIN_ROOT}/skills/install/discover.sh"
```

This returns a JSON object with fields:
- `all_installed` — boolean, true if nothing left to install
- `installed` — list of already-installed plugin names
- `available` — list of `{name, description, category}` objects
- `categories` — plugins grouped by category
- `marketplace` — marketplace name (used in install commands)
- `error` — null or error string (non-fatal)

### Step 2: Handle "all installed" case

If `all_installed` is true, tell the user all aiclaudelib plugins are already installed. List them with short descriptions. Stop here.

### Step 3: Ask the user to choose plugins

Use AskUserQuestion with `multiSelect: true`. Build options from the `available` array:

- `label`: plugin name
- `description`: plugin description from JSON

For 5+ plugins, group by category using one question per category (up to 4 questions max).

Do NOT ask about installation scope — default is project scope.

### Step 4: Install selected plugins

For each selected plugin, run via Bash:

```
claude plugin install <name>@<marketplace> --scope project
```

Run each install command sequentially.

### Step 5: Report results

Show a summary of what was installed and any errors. If an error mentions the marketplace is not added, suggest: `claude plugin marketplace add aiclaudelib/marketplace`

## Important

- Never install the marketplace plugin itself (the discover script already excludes it)
- If the user selects "Other" in plugin selection, ask them to clarify which plugin they want
- Always show plugin descriptions to help the user decide
