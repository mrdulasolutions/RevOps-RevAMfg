---
name: reva-turbo-customer-gate
preamble-tier: 2
version: 1.0.0
description: |
  New customer onboarding gate. Collects customer information, verifies legitimacy,
  sets up CRM records, assigns PM, and establishes credit terms. Required before
  accepting orders from any new customer.
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
echo '{"skill":"reva-turbo-customer-gate","ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"}' >> ~/.reva-turbo/analytics/skill-usage.jsonl 2>/dev/null || true
```

## Purpose

Onboard new customers for Rev A Manufacturing. This skill ensures every new customer is properly vetted, set up in CRM, assigned a PM, and given appropriate credit terms before any order is accepted.

## Prerequisites

This skill is triggered when `reva-turbo-rfq-qualify` identifies a new customer (Gate 1 result = NEW). It can also be invoked directly when a PM needs to onboard a customer outside the RFQ flow.

## Flow

### Step 1: Collect Customer Information

Gather the required information. If an RFQ intake record exists, pre-populate from it. Ask the PM to fill gaps:

> New customer onboarding for **{{CUSTOMER_COMPANY}}**. I need the following information. Please provide what you have:
>
> 1. **Full legal company name:** ___
> 2. **DBA / trade name (if different):** ___
> 3. **Website:** ___
> 4. **Physical address (HQ):** ___
> 5. **Shipping address (if different):** ___
> 6. **Phone (main):** ___
> 7. **Industry / sector:** ___
> 8. **Company size (approximate employees):** ___
> 9. **Primary contact name:** ___
> 10. **Primary contact title:** ___
> 11. **Primary contact email:** ___
> 12. **Primary contact phone:** ___
> 13. **How they found Rev A:** ___
> 14. **BD rep (if applicable):** ___
> 15. **Estimated annual spend potential:** ___
> 16. **DUNS number (if available):** ___

Reference `references/onboarding-checklist.md` for the complete checklist.

### Step 2: Legitimacy Verification

Verify the customer is a legitimate business. Reference `references/legitimacy-checks.md`.

**Automated checks:**
1. **Website exists** — Verify the company has a functioning website
2. **Email domain matches** — Contact email domain matches the company website
3. **Business registration** — Check for a valid business presence (state registration, LinkedIn company page, industry directories)
4. **No red flags** — Screen against known issues (personal email only, PO Box only, no web presence)

**Manual verification (PM to confirm):**

> **Legitimacy Check Results:**
>
> | Check | Result |
> |-------|--------|
> | Website verified | {{WEBSITE_CHECK}} |
> | Email domain match | {{EMAIL_CHECK}} |
> | Business presence confirmed | {{BUSINESS_CHECK}} |
> | Red flag scan | {{RED_FLAG_CHECK}} |
>
> {{LEGITIMACY_COMMENTARY}}
>
> A) Customer passes legitimacy checks — proceed
> B) Concerns identified — proceed with caution
> C) Customer fails checks — escalate to Donovan Weber
> D) Need more information

If B or C, document the concerns and require senior review.

### Step 3: CRM Setup

Set up the customer in CRM. Reference `references/crm-setup.md`.

**Create the following records:**

1. **Account** — New Account record with:
   - Company name, address, phone, website
   - Industry classification
   - Customer type: "New"
   - Source: how they found Rev A
   - BD rep assignment

2. **Contact** — Primary Contact record linked to Account:
   - Name, title, email, phone
   - Mark as primary contact

3. **Relationship** — Set initial relationship fields:
   - Account status: "Onboarding"
   - First contact date
   - Originating RFQ (if applicable)

Log the CRM setup:

```bash
mkdir -p ~/.reva-turbo/customers/{{CUSTOMER_ID}}
echo '{"action":"crm_setup","customer":"{{CUSTOMER_COMPANY}}","customer_id":"{{CUSTOMER_ID}}","ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"}' >> ~/.reva-turbo/state/crm-push-log.jsonl 2>/dev/null || true
```

### Step 4: PM Assignment

Assign a PM based on the assignment logic from CLIENT.md:

1. **Current load** — Check active order counts for Ray Yeh and Harley Scott
2. **Expertise match** — Match PM experience to the type of work requested
3. **Customer relationship** — If a BD rep has a preference, consider it

Present the assignment:

> **PM Assignment Recommendation:**
>
> | PM | Active Orders | Specialty Match | Recommendation |
> |----|--------------|----------------|----------------|
> | Ray Yeh | {{RAY_ACTIVE}} | {{RAY_MATCH}} | {{RAY_REC}} |
> | Harley Scott | {{HARLEY_ACTIVE}} | {{HARLEY_MATCH}} | {{HARLEY_REC}} |
>
> **Recommended PM:** {{RECOMMENDED_PM}}
> **Reason:** {{PM_ASSIGNMENT_REASON}}
>
> A) Accept recommendation
> B) Assign to the other PM
> C) Discuss assignment with Donovan Weber

### Step 5: Credit Terms

Establish initial credit terms for the new customer.

**Standard new customer terms:**
- First order: 50% deposit, 50% upon shipment (prepay)
- After successful first order: Net 30 (pending credit application)
- Credit application required for Net 30 terms

**HUMAN-IN-THE-LOOP CHECKPOINT:**

> **Credit Terms for {{CUSTOMER_COMPANY}}:**
>
> Initial terms: {{INITIAL_TERMS}}
> Credit application: {{CREDIT_APP_STATUS}}
> Estimated first order value: ${{FIRST_ORDER_VALUE}}
>
> For first orders over $25,000, a credit check is recommended before production begins.
>
> A) Accept standard new customer terms (50/50 prepay)
> B) Offer Net 30 immediately (requires Donovan Weber approval)
> C) Require full prepayment
> D) Custom terms (specify)

### Step 6: Onboarding Documentation

Generate the onboarding record using `templates/Customer Onboarding Gate.md`.

**Notify the relevant parties:**
- Assigned PM: New customer assigned
- BD rep (if applicable): Customer onboarded successfully
- Donovan Weber: Only if escalation was triggered in Steps 2 or 5

### Step 7: Save and Route

Save the onboarding record:

```bash
mkdir -p ~/.reva-turbo/customers/{{CUSTOMER_ID}}
```

Log the workflow transition:

```bash
echo '{"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","customer":"{{CUSTOMER_COMPANY}}","customer_id":"{{CUSTOMER_ID}}","stage":"reva-turbo-customer-gate","status":"complete","pm":"{{ASSIGNED_PM}}","next_suggested":"reva-turbo-rfq-quote"}' >> ~/.reva-turbo/state/workflow-state.jsonl 2>/dev/null || true
```

Suggest the next step:

> Customer onboarding complete for {{CUSTOMER_COMPANY}}.
> Assigned PM: {{ASSIGNED_PM}}
> Credit terms: {{CREDIT_TERMS}}
>
> Next step: Return to **quote generation** (reva-turbo-rfq-quote) for RFQ {{RFQ_ID}}. Want me to run it?

## Report Naming

```
REVA-TURBO-CustGate-{YYYY-MM-DD}-{CustomerShortName}.md
```

## Template References

- `prompts/onboarding-system.md` — System prompt for onboarding logic
- `prompts/onboarding-user-template.md` — Onboarding input template
- `references/onboarding-checklist.md` — Complete onboarding checklist
- `references/crm-setup.md` — CRM record creation guide
- `references/legitimacy-checks.md` — Customer verification process
- `templates/Customer Onboarding Gate.md` — Output template
