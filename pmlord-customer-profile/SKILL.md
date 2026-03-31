---
name: pmlord-customer-profile
preamble-tier: 2
version: 1.0.0
description: |
  Build and maintain customer profiles for Rev A Manufacturing. Aggregates order
  history, preferences, quality requirements, payment terms, communication
  preferences, and relationship intelligence into a living profile document.
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
echo '{"skill":"pmlord-customer-profile","ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"}' >> ~/.pmlord/analytics/skill-usage.jsonl 2>/dev/null || true
```

## Purpose

Build, update, and maintain comprehensive customer profiles for Rev A Manufacturing. A customer profile is a living document that gives any PM instant context on a customer: who they are, what they buy, how they pay, what they care about, and how to work with them.

## Flow

### Step 1: Identify Customer

Determine which customer profile to build or update.

If customer name is provided, search for an existing profile:

```bash
ls ~/.pmlord/customers/ 2>/dev/null
```

If a profile exists, load it for update. If not, check if onboarding has been completed:

> I am looking for a customer profile for **{{CUSTOMER_COMPANY}}**.
>
> A) This is a new profile — build it from scratch
> B) This is an existing profile — update it with new information
> C) Search for a different customer

If A and no onboarding record exists, recommend running `pmlord-customer-gate` first.

### Step 2: Gather Profile Data

Collect information from all available sources. Reference `references/profile-fields.md` for the complete field list.

**From CRM / existing records:**
- Company information (from onboarding or CRM)
- Contact list (all known contacts)
- Order history (all RFQs, quotes, orders)
- Payment history (invoices, payment timing)
- Quality records (NCRs, returns, complaints)

**From PM knowledge (ask the PM):**

> Building the profile for {{CUSTOMER_COMPANY}}. Please share any information you have on:
>
> 1. **Key contacts and their roles** (buyer, engineer, quality, exec): ___
> 2. **Preferred communication method** (email, phone, in-person): ___
> 3. **Decision-making process** (who approves POs, who has authority): ___
> 4. **Quality expectations** (strict inspector, flexible, requires certs): ___
> 5. **Pricing sensitivity** (price-driven, value-driven, relationship-driven): ___
> 6. **Industry / end application** for their parts: ___
> 7. **Typical order patterns** (quarterly, project-based, steady flow): ___
> 8. **Any special requirements or preferences**: ___
> 9. **Relationship notes** (rapport, challenges, opportunities): ___
> 10. **Competitors we beat or lost to**: ___

### Step 3: Build Order History

Aggregate all order data for this customer. For each order, capture:

| Field | Value |
|-------|-------|
| Order/RFQ ID | {{ORDER_ID}} |
| Date | {{ORDER_DATE}} |
| Part description | {{PART_DESC}} |
| Process | {{PROCESS}} |
| Quantity | {{QTY}} |
| Order value | ${{ORDER_VALUE}} |
| Status | {{STATUS}} |
| Quality result | {{QUALITY_RESULT}} |
| On-time delivery | {{ON_TIME}} |
| PM | {{PM}} |

Calculate summary metrics:
- Total lifetime value
- Average order value
- Order frequency
- On-time delivery rate
- Quality pass rate (first-time acceptance)
- Payment on-time rate

### Step 4: Analyze Patterns and Preferences

Based on order history and PM input, identify:

**Purchasing patterns:**
- Typical order size and frequency
- Seasonal trends (if any)
- Preferred processes and materials
- Price sensitivity level

**Quality profile:**
- Typical tolerance requirements
- Required quality documentation (CoC, FAIR, PPAP, material certs)
- Inspection standards (visual, dimensional, functional)
- History of quality issues or NCRs

**Communication preferences:**
- Primary and secondary contacts
- Preferred communication channel (email, phone, video call)
- Response time expectations
- Technical vs. commercial focus
- Escalation sensitivity

**Relationship intelligence:**
- Decision-making process and authority
- Budget cycle and timing
- Growth potential
- Competitive landscape (who else they buy from)
- Relationship strength (strong, moderate, developing, at risk)

### Step 5: Set Customer Tier

Based on the profile data, recommend a customer tier:

| Tier | Criteria | Service Level |
|------|----------|--------------|
| **Platinum** | > $200K annual spend, 3+ year relationship, growth potential | Highest priority, dedicated PM, quarterly reviews |
| **Gold** | $50K-200K annual spend, 1+ year relationship | High priority, regular check-ins |
| **Silver** | $10K-50K annual spend, any relationship length | Standard service, periodic check-ins |
| **Bronze** | < $10K annual spend | Standard service |
| **New** | No completed orders yet | Onboarding service level |

Present the recommendation:

> **Customer Tier Recommendation:** {{TIER}}
> **Rationale:** {{TIER_RATIONALE}}
>
> A) Accept tier assignment
> B) Override tier (specify)

### Step 6: Generate Profile Document

**HUMAN-IN-THE-LOOP CHECKPOINT:**

Present the completed profile summary:

> ## Customer Profile: {{CUSTOMER_COMPANY}}
>
> **Tier:** {{TIER}}
> **Assigned PM:** {{ASSIGNED_PM}}
> **Lifetime Value:** ${{LIFETIME_VALUE}}
> **Relationship:** {{RELATIONSHIP_STRENGTH}}
>
> **Key Contacts:** {{KEY_CONTACTS_SUMMARY}}
> **Typical Orders:** {{ORDER_PATTERN_SUMMARY}}
> **Quality Profile:** {{QUALITY_SUMMARY}}
>
> A) Save this profile
> B) Add or correct information
> C) Cancel

Use `templates/Customer Profile.md` to generate the full profile document.

### Step 7: Save and Sync

Save the profile:

```bash
mkdir -p ~/.pmlord/customers/{{CUSTOMER_ID}}
```

Reference `references/crm-field-mapping.md` for CRM sync mapping. If CRM is configured, push the profile summary to CRM.

Log the action:

```bash
echo '{"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","customer":"{{CUSTOMER_COMPANY}}","customer_id":"{{CUSTOMER_ID}}","stage":"pmlord-customer-profile","status":"{{PROFILE_ACTION}}","pm":"{{ASSIGNED_PM}}"}' >> ~/.pmlord/state/workflow-state.jsonl 2>/dev/null || true
```

## Profile Maintenance

Profiles should be updated:
- After every completed order
- After any quality issue or NCR
- After any change in contacts or payment terms
- During quarterly account reviews (Platinum/Gold customers)
- When the PM learns new relationship intelligence

When updating an existing profile, show what changed:

> **Profile Updated:** {{CUSTOMER_COMPANY}}
> Changes:
> - [field]: [old value] -> [new value]
> - [new information added]

## Report Naming

```
PMLORD-CustProfile-{YYYY-MM-DD}-{CustomerShortName}.md
```

## Template References

- `prompts/profile-system.md` — System prompt for profile building
- `prompts/profile-user-template.md` — Profile input template
- `references/profile-fields.md` — Complete field reference
- `references/crm-field-mapping.md` — CRM sync mapping
- `templates/Customer Profile.md` — Output template
