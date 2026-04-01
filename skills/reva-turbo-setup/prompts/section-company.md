# Section 1 of 7: Company Profile

## Overview

Collect the company's identity, contact information, team roster, and escalation matrix. This information drives report headers, email signatures, CRM records, and escalation routing across all REVA-TURBO skills.

## Questions

### Q1: Company Legal Name (required)

> What is the company's full legal name?
> Example: "Rev A Manufacturing LLC"

Validation: Non-empty string. Strip leading/trailing whitespace.

### Q2: DBA / Doing Business As (optional)

> Does the company operate under a different name (DBA)?
> A) Same as legal name
> B) Different — please specify

If B, collect the DBA name. If A, set DBA = legal name.

### Q3: Company Address (required)

> Enter the company's primary business address:
> - Street address:
> - City:
> - State/Province:
> - ZIP/Postal Code:
> - Country:

Collect as a multi-line grouped question. All fields required except State (some countries don't use states).

### Q4: Phone Number (required)

> Company main phone number:
> Example: +1 (555) 123-4567

Validation: Must contain digits. Allow +, (, ), -, spaces, dots.

### Q5: Fax Number (optional)

> Fax number (or press Enter to skip):

### Q6: Website (required)

> Company website URL:
> Example: https://www.revamfg.com

Validation: Must start with http:// or https://. If user enters without protocol, prepend https://.

### Q7: Company Logo Path (optional)

> Path to the company logo file (used in report headers):
> Example: ~/Documents/logos/reva-logo.png
> (Enter "later" to set this up after setup)

Validation: If provided, check file exists. Accept "later" to skip.

### Q8: Default Timezone (required)

> What is the company's default timezone?
> A) US/Eastern (ET)
> B) US/Central (CT)
> C) US/Mountain (MT)
> D) US/Pacific (PT)
> E) UTC
> F) Other — please specify (e.g., Asia/Shanghai, Europe/London)

Map selection to IANA timezone string.

### Q9: Fiscal Year Start Month (required)

> What month does the fiscal year start?
> Default is January (1). Enter a number 1-12.

Validation: Integer 1-12. Default: 1.

---

## Team Members

Collect team members in a loop. At least one team member is required (the PM running setup).

### Per-member questions:

> **Team Member [N]:**
> - Full name:
> - Role:
>   A) Project Manager
>   B) Engineer
>   C) Quality Control
>   D) Executive
>   E) Admin
>   F) Other (specify)
> - Email:
> - Phone (optional):

Validation:
- Name: required, non-empty
- Role: must be one of the lettered options
- Email: required, must contain @
- Phone: optional, same format rules as company phone

After each member:
> Add another team member? (Y/N)

Continue until N.

---

## Escalation Matrix

The REVA-TURBO escalation matrix has 4 levels. Each level needs a name and email. The person can be from the team roster or someone not yet listed.

> **Escalation Matrix**
> This defines who gets escalated to when issues arise. Per CLIENT.md, Donovan Weber is the final escalation.
>
> Level 1 — Project Manager (first responder):
> - Name:
> - Email:
>
> Level 2 — PM Manager (if PM cannot resolve within SLA):
> - Name:
> - Email:
>
> Level 3 — VP Operations (if PM Manager cannot resolve):
> - Name:
> - Email:
>
> Level 4 — CEO (final escalation):
> - Name:
> - Email:

Validation: All names and emails are required for all 4 levels.

---

## Summary Display

After collecting all data, display:

```
┌─────────────────────────────────────────────────────┐
│  COMPANY PROFILE SUMMARY                            │
├──────────────────┬──────────────────────────────────┤
│  Legal Name      │  [value]                         │
│  DBA             │  [value]                         │
│  Address         │  [street]                        │
│                  │  [city], [state] [zip]            │
│                  │  [country]                       │
│  Phone           │  [value]                         │
│  Fax             │  [value or "N/A"]                │
│  Website         │  [value]                         │
│  Logo            │  [path or "Not set"]             │
│  Timezone        │  [value]                         │
│  Fiscal Year     │  Starts [month name]             │
├──────────────────┴──────────────────────────────────┤
│  TEAM ([N] members)                                 │
├──────────────────┬──────────────────────────────────┤
│  [Name]          │  [Role] — [email]                │
│  [Name]          │  [Role] — [email]                │
├──────────────────┴──────────────────────────────────┤
│  ESCALATION MATRIX                                  │
├──────────────────┬──────────────────────────────────┤
│  L1 (PM)         │  [name] — [email]                │
│  L2 (Mgr)        │  [name] — [email]                │
│  L3 (VP)         │  [name] — [email]                │
│  L4 (CEO)        │  [name] — [email]                │
└──────────────────┴──────────────────────────────────┘
```

Then ask:
> Does this look correct?
> A) Yes, save it
> B) Edit a field (specify which)
> C) Start this section over

## Output

Write to `~/.reva-turbo/config/company-profile.yaml` using `templates/company-profile.yaml.tmpl`.
