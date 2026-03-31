---
name: pmlord-rfq-intake
preamble-tier: 2
version: 1.0.0
description: |
  Parse incoming RFQs from email, website, or CRM. Extract structured data
  (customer, part description, quantity, material, tolerances, drawings, timeline)
  into a standardized intake record. Push to CRM and route to qualification.
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
mkdir -p ~/.pmlord/analytics
echo '{"skill":"pmlord-rfq-intake","ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"}' >> ~/.pmlord/analytics/skill-usage.jsonl 2>/dev/null || true
```

## Purpose

Parse incoming RFQ data from any source (email, website form, CRM entry, forwarded message) into a structured Rev A Manufacturing intake record. Every field must be captured or explicitly marked as missing so the PM can follow up before qualification.

## Flow

### Step 1: Data Sensitivity Check

Before processing the RFQ content, verify:

1. **Source authorization** — Confirm the PM has authorization to process this RFQ. If the source is unclear, ask:

> This RFQ content may contain proprietary specifications. Confirm you are authorized to process this request.
> A) Yes, proceed
> B) Let me check first

If B, stop and wait.

2. **NDA check** — If the customer name is recognized as having an NDA on file, flag it:

> **NDA Alert:** {{CUSTOMER_COMPANY}} has an NDA on file. All extracted data must be handled per NDA terms. Do not share specs with manufacturing partners until NDA compliance is confirmed.

3. **PII scan** — If the RFQ text contains personal information beyond standard business contact info (SSNs, personal addresses, financial data), flag it and recommend redaction before proceeding.

### Step 2: Source Identification

Determine the RFQ source and tag it:

| Source | Identifier | Notes |
|--------|-----------|-------|
| Email | `email` | Forwarded or pasted email content |
| Website | `website` | revamfg.com contact/RFQ form submission |
| CRM | `crm` | Entry from Power Apps / Dynamics 365 |
| Phone | `phone` | PM transcribing a phone inquiry |
| Referral | `referral` | Forwarded from BD team or existing customer |
| Trade show | `tradeshow` | Lead from trade show or event |

Ask the PM if the source is ambiguous:

> Where did this RFQ come from?
> A) Email
> B) Website (revamfg.com)
> C) CRM (Power Apps / Dynamics 365)
> D) Phone call
> E) Referral from BD or customer
> F) Trade show / event

### Step 3: RFQ Data Extraction

Read the provided RFQ content and extract all fields listed in `prompts/rfq-user-template.md`. Use the system prompt from `prompts/rfq-extraction-system.md` to guide extraction logic.

For each field, either:
- **Extract** the value from the RFQ text
- **Infer** the value with a confidence note (e.g., "Inferred from email domain: Acme Corp")
- **Mark missing** with `[MISSING — follow up required]`

Required fields that trigger a follow-up flag if missing:
- Customer company name
- Contact name and email
- Part description or drawing reference
- Quantity
- Delivery timeline

### Step 4: Structured Output

Use the template from `templates/RFQ Intake Record.md` to generate the structured intake record. Fill all `{{PLACEHOLDER}}` variables with extracted data.

**HUMAN-IN-THE-LOOP CHECKPOINT:**

Present the completed intake record to the PM and ask:

> I have extracted the following RFQ data. Please review:
>
> **Customer:** {{CUSTOMER_COMPANY}}
> **Contact:** {{CONTACT_NAME}} ({{CONTACT_EMAIL}})
> **Part:** {{PART_DESCRIPTION}}
> **Qty:** {{QUANTITY}}
> **Timeline:** {{DELIVERY_TIMELINE}}
>
> Missing fields: [list any MISSING fields]
>
> A) Looks good — save and continue to qualification
> B) I need to correct some fields
> C) Cancel — do not process this RFQ

If B, ask which fields need correction and update the record.

### Step 5: CRM Push

If CRM integration is configured (`_CRM_TYPE` is not `none`), push the structured record to CRM:

```bash
echo '{"action":"crm_push","skill":"pmlord-rfq-intake","rfq_id":"{{RFQ_ID}}","customer":"{{CUSTOMER_COMPANY}}","ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"}' >> ~/.pmlord/state/crm-push-log.jsonl 2>/dev/null || true
```

Reference `references/rfq-field-mapping.md` for CRM field mapping. If CRM is not configured, save the intake record to:

```
~/.pmlord/rfqs/{{RFQ_ID}}/intake-record.md
```

### Step 6: Route to Qualification

After saving the intake record, log the workflow transition:

```bash
echo '{"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","rfq_id":"{{RFQ_ID}}","customer":"{{CUSTOMER_COMPANY}}","stage":"pmlord-rfq-intake","status":"complete","pm":"{{ASSIGNED_PM}}","next_suggested":"pmlord-rfq-qualify"}' >> ~/.pmlord/state/workflow-state.jsonl 2>/dev/null || true
```

Then suggest the next step:

> RFQ intake complete for {{CUSTOMER_COMPANY}}. Next step: **Qualification gate check** (pmlord-rfq-qualify). Want me to run it?

## Report Naming

Save the intake record as:
```
PMLORD-RFQIntake-{YYYY-MM-DD}-{CustomerShortName}.md
```

## Template References

- `prompts/rfq-extraction-system.md` — System prompt for RFQ parsing
- `prompts/rfq-user-template.md` — Field extraction template
- `references/rfq-field-mapping.md` — CRM field mapping
- `references/email-patterns.md` — Common RFQ email patterns
- `references/data-sensitivity.md` — Customer data handling rules
- `templates/RFQ Intake Record.md` — Output template
