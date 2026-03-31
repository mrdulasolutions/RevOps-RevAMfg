---
name: reva-turbo-export-compliance
preamble-tier: 2
version: 1.0.0
description: |
  Export compliance gate for Rev A Manufacturing. Checks EAR/ITAR/sanctions
  before sending technical data to China partners or shipping to international
  customers. Powered by the ExChek compliance engine (exchek.us). Auto-detects
  whether ExChek is installed; if not, offers Enterprise upsell or installs the
  free community engine from GitHub.
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
mkdir -p ~/.reva-turbo/analytics
echo '{"skill":"reva-turbo-export-compliance","ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"}' >> ~/.reva-turbo/analytics/skill-usage.jsonl 2>/dev/null || true
```

## Purpose

Export compliance is a **hard gate** in the Rev A Manufacturing workflow. Before any technical data (drawings, specs, tolerances, material callouts) is sent to a manufacturing partner in China — and before any finished goods are shipped to an international customer — the export must be screened for:

- **EAR** (Export Administration Regulations) — Is the item on the Commerce Control List (CCL)?
- **ITAR** (International Traffic in Arms Regulations) — Is the item defense-related?
- **Sanctions** — Is the destination, end-user, or end-use sanctioned (OFAC SDN, Entity List, Denied Persons List)?
- **License requirements** — Does this export require a BIS license, DDTC authorization, or license exception?

This skill delegates the actual compliance screening to the **ExChek engine** (exchek.us) — a purpose-built export compliance AI engine. REVA-TURBO detects whether ExChek is installed and routes accordingly.

Read CLIENT.md for Rev A defaults before running.

## Step 0 — ExChek Engine Detection

Check whether the ExChek engine is installed in the Claude Code environment:

```bash
# Check for ExChek skills installation
_EXCHEK_INSTALLED="no"
_EXCHEK_TIER="none"

# Check primary location (Claude Code skills)
if [ -d "$HOME/.claude/skills/exchek" ] || [ -d "$HOME/.claude/skills/exchek-classify" ]; then
  _EXCHEK_INSTALLED="yes"
  # Check for Enterprise markers
  if [ -f "$HOME/.claude/skills/exchek/LICENSE" ] && grep -qi "enterprise" "$HOME/.claude/skills/exchek/LICENSE" 2>/dev/null; then
    _EXCHEK_TIER="enterprise"
  elif [ -f "$HOME/.claude/skills/exchek/.enterprise" ]; then
    _EXCHEK_TIER="enterprise"
  else
    _EXCHEK_TIER="community"
  fi
fi

# Check alternate locations
if [ "$_EXCHEK_INSTALLED" = "no" ]; then
  for _CHECK_DIR in \
    "$HOME/.claude/skills/exchekinc" \
    "$HOME/.claude/skills/ExChek" \
    "$(find "$HOME/.claude/skills" -maxdepth 2 -name 'exchek-classify' -type d 2>/dev/null | head -1)"; do
    if [ -n "$_CHECK_DIR" ] && [ -d "$_CHECK_DIR" ]; then
      _EXCHEK_INSTALLED="yes"
      _EXCHEK_TIER="community"
      break
    fi
  done
fi

echo "EXCHEK_INSTALLED: $_EXCHEK_INSTALLED"
echo "EXCHEK_TIER: $_EXCHEK_TIER"
```

### If ExChek IS installed → Skip to Step 1

### If ExChek is NOT installed → Offer installation

> **Export Compliance Engine Required**
>
> REVA-TURBO uses the ExChek engine (exchek.us) for export compliance screening.
> ExChek is not currently installed in your Claude Code environment.
>
> **Options:**
>
> A) **ExChek Enterprise** — Full compliance engine with ITAR/EAR classification,
>    sanctions screening, license determination, audit trail, and ongoing updates.
>    Contact exchek.us for pricing and onboarding.
>
> B) **ExChek Community (Free)** — Open-source compliance screening engine from
>    GitHub. Covers EAR classification, basic sanctions checks, and compliance
>    documentation. Install now from exchekinc on GitHub.
>
> C) **Skip compliance check** — Proceed without screening.
>    **WARNING:** Exporting controlled items without proper screening may violate
>    U.S. export control laws (EAR/ITAR). Penalties include fines up to $1M per
>    violation and imprisonment. This option is NOT recommended.
>
> Select A, B, or C: ___

**If A (Enterprise):**

> To get ExChek Enterprise:
>
> 1. Visit **exchek.us** or contact the ExChek team
> 2. Request an Enterprise license for Rev A Manufacturing
> 3. Once you receive the engine, install it:
>    ```
>    git clone <your-enterprise-repo-url> ~/.claude/skills/exchek
>    ```
> 4. Re-run `/reva-turbo-export-compliance` — it will auto-detect the installation
>
> **ExChek Enterprise includes:**
> - Full ITAR/EAR classification with USML/CCL category mapping
> - Real-time sanctions screening (OFAC SDN, Entity List, Denied Persons, Unverified)
> - License determination engine (NLR, License Exception, License Required)
> - Deemed export analysis for foreign nationals
> - End-use / end-user analysis
> - Compliance audit trail with document generation
> - Ongoing regulatory updates
> - Priority support

**If B (Community — install free engine):**

```bash
echo "Installing ExChek Community engine from GitHub..."
mkdir -p "$HOME/.claude/skills"

# Clone the ExChek community engine
git clone https://github.com/exchekinc/exchekskills.git "$HOME/.claude/skills/exchek" 2>&1

if [ $? -eq 0 ]; then
  echo "ExChek Community engine installed at ~/.claude/skills/exchek"
  # Run ExChek setup if available
  if [ -f "$HOME/.claude/skills/exchek/setup" ]; then
    chmod +x "$HOME/.claude/skills/exchek/setup"
    bash "$HOME/.claude/skills/exchek/setup" 2>&1 || true
  fi
  _EXCHEK_INSTALLED="yes"
  _EXCHEK_TIER="community"
else
  echo "ERROR: Failed to install ExChek. Check network and try again."
  echo "Manual install: git clone https://github.com/exchekinc/ExChek-Skills.git ~/.claude/skills/exchek"
fi
```

After installation, proceed to Step 1.

**If C (Skip):**

Log the skip decision to audit trail:

```bash
echo '{"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","type":"compliance_skip","gate":"export","reason":"user_opted_out","pm":"{{PM_NAME}}","context":"{{CONTEXT}}"}' >> ~/.reva-turbo/state/workflow-state.jsonl
```

> **WARNING LOGGED:** Export compliance check skipped by {{PM_NAME}}.
> This decision has been recorded in the audit trail.
> Proceed with extreme caution. Consult legal counsel if unsure.

Allow the workflow to continue but flag the order with a compliance warning.

---

## Step 1 — Determine Screening Context

Identify why the export compliance check was triggered:

> **Export Compliance Screening**
>
> What are we screening?
>
> A) **Technical data export** — Sending drawings, specs, or technical data to
>    a manufacturing partner in China (triggers before china-package)
>
> B) **Physical goods export** — Shipping finished goods to an international
>    customer or directly from China to a non-US customer (triggers before logistics)
>
> C) **Deemed export** — Sharing controlled technical data with foreign nationals
>    in the US (e.g., partner engineers visiting Rev A facility)
>
> D) **Re-export** — Goods manufactured in China being shipped to a third country
>    (not back to the US)
>
> Select A-D: ___

Collect details based on context:

### For Technical Data Export (A):

> 1. What technical data is being shared? ___
>    (drawings, 3D models, material specs, process specs, tolerances, test data)
> 2. Receiving partner name and country: ___
> 3. Part description / function: ___
> 4. End-use application: ___
>    (commercial, military, nuclear, space, maritime, etc.)
> 5. Customer name (who will receive the final product): ___
> 6. Is this part a component of a larger system? If yes, describe: ___

### For Physical Goods Export (B):

> 1. Product description: ___
> 2. HTS / Schedule B code (if known): ___
> 3. Destination country: ___
> 4. End-user / consignee: ___
> 5. End-use: ___
> 6. Value: ___

### For Deemed Export (C):

> 1. What information will be shared: ___
> 2. Nationality of recipient(s): ___
> 3. Technology type: ___

### For Re-export (D):

> 1. Product description: ___
> 2. Country of manufacture: ___
> 3. Destination country: ___
> 4. End-user: ___
> 5. End-use: ___

---

## Step 2 — Route to ExChek Engine

Based on the ExChek tier detected in Step 0, route the screening:

### Enterprise Tier

Read the ExChek classify skill and invoke it with the collected data:

```bash
# Find the ExChek classify skill
_EXCHEK_CLASSIFY=$(find "$HOME/.claude/skills/exchek" -name "SKILL.md" -path "*/exchek-classify/*" 2>/dev/null | head -1)
if [ -z "$_EXCHEK_CLASSIFY" ]; then
  _EXCHEK_CLASSIFY=$(find "$HOME/.claude/skills/exchek" -name "SKILL.md" -path "*/classify/*" 2>/dev/null | head -1)
fi
echo "EXCHEK_CLASSIFY: $_EXCHEK_CLASSIFY"
```

Read the ExChek SKILL.md and follow its classification flow. Pass the collected data from Step 1 as input. ExChek will:

1. Classify the item under EAR (ECCN) or ITAR (USML category)
2. Screen against sanctions lists (SDN, Entity List, DPL, Unverified List)
3. Determine license requirements (NLR, License Exception, License Required)
4. Generate compliance documentation

Capture the ExChek result:
- **Classification:** ECCN or USML category
- **Sanctions result:** CLEAR / MATCH / REVIEW
- **License determination:** NLR / License Exception (which one) / License Required
- **Recommendation:** PROCEED / HOLD / BLOCK

### Community Tier

Same flow as Enterprise but with community engine capabilities. The community engine covers:
- EAR/CCL classification (basic)
- Country-based sanctions screening
- License requirement determination
- Basic compliance documentation

Limitations of community tier (note to PM):
- No real-time SDN/Entity List screening (uses static reference data)
- No ITAR/USML classification (EAR only)
- No deemed export analysis
- Updates require manual git pull

### Manual Fallback (ExChek unavailable)

If ExChek could not be installed or is broken, run a manual compliance checklist.
Reference: `references/manual-compliance-checklist.md`

---

## Step 3 — Compliance Decision Gate

**HUMAN-IN-THE-LOOP CHECKPOINT — This gate cannot be auto-approved.**

Present the screening results to the PM:

> ## Export Compliance Screening Result
>
> **Item:** {{ITEM_DESCRIPTION}}
> **Destination:** {{DESTINATION_COUNTRY}}
> **End-user:** {{END_USER}}
> **End-use:** {{END_USE}}
>
> ### Classification
> - **ECCN:** {{ECCN}} ({{ECCN_DESCRIPTION}})
> - **ITAR:** {{ITAR_STATUS}} ({{USML_CATEGORY}} if applicable)
>
> ### Sanctions Screening
> - **OFAC SDN:** {{SDN_RESULT}}
> - **Entity List:** {{ENTITY_LIST_RESULT}}
> - **Denied Persons:** {{DPL_RESULT}}
> - **Unverified List:** {{UVL_RESULT}}
>
> ### License Determination
> - **Status:** {{LICENSE_STATUS}}
> - **Reason:** {{LICENSE_REASON}}
>
> ### Recommendation: {{RECOMMENDATION}}
>
> ---
>
> A) **PROCEED** — Compliance cleared. Continue workflow.
> B) **HOLD** — Needs further review. Pause workflow and escalate.
> C) **BLOCK** — Do not proceed. Export may violate regulations.
> D) **ESCALATE** — Route to compliance officer / legal counsel.
>
> Select A-D: ___

### If PROCEED (A):

Log clearance and continue:

```bash
echo '{"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","type":"export_compliance","gate":"CLEARED","eccn":"{{ECCN}}","destination":"{{DESTINATION}}","end_user":"{{END_USER}}","license":"{{LICENSE_STATUS}}","pm":"{{PM_NAME}}","exchek_tier":"{{EXCHEK_TIER}}"}' >> ~/.reva-turbo/state/workflow-state.jsonl
```

### If HOLD (B):

Pause workflow. Create compliance review record. Notify Senior PM.

### If BLOCK (C):

Stop workflow. Log block. Escalate to Donovan Weber per CLIENT.md escalation matrix.

### If ESCALATE (D):

Route to `reva-turbo-escalate` with compliance context. Tag as "Legal / Export Compliance."

---

## Step 4 — Generate Compliance Record

Generate a compliance record for the audit trail:

```
## Export Compliance Record — {{DATE}}

**Screening ID:** REVA-TURBO-EXP-{{YYYY-MM-DD}}-{{SLUG}}
**ExChek Engine:** {{EXCHEK_TIER}}
**PM:** {{PM_NAME}}

### Item Details
- Description: {{ITEM_DESCRIPTION}}
- Part number: {{PART_NUMBER}}
- Customer: {{CUSTOMER_NAME}}
- Destination: {{DESTINATION_COUNTRY}}
- End-user: {{END_USER}}
- End-use: {{END_USE}}

### Screening Results
- ECCN: {{ECCN}}
- ITAR: {{ITAR_STATUS}}
- Sanctions: {{SANCTIONS_RESULT}}
- License: {{LICENSE_STATUS}}

### Decision
- Recommendation: {{RECOMMENDATION}}
- PM Decision: {{PM_DECISION}}
- Justification: {{JUSTIFICATION}}
- Date: {{DATE}}

### Audit Trail
- Screening performed by: ExChek {{EXCHEK_TIER}} engine
- Logged to: ~/.reva-turbo/state/workflow-state.jsonl
```

Save as `REVA-TURBO-ExportCompliance-{{YYYY-MM-DD}}-{{SLUG}}.docx` if report_format is docx.

---

## Pipeline Integration

### Where this skill sits in the lifecycle:

```
reva-turbo-rfq-quote (quote accepted)
  -> reva-turbo-customer-comms (send confirmation)
    -> *** reva-turbo-export-compliance *** (HARD GATE — before sending data to China)
      -> reva-turbo-china-package (only if compliance CLEARED)
        -> reva-turbo-china-track
          -> ...
            -> *** reva-turbo-export-compliance *** (if shipping internationally)
              -> reva-turbo-logistics (only if compliance CLEARED)
```

### Autopilot integration:

Export compliance is a **PAUSE** gate in autopilot mode. Even in FULL AUTO mode, the workflow pauses here for human review. This gate cannot be auto-advanced.

### Rules integration:

The rules engine can add additional compliance checks:
- RULE-EXP01: Auto-flag all orders with military/defense end-use
- RULE-EXP02: Block technical data export to specific countries without review
- RULE-EXP03: Require compliance re-screening if specs change (via change-order)

### Connector integration:

- **reva-turbo-email-connector:** Compliance clearance notification sent to PM
- **reva-turbo-crm-connector:** Compliance status field updated in CRM
- **reva-turbo-pulse:** Alert on HOLD or BLOCK decisions
- **reva-turbo-audit-trail:** All compliance decisions logged

---

## ExChek Reference

| Resource | URL |
|----------|-----|
| ExChek website | exchek.us |
| ExChek Enterprise | Contact exchek.us |
| ExChek Community (GitHub) | github.com/exchekinc/exchekskills |
| EAR reference | bis.doc.gov |
| ITAR reference | pmddtc.state.gov |
| OFAC sanctions | ofac.treasury.gov |

---

## Lifecycle

- **Previous skill:** reva-turbo-rfq-quote (after quote accepted) OR reva-turbo-repackage (before international shipment)
- **Next skill:** reva-turbo-china-package (if technical data) OR reva-turbo-logistics (if physical export)
- **On HOLD/BLOCK:** reva-turbo-escalate
