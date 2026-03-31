# REVA-TURBO Installation Guide

Four ways to install REVA-TURBO into your Claude Code environment. Pick the one that fits your setup.

---

## Prerequisites

| Requirement | Why | Check |
|-------------|-----|-------|
| **Claude Code** | REVA-TURBO runs as a Claude Code skills engine | `claude --version` |
| **Node.js 18+** | Required for `.docx` report generation | `node --version` |
| **npm** | Installs docx converter dependencies | `npm --version` |
| **Git** (optional) | For Method 1 and Method 2 | `git --version` |
| **macOS or Windows** | Auto-detected by setup script | — |

---

## Method 1: Git Clone (Recommended)

Clone the repository and run the setup script.

```bash
# Clone the repo
git clone https://github.com/mrdulasolutions/RevOps-RevAMfg.git reva-turbo

# Enter the directory
cd reva-turbo

# Run setup
./setup
```

**What `./setup` does:**

1. Creates `~/.reva-turbo/` runtime directory structure:
   ```
   ~/.reva-turbo/
     config.yaml
     sessions/
     analytics/
     state/
     reports/REVA-TURBO-Reports/
     contributor-logs/
   ```

2. Symlinks the skill directory into Claude Code's skills path:
   ```
   ~/.claude/skills/reva-turbo -> /path/to/your/reva-turbo
   ```

3. Makes all `bin/` scripts executable

4. Installs npm dependencies for the `.docx` report converter

5. Creates default configuration at `~/.reva-turbo/config.yaml`:
   ```yaml
   telemetry: off
   proactive: true
   report_format: docx
   crm_type: none
   platform: mac    # auto-detected
   ```

**Verify installation:**

```bash
# Check the symlink
ls -la ~/.claude/skills/reva-turbo

# Check config
~/.claude/skills/reva-turbo/bin/reva-turbo-config list

# Launch REVA-TURBO in Claude Code
claude
# Then type: /revmyengine
```

---

## Method 2: Agentic Install (Inside Claude Code)

Let Claude Code install REVA-TURBO for you. Open Claude Code and paste:

```
Clone the REVA-TURBO skills engine from https://github.com/mrdulasolutions/RevOps-RevAMfg.git
and run the setup script. Install it as a Claude Code skills engine at ~/.claude/skills/reva-turbo.
```

Claude will:
1. Clone the repo to a local directory
2. Run `./setup` to create runtime directories and symlink skills
3. Confirm the installation
4. You can immediately use `/revmyengine`

**Alternative — install from within an existing Claude Code session:**

```
Read and execute the setup script at https://github.com/mrdulasolutions/RevOps-RevAMfg.git
to install the REVA-TURBO PM workflow engine.
```

---

## Method 3: Upload / Drag-and-Drop

For environments without Git access, or when working in Claude Desktop or Claude CoWork.

### Step 1: Download

Download the repository as a `.zip` from GitHub:
- Go to the repository page
- Click **Code** > **Download ZIP**
- Save `RevOps-RevAMfg-main.zip` to your machine

### Step 2: Extract

```bash
# Extract the zip
unzip RevOps-RevAMfg-main.zip

# Rename to reva-turbo
mv RevOps-RevAMfg-main reva-turbo
```

### Step 3: Run Setup

```bash
cd reva-turbo
chmod +x setup
./setup
```

### Step 4: Verify

```bash
ls -la ~/.claude/skills/reva-turbo
```

### Alternative: Drag into Claude Desktop

1. Download and extract the `.zip`
2. Open Claude Desktop
3. Drag the `reva-turbo/` folder into the conversation
4. Ask Claude to run the setup script:
   ```
   Run the setup script in the reva-turbo directory I just uploaded.
   ```

---

## Method 4: Add .zip to Claude Code Instance

For Claude Code web (claude.ai/code) or managed instances where you can upload files.

### Step 1: Prepare the Archive

```bash
# If you have the repo locally
cd /path/to/reva-turbo
zip -r reva-turbo-skills.zip . -x '*.git*' -x 'node_modules/*' -x '._*' -x '.DS_Store'
```

Or download the `.zip` directly from GitHub.

### Step 2: Upload to Instance

In Claude Code (web or desktop):

1. Use the file upload button or drag-and-drop
2. Upload `reva-turbo-skills.zip` or the extracted folder
3. Tell Claude:
   ```
   Extract reva-turbo-skills.zip to ~/.claude/skills/reva-turbo/ and run the setup script.
   ```

### Step 3: Manual Setup (if upload doesn't support scripts)

If the setup script can't run automatically:

```bash
# Create runtime directories
mkdir -p ~/.reva-turbo/{sessions,analytics,state,reports/REVA-TURBO-Reports,contributor-logs}

# Create skills directory and link
mkdir -p ~/.claude/skills
ln -s /path/to/extracted/reva-turbo ~/.claude/skills/reva-turbo

# Make scripts executable
chmod +x ~/.claude/skills/reva-turbo/bin/*
chmod +x ~/.claude/skills/reva-turbo/setup

# Install docx dependencies (if package.json exists)
cd ~/.claude/skills/reva-turbo/reva-turbo-docx/scripts && npm install --silent 2>/dev/null || true

# Create default config
cat > ~/.reva-turbo/config.yaml << 'EOF'
telemetry: off
proactive: true
report_format: docx
crm_type: none
platform: mac
EOF
```

---

## Post-Install Configuration

After installation, configure REVA-TURBO for your environment:

```bash
# Set your default PM
reva-turbo-config set default_pm ray-yeh

# Set your CRM type
reva-turbo-config set crm_type dynamics    # or: powerapps, hubspot, none

# Enable telemetry (optional)
reva-turbo-config set telemetry on

# Set proactive mode
reva-turbo-config set proactive true       # auto-suggest skills based on context
```

### CRM Integration

If using Microsoft Dynamics 365 or Power Apps:
1. Set `crm_type` to `dynamics` or `powerapps`
2. Configure CRM MCP tools in your Claude Code settings
3. Test with `/reva-turbo-crm-connector`

If using HubSpot:
1. Set `crm_type` to `hubspot`
2. Ensure HubSpot MCP tools are available
3. Test with `/reva-turbo-crm-connector`

### Email Integration

1. Configure Hostinger or Gmail MCP tools in Claude Code
2. Test with `/reva-turbo-email-connector`
3. Set up RFQ detection patterns for automatic intake

### Slack Integration (for Pulse alerts)

1. Configure Slack MCP tools in Claude Code
2. Test with `/reva-turbo-pulse`
3. Set channel preferences for alert routing

---

## First Run

After installation, start REVA-TURBO:

```
/revmyengine
```

The engine will:
1. Run the preamble (session init, config load, telemetry check)
2. Prompt for telemetry opt-in (one-time only)
3. Wait for your first command

**Try these to get started:**

| Say This | What Happens |
|----------|-------------|
| "New RFQ from Acme Corp" | Routes to rfq-intake |
| "Dashboard" | Shows PM workload dashboard |
| "What's the status of order ORD-001?" | Routes to order-track |
| "Quote 500 aluminum brackets" | Routes to quick -> rfq-quote |
| "Inspect incoming shipment" | Routes to inspect |
| "Escalate — quality issue with Shenzhen partner" | Routes to escalate |

---

## Updating

### Git-based Install

```bash
cd /path/to/reva-turbo
git pull origin main
./setup    # re-run to pick up any new dependencies
```

### Zip-based Install

1. Download the latest `.zip`
2. Extract over the existing directory
3. Re-run `./setup`

Your runtime data at `~/.reva-turbo/` (config, state, reports) is preserved across updates. Only the skill files are updated.

---

## Uninstalling

```bash
# Remove the skills symlink
rm ~/.claude/skills/reva-turbo

# Remove runtime data (optional — contains your reports and config)
rm -rf ~/.reva-turbo

# Remove the skill source directory
rm -rf /path/to/reva-turbo
```

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| `./setup: Permission denied` | Run `chmod +x setup` first |
| Skills not found in Claude Code | Check symlink: `ls -la ~/.claude/skills/reva-turbo` |
| `.docx` reports not generating | Run `cd reva-turbo-docx/scripts && npm install` |
| Config not loading | Check `~/.reva-turbo/config.yaml` exists |
| Telemetry prompt keeps appearing | Run `touch ~/.reva-turbo/.telemetry-prompted` |
| Hook scripts not running | Run `chmod +x` on all scripts in `bin/` directories |
| CRM connector fails | Verify CRM MCP tools are configured in Claude Code settings |

---

## System Requirements

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| Claude Code | v2.0+ | Latest |
| Node.js | 18.0+ | 20.0+ |
| Disk space | 50 MB (engine) | 200 MB (with reports) |
| OS | macOS 12+ or Windows 10+ | macOS 14+ |
