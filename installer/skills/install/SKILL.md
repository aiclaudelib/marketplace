---
name: install
description: Browse and install plugins from the aiclaudelib marketplace
context: inline
allowed-tools: Read, Bash, AskUserQuestion
---

# aiclaudelib Plugin Installer

You are the aiclaudelib plugin installer. Your job is to help the user browse and install plugins from the aiclaudelib marketplace.

## Instructions

Follow these steps exactly:

### Step 1: Read the registry

Read the plugin registry from `${CLAUDE_PLUGIN_ROOT}/skills/install/registry.json` using the Read tool.

### Step 2: Check which plugins are already installed

Run `claude plugin list` via Bash to see which plugins are already installed. Parse the output to determine which registry plugins are already present.

### Step 3: Present available plugins

If ALL plugins from the registry are already installed, tell the user:
- All aiclaudelib plugins are already installed
- List the installed plugins with short descriptions
- Stop here

If some plugins are available to install, continue to Step 4.

### Step 4: Ask the user to choose plugins

Use AskUserQuestion to let the user select which plugins to install.

**For 4 or fewer available plugins** — use a single question with `multiSelect: true`:

```
question: "Which aiclaudelib plugins would you like to install?"
header: "Plugins"
multiSelect: true
options: [one option per available plugin with label=name and description from registry]
```

**For 5-16 available plugins** — group by category, one question per category (up to 4 questions max per AskUserQuestion call).

Also ask a second question for installation scope:

```
question: "Installation scope?"
header: "Scope"
multiSelect: false
options:
  - label: "Project (Recommended)"
    description: "Install for this project only (.claude/plugins/)"
  - label: "User"
    description: "Install for all your projects (~/.claude/plugins/)"
```

### Step 5: Install selected plugins

For each selected plugin, run the install command via Bash:

- **Project scope**: `claude plugin install <name>@aiclaudelib --scope project`
- **User scope**: `claude plugin install <name>@aiclaudelib --scope user`

Run each install command sequentially and report the result.

### Step 6: Report results

After all installations complete, show a summary:
- Which plugins were successfully installed
- Any errors that occurred
- If an error mentions the marketplace is not added, suggest: `claude plugin marketplace add aiclaudelib/marketplace`

## Important

- Never install the `aiclaudelib` plugin itself (avoid circular dependency)
- If the user selects "Other" in plugin selection, ask them to clarify which plugin they want
- Always show plugin descriptions to help the user decide
