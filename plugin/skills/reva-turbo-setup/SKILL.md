---
name: reva-turbo-setup
preamble-tier: 2
version: 1.0.0
description: |
  Interactive onboarding wizard for REVA-TURBO engine configuration.
  8 sections: company profile, workflow, connectors, manufacturing partners,
  shipping, documents, CoWork space, voice profile. Creates 6 YAML config
  files + voice profile yaml. Supports skip, resume, and per-section reconfiguration.
compatibility: Claude Code, Claude desktop, Claude CoWork
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - AskUserQuestion
---

## Preamble (run first)

```bash
mkdir -p ~/.reva-turbo/analytics ~/.reva-turbo/config ~/.reva-turbo/sessions ~/.reva-turbo/state
echo '{"skill":"reva-turbo-setup","ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"}' >> ~/.reva-turbo/analytics/skill-usage.jsonl 2>/dev/null || true

# Detect existing config for resume
_SETUP_COMPLETE=$(~/.claude/skills/reva-turbo/bin/reva-turbo-config get setup_completed 2>/dev/null || echo "false")
_HAS_COMPANY=$([ -f ~/.reva-turbo/config/company-profile.yaml ] && echo "yes" || echo "no")
_HAS_WORKFLOW=$([ -f ~/.reva-turbo/config/workflow-config.yaml ] && echo "yes" || echo "no")
_HAS_CONNECTORS=$([ -f ~/.reva-turbo/config/connector-config.yaml ] && echo "yes" || echo "no")
_HAS_PARTNERS=$([ -f ~/.reva-turbo/config/partners.yaml ] && echo "yes" || echo "no")
_HAS_SHIPPING=$([ -f ~/.reva-turbo/config/shipping-config.yaml ] && echo "yes" || echo "no")
_HAS_DOCUMENTS=$([ -f ~/.reva-turbo/config/document-config.yaml ] && echo "yes" || echo "no")
echo "SETUP_COMPLETE: $_SETUP_COMPLETE"
echo "SECTION_STATUS: company=$_HAS_COMPANY workflow=$_HAS_WORKFLOW connectors=$_HAS_CONNECTORS partners=$_HAS_PARTNERS shipping=$_HAS_SHIPPING documents=$_HAS_DOCUMENTS"
```

## Purpose

REVA-TURBO Setup is an interactive 7-section onboarding wizard that configures the entire REVA-TURBO engine for a specific company. It creates 6 YAML configuration files at `~/.reva-turbo/config/` that drive every downstream skill — from RFQ intake through customer delivery.

Read the system prompt and all section prompts from `prompts/` before beginning. Read `references/config-schema.md` for field-level validation rules.

## Resume Detection

After running the preamble, check for existing configuration:

1. If `SETUP_COMPLETE` is `true`, inform the PM:
   > REVA-TURBO setup is already complete. What would you like to do?
   > A) Reconfigure a specific section (specify 1-7)
   > B) Start fresh (overwrites all config)
   > C) View current configuration summary
   > D) Exit

2. If `SETUP_COMPLETE` is `false` but some config files exist, offer resume:
   > Previous setup was not completed. Found config for: [list existing].
   > A) Resume from the next incomplete section
   > B) Start fresh (overwrites existing config)
   > C) Exit

3. If no config files exist, begin from Section 1.

### Section-Specific Invocation

If invoked with `section:N` parameter (e.g., `/setup section:3`), skip directly to that section. Confirm before overwriting if a config file already exists for that section.

## Section Flow

Always display the progress indicator at the start of each section:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  REVA-TURBO Setup — Section X of 8: [Name]
  ██████░░░░░░░░ X/7 complete
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Fill in the progress bar proportionally.

---

### Section 1 of 7: Company Profile

**Read:** `prompts/section-company.md` for detailed questions.
**Writes:** `~/.reva-turbo/config/company-profile.yaml`
**Template:** `templates/company-profile.yaml.tmpl`

Collect the following via AskUserQuestion (one question at a time or grouped logically):

1. **Company legal name** — free text, required
2. **DBA** (doing business as) — free text, optional ("same" = use legal name)
3. **Address** — street, city, state, zip, country (group as one question with line-by-line entry)
4. **Phone** — required
5. **Fax** — optional
6. **Website** — required
7. **Logo file path** — path to company logo file for report headers (can be set later)
8. **Default timezone** — lettered options: A) US/Eastern, B) US/Central, C) US/Mountain, D) US/Pacific, E) UTC, F) Other (specify)
9. **Fiscal year start month** — 1-12, default January

**Team Members** — loop to collect team:

For each member:
- Name (required)
- Role: A) Project Manager, B) Engineer, C) Quality Control, D) Executive, E) Admin, F) Other
- Email (required)
- Phone (optional)

Ask: "Add another team member? (Y/N)"

**Escalation Matrix** — collect 4 levels:

- Level 1 (Project Manager): name + email
- Level 2 (PM Manager): name + email
- Level 3 (VP Operations): name + email
- Level 4 (CEO): name + email

After collecting all data, display a summary table:

```
┌─────────────────────────────────────────────┐
│  Company Profile Summary                    │
├─────────────────────────────────────────────┤
│  Legal Name:  [value]                       │
│  DBA:         [value]                       │
│  Address:     [full address]                │
│  Phone:       [value]                       │
│  Website:     [value]                       │
│  Timezone:    [value]                       │
│  Team:        [N] members                   │
│  Escalation:  4 levels configured           │
└─────────────────────────────────────────────┘
```

Ask: "Does this look correct? A) Yes, save it  B) Edit a field  C) Start this section over"

If A, render `templates/company-profile.yaml.tmpl` with collected values and write to `~/.reva-turbo/config/company-profile.yaml`.

---

### Section 2 of 7: Workflow Configuration

**Read:** `prompts/section-workflow.md` for detailed questions.
**Writes:** `~/.reva-turbo/config/workflow-config.yaml`
**Template:** `templates/workflow-config.yaml.tmpl`

1. **Display the 15 lifecycle stages** and let the PM activate or deactivate each:

```
REVA-TURBO Lifecycle Stages (enter numbers to toggle, 'all' to activate all):

 1. [x] rfq-intake        — RFQ received and parsed
 2. [x] rfq-qualify        — Customer/project qualified
 3. [x] rfq-quote          — Quote prepared and sent
 4. [x] customer-gate      — Customer approves quote/terms
 5. [x] china-package      — Technical package sent to mfg partners
 6. [x] partner-quote      — Partner quote received and evaluated
 7. [x] order-confirm      — Order placed with partner
 8. [x] production-track   — Production monitoring
 9. [x] quality-gate       — Quality inspections (G1-G4)
10. [x] export-compliance  — Export/import compliance check
11. [x] logistics          — Shipping and logistics
12. [x] import-compliance  — US import clearance
13. [x] delivery           — Customer delivery
14. [x] invoice            — Invoicing and payment
15. [x] closeout           — Project closeout and archive
```

2. **Custom stage display names** — For each active stage, optionally rename its display label (e.g., "china-package" -> "Send to Shenzhen"). Use existing names as defaults.

3. **Quality gate thresholds** (G1-G4):
   - G1: Drawing Review — minimum pass % (default: 100%)
   - G2: First Article Inspection — minimum pass % (default: 95%)
   - G3: Production Sample — minimum pass % (default: 98%)
   - G4: Final Inspection — minimum pass % (default: 99%)

4. **Auto-advance settings** — Which stages can auto-advance to the next stage without PM approval? Display each active stage and ask Y/N. Recommend manual for customer-gate, quality-gate, export-compliance.

5. **Default priority levels**:
   - Critical (same-day response)
   - High (24-hour response)
   - Medium (48-hour response, default)
   - Low (1-week response)

6. **SLA definitions** — Target days for each active stage. Show defaults, let PM adjust:
   - rfq-intake: 1 day
   - rfq-qualify: 2 days
   - rfq-quote: 3 days
   - customer-gate: 5 days
   - china-package: 2 days
   - partner-quote: 5 days
   - order-confirm: 2 days
   - production-track: 30 days
   - quality-gate: 5 days
   - export-compliance: 3 days
   - logistics: 14 days
   - import-compliance: 5 days
   - delivery: 3 days
   - invoice: 5 days
   - closeout: 7 days

Display summary, confirm, write `workflow-config.yaml`.

---

### Section 3 of 7: Connectors

**Read:** `prompts/section-connectors.md` and `references/connector-guide.md`.
**Writes:** `~/.reva-turbo/config/connector-config.yaml`
**Template:** `templates/connector-config.yaml.tmpl`

For each connector type, ask if the PM wants to configure it:

1. **CRM**:
   - Type: A) Power Apps/Dataverse, B) Dynamics 365, C) HubSpot, D) Salesforce, E) None/Later
   - If selected: API URL, API key/token (warn about security — store as env var reference, not plaintext)
   - Field mapping guidance: link to `references/connector-guide.md`

2. **Email**:
   - Provider: A) Hostinger, B) Gmail, C) Outlook/Microsoft 365, D) None/Later
   - Sending address (the "from" address for REVA-TURBO emails)
   - Signature text (or "use company default")
   - Connection: reference MCP server setup in connector guide

3. **ERP**:
   - Type: A) SAP Business One, B) NetSuite, C) QuickBooks, D) None/Later
   - Connection details (store securely)
   - Inventory sync frequency: A) Real-time, B) Hourly, C) Daily, D) Manual

4. **Slack**:
   - Workspace URL
   - Channels: alerts channel, orders channel, escalation channel
   - Bot token reference (env var name, not the token itself)

5. **iMessage**:
   - Contact list for pulse/alert notifications (name + phone number)
   - Enable/disable iMessage alerts

6. **Webhooks**:
   - Any external webhook URLs for notifications

Display summary of configured connectors, confirm, write `connector-config.yaml`.

**Security note:** Never write API keys, tokens, or passwords directly to config files. Instead, write environment variable references like `${REVA_TURBO_HUBSPOT_API_KEY}`. Instruct the PM to set these in their shell profile.

---

### Section 4 of 7: Manufacturing Partners

**Read:** `prompts/section-partners.md`.
**Writes:** `~/.reva-turbo/config/partners.yaml`
**Template:** `templates/partners.yaml.tmpl`

Collect partner data in a loop:

For each partner:

1. **Company name** — required
2. **Country** — lettered: A) China, B) Taiwan, C) Vietnam, D) India, E) Mexico, F) USA, G) Other
3. **City** — free text
4. **Primary contact**:
   - Name
   - Email
   - Phone
   - WeChat ID (if China/Taiwan)
   - WhatsApp (if other)
5. **Capabilities** — multi-select from:
   - A) CNC Machining
   - B) Injection Molding
   - C) Sheet Metal / Stamping
   - D) Die Casting
   - E) Investment Casting
   - F) Assembly
   - G) Surface Finishing / Plating
   - H) 3D Printing / Additive
   - I) PCB / Electronics
   - J) Packaging
   - K) Other (specify)
6. **Lead times** by complexity:
   - Simple parts: ___ days
   - Moderate parts: ___ days
   - Complex parts: ___ days
7. **Quality rating**: A) A/Excellent, B) B/Good, C) C/Acceptable, D) D/Probation, E) F/Blocked
8. **IP protection level**: A) Full NNN Agreement, B) NDA only, C) Limited Disclosure, D) None/Pending
9. **Communication preference**: A) Email, B) WeChat, C) WhatsApp, D) Phone, E) Mixed
10. **Timezone** — e.g., Asia/Shanghai, Asia/Taipei
11. **Payment terms**: A) Net 30, B) Net 60, C) 50/50 (50% deposit, 50% on ship), D) T/T in advance, E) Custom

Display partner summary card:

```
┌─────────────────────────────────────────────┐
│  Partner: [Name]                            │
│  Location: [City], [Country]                │
│  Contact: [Name] ([preference])             │
│  Capabilities: [list]                       │
│  Lead Times: S:[x]d / M:[x]d / C:[x]d      │
│  Quality: [rating] | IP: [level]            │
│  Payment: [terms]                           │
└─────────────────────────────────────────────┘
```

Ask: "Add another manufacturing partner? (Y/N)"

When done, display full partner roster, confirm, write `partners.yaml`.

---

### Section 5 of 7: Shipping & Logistics

**Read:** `prompts/section-shipping.md` and `references/shipping-defaults.md`.
**Writes:** `~/.reva-turbo/config/shipping-config.yaml`
**Template:** `templates/shipping-config.yaml.tmpl`

1. **Preferred carriers** — multi-select:
   - A) FedEx
   - B) UPS
   - C) DHL
   - D) USPS
   - E) Freight forwarder (specify name)
   - F) Other (specify)

2. **Customs broker**:
   - Name
   - Contact person
   - Phone/email
   - License number (optional)

3. **Origin ports** (select all that apply):
   - A) Shanghai (CNSHA)
   - B) Shenzhen/Yantian (CNSZX)
   - C) Ningbo (CNNGB)
   - D) Qingdao (CNTAO)
   - E) Guangzhou (CNGZH)
   - F) Xiamen (CNXMN)
   - G) Other (specify)

4. **Destination ports** (select all that apply):
   - A) Los Angeles / Long Beach (USLAX)
   - B) Oakland (USOAK)
   - C) Seattle / Tacoma (USSEA)
   - D) Newark / New York (USEWR)
   - E) Savannah (USSAV)
   - F) Houston (USHOU)
   - G) Chicago (inland, USCHI)
   - H) Other (specify)

5. **Default incoterms**: A) FOB, B) CIF, C) DDP, D) EXW, E) FCA, F) DAP
   - Show brief definition from `references/shipping-defaults.md`

6. **Insurance**:
   - Provider name
   - Default coverage: A) Full value, B) 110% value (standard), C) Custom %

7. **Freight forwarder**:
   - Company name
   - Contact person
   - Phone/email

8. **Shipping method by order value**:
   - Under $500: default method (e.g., Express courier)
   - $500-$5,000: default method
   - $5,000-$25,000: default method
   - Over $25,000: default method (e.g., Ocean freight FCL)

Display summary, confirm, write `shipping-config.yaml`.

---

### Section 6 of 7: Documents & Formatting

**Read:** `prompts/section-documents.md`.
**Writes:** `~/.reva-turbo/config/document-config.yaml`
**Template:** `templates/document-config.yaml.tmpl`

1. **Logo path** — Reuse from company profile or specify a different path for documents
2. **Report header text** — e.g., "Rev A Manufacturing — Confidential"
3. **Report footer text** — e.g., "Generated by REVA-TURBO | {date}"
4. **Default output format**: A) .docx, B) .pdf, C) Both
5. **Template overrides directory** — path for custom template files (default: `~/.reva-turbo/templates/`)
6. **Output storage location** — where to save generated reports:
   - Local path (default: `~/Documents/REVA-TURBO-Reports/`)
   - Cloud sync: A) Google Drive, B) OneDrive, C) Dropbox, D) S3, E) None
   - If cloud selected, specify sync folder path
7. **Backup configuration**:
   - Enabled: Y/N
   - Frequency: A) Daily, B) Weekly, C) Monthly
   - Destination: A) Local only, B) Cloud only, C) Both
   - Cloud provider (if applicable)
8. **Document naming convention** — confirm or customize:
   - Default: `REVA-TURBO-{Type}-{YYYY-MM-DD}-{ShortName}.docx`
   - Custom pattern (explain available tokens)

Display summary, confirm, write `document-config.yaml`.

---

### Section 7 of 7: CoWork Space Optimization

**Read:** `prompts/section-cowork.md`.
**Does not write a separate config file** — settings are stored in workflow-config.yaml under a `cowork:` key.

1. **Explain CoWork organization** for REVA-TURBO:
   > Claude CoWork lets you organize AI-assisted projects into separate workspaces. For REVA-TURBO, we recommend:
   > - One project per major customer (for ongoing relationship management)
   > - One "Internal Ops" project (for dashboards, partner management, reporting)
   > - One "Active RFQs" project (for current pipeline)

2. **Auto-create starter projects** — offer to create recommended project names:
   - "REVA-TURBO — Internal Ops"
   - "REVA-TURBO — Active RFQs"
   - "REVA-TURBO — [Customer Name]" (for each team member's top customer)

3. **Pin key skills** — recommend pinning these skills to CoWork sidebar:
   - revmyengine
   - reva-turbo-dashboard
   - reva-turbo-rfq-intake
   - reva-turbo-pulse

4. **Notification preferences for CoWork**:
   - Escalation alerts: A) Immediate, B) Batched hourly, C) Daily digest
   - Order status changes: A) Immediate, B) Batched, C) Off
   - Quality gate results: A) Immediate, B) Batched

Display summary, confirm, update `workflow-config.yaml` with CoWork settings.

---

### Section 8 of 8: Voice & Communication Profile

**Delegates to:** `reva-turbo-voice` skill
**Writes:** `~/.reva-turbo/users/<pm-slug>/voice-profile.yaml`

Explain to the PM:

> **Voice Profile** is how REVA-TURBO learns your communication style. Once set,
> every email draft, customer communication, partner message, and report generated
> by the engine will match your tone, length preference, formality level, and
> personal style — automatically.
>
> This takes about 3 minutes and makes every output feel like it came from you,
> not a template.

Ask:
- A) Set up my voice profile now (recommended)
- B) Skip for now — I'll configure it later with `/reva-turbo:reva-turbo-voice`

**If A:** Invoke `reva-turbo-voice` by reading `~/.claude/skills/reva-turbo/skills/reva-turbo-voice/SKILL.md` and running its setup flow with `mode: setup`. The voice skill handles all questions — do not duplicate its prompts. Let it complete fully, including saving the profile yaml.

After voice setup completes, return to the setup wizard completion flow.

**If B:** Log the skip and remind the PM at completion:
```bash
~/.claude/skills/reva-turbo/bin/reva-turbo-config set section_8_skipped true 2>/dev/null || true
```

Display summary, confirm voice profile path if created.

---

## Completion

After all 8 sections (or all non-skipped sections):

1. **Set setup flag**:
```bash
~/.claude/skills/reva-turbo/bin/reva-turbo-config set setup_completed true 2>/dev/null || true
~/.claude/skills/reva-turbo/bin/reva-turbo-config set setup_date "$(date -u +%Y-%m-%dT%H:%M:%SZ)" 2>/dev/null || true
```

2. **Validate all config files**:
```bash
for f in company-profile workflow-config connector-config partners shipping-config document-config; do
  if [ -f ~/.reva-turbo/config/${f}.yaml ]; then
    bash "${CLAUDE_SKILL_DIR}/bin/validate-config.sh" ~/.reva-turbo/config/${f}.yaml
  fi
done
```

3. **Display completion summary**:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  REVA-TURBO Setup Complete!
  ████████████████ 8/8 sections configured
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Config Files Created:
  ✓ ~/.reva-turbo/config/company-profile.yaml
  ✓ ~/.reva-turbo/config/workflow-config.yaml
  ✓ ~/.reva-turbo/config/connector-config.yaml
  ✓ ~/.reva-turbo/config/partners.yaml
  ✓ ~/.reva-turbo/config/shipping-config.yaml
  ✓ ~/.reva-turbo/config/document-config.yaml
  ✓ ~/.reva-turbo/users/<pm-slug>/voice-profile.yaml

  Skipped Sections: [list any skipped]

  Next Steps:
  1. Run /reva-turbo:reva-turbo-dashboard to see your engine status
  2. Run /reva-turbo:reva-turbo-rfq-intake to process your first RFQ
  3. Run /reva-turbo:reva-turbo-setup section:N to reconfigure any section
  4. Run /reva-turbo:reva-turbo-voice to update your communication profile
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

4. **Log completion**:
```bash
echo '{"event":"setup_complete","ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","sections_completed":"'$_COMPLETED'","sections_skipped":"'$_SKIPPED'"}' >> ~/.reva-turbo/analytics/skill-usage.jsonl 2>/dev/null || true
```

## Skip Behavior

At any section, the PM can say "skip" or "skip this section for now." When skipping:

1. Record the skip: `~/.claude/skills/reva-turbo/bin/reva-turbo-config set "section_N_skipped" "true"`
2. Move to the next section
3. At completion, list skipped sections and remind PM to configure them later via `/setup section:N`

## Validation Rules

After collecting data for each section, before writing the YAML config file:

1. Check all required fields are populated
2. Validate email format (contains @)
3. Validate phone format (digits, dashes, parens, plus sign)
4. Validate URLs (starts with http:// or https://)
5. Validate file paths (no illegal characters)
6. Check for remaining `{{PLACEHOLDER}}` values in rendered template
7. Run `bin/validate-config.sh` on the written file

If validation fails, show errors and ask PM to correct specific fields.

## Security Rules

1. **Never write secrets to YAML files** — API keys, tokens, passwords must be stored as `${ENV_VAR_NAME}` references
2. **Warn before overwriting** — Always confirm before replacing an existing config file
3. **Backup before overwrite** — Copy existing config to `~/.reva-turbo/config/backups/` with timestamp before replacing
4. **File permissions** — Config files should be user-readable only (mode 600)
