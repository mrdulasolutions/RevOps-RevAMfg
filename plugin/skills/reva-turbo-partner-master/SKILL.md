---
name: reva-turbo-partner-master
preamble-tier: 2
version: 1.0.0
description: |
  Maintain the authoritative manufacturing partner record — capabilities,
  certifications, contacts, location, payment terms, IP agreements, active orders,
  and performance history. Used by reva-turbo-partner-select and
  reva-turbo-partner-scorecard.
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
mkdir -p ~/.reva-turbo/analytics ~/.reva-turbo/config ~/.reva-turbo/state
echo '{"skill":"reva-turbo-partner-master","ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"}' >> ~/.reva-turbo/analytics/skill-usage.jsonl 2>/dev/null || true
```

## Purpose

Maintain the authoritative manufacturing partner record for Rev A Manufacturing. The master partner file (`~/.reva-turbo/config/partners.yaml`) is the single source of truth for partner capabilities, certifications, contacts, location, payment terms, IP agreements, and quality ratings. This skill provides CRUD operations on the partner master and feeds reva-turbo-partner-select and reva-turbo-partner-scorecard.

## State Files

| File | Purpose |
|------|---------|
| `~/.reva-turbo/config/partners.yaml` | Master partner record (authoritative) |
| `~/.reva-turbo/state/partner-history.jsonl` | Partner event log — orders, score changes, NCRs, contacts |

## Partner Record Schema

Each partner in partners.yaml follows this structure:

```yaml
partners:
  - slug: shenzhen-precision           # URL-safe identifier
    name: Shenzhen Precision Machining
    location:
      city: Shenzhen
      province: Guangdong
      country: CN
    processes:                          # Manufacturing capabilities
      - CNC machining
      - surface grinding
      - EDM
    materials:
      - aluminum
      - stainless steel
      - titanium
    certifications:
      - ISO 9001:2015
      - IATF 16949
    quality_rating: A                   # A / B / C / D / F
    quality_hold: false                 # true if active hold
    ip_agreements:
      nnn: true
      nda: true
      nnn_expiry: 2028-01-15
    payment_terms: net-30
    currency: USD                       # preferred invoice currency
    contacts:
      - name: Wang Fang
        title: Sales Manager
        email: wfang@shenzhen-prec.com
        phone: "+86-755-XXXX-XXXX"
        wechat: wangfang_sp
        preferred_channel: wechat
      - name: Liu Chen
        title: Quality Manager
        email: lchen@shenzhen-prec.com
        preferred_channel: email
    lead_time_standard_days: 25
    lead_time_tooling_days: 45
    min_order_qty: 1
    active: true
    notes: "Primary CNC partner for aluminum and stainless. Strong on tight tolerances."
    added_date: 2024-03-15
    last_updated: 2026-01-10
```

## Flow

### Step 1 — Parse Command

Detect the function requested:

- `view <partner-name>` → Step 2
- `add` → Step 3
- `update <partner-name> <field> <value>` → Step 4
- `capability-search <process>` → Step 5
- `certifications` → Step 6
- `contacts` → Step 7
- No argument → show menu

> Partner Master action:
>
> A) View a partner profile
> B) Add a new partner
> C) Update a partner field
> D) Search by capability
> E) List partners by certification
> F) View all partner contacts

### Step 2 — View Partner Profile (`view <partner-name>`)

```bash
_PARTNER="{{PARTNER_SLUG_OR_NAME}}"
grep -A 60 "slug: $_PARTNER\|name: .*$_PARTNER" ~/.reva-turbo/config/partners.yaml 2>/dev/null | head -60
```

Also pull recent history:

```bash
grep "\"partner\":\"$_PARTNER\"" ~/.reva-turbo/state/partner-history.jsonl 2>/dev/null | tail -10
```

Present a formatted partner profile card:

> **Partner Profile: {{PARTNER_NAME}}**
>
> Location: {{CITY}}, {{COUNTRY}}
> Quality Rating: {{RATING}} {{HOLD_FLAG}}
> IP Agreements: {{NNN_STATUS}} / {{NDA_STATUS}}
> Certifications: {{CERT_LIST}}
> Processes: {{PROCESS_LIST}}
> Standard Lead Time: {{LEAD_TIME}} days
> Payment Terms: {{PAYMENT_TERMS}}
>
> **Contacts:**
> | Name | Title | Channel | Contact |
> |------|-------|---------|---------|
> | {{NAME}} | {{TITLE}} | {{CHANNEL}} | {{CONTACT}} |
>
> **Recent History (last 10 events):**
> {{HISTORY_LIST}}

### Step 3 — Add New Partner (`add`)

Collect partner data interactively:

Ask PM for each field in the partner schema. Required fields:
- Partner name (will generate slug automatically)
- City, country
- Primary processes (list)
- Materials (list)
- Quality rating (A/B/C/D/F) — default B for new partners
- IP agreements (NNN, NDA, none)
- Payment terms
- At least one contact (name, email, preferred channel)

After collecting all data, present for review:

> **New Partner Record Review:**
>
> {{FORMATTED_PARTNER_CARD}}
>
> A) Confirm and save to partners.yaml
> B) Edit a field before saving
> C) Cancel

On confirmation, append to partners.yaml and log:

```bash
echo '{"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","event":"partner_added","partner":"{{SLUG}}","pm":"{{PM_NAME}}"}' >> ~/.reva-turbo/state/partner-history.jsonl
```

### Step 4 — Update Partner Field (`update <partner-name> <field> <value>`)

```bash
_PARTNER="{{PARTNER_SLUG}}"
_FIELD="{{FIELD}}"
_VALUE="{{VALUE}}"
# Edit the field in partners.yaml
# Log the change
echo '{"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","event":"partner_updated","partner":"'"$_PARTNER"'","field":"'"$_FIELD"'","old_value":"{{OLD}}","new_value":"'"$_VALUE"'","pm":"{{PM_NAME}}"}' >> ~/.reva-turbo/state/partner-history.jsonl
```

**Protected fields:** `quality_rating` and `quality_hold` changes require PM confirmation and are always logged to both partner-history.jsonl and audit-trail.jsonl.

### Step 5 — Capability Search (`capability-search <process>`)

```bash
_PROCESS="{{PROCESS}}"
grep -B 5 -A 30 "processes:" ~/.reva-turbo/config/partners.yaml 2>/dev/null | grep -B 5 "$_PROCESS" | grep "name:"
```

Present all partners with the matching capability, sorted by quality rating.

### Step 6 — Certifications (`certifications`)

```bash
grep -E "name:|certifications:|  - (ISO|IATF|AS9100|NADCAP|UL)" ~/.reva-turbo/config/partners.yaml 2>/dev/null
```

Present a table:

> **Partners by Certification**
>
> | Certification | Partners |
> |--------------|---------|
> | ISO 9001:2015 | {{LIST}} |
> | IATF 16949 | {{LIST}} |
> | AS9100 Rev D | {{LIST}} |
> | NADCAP | {{LIST}} |
> | UL Listed | {{LIST}} |

### Step 7 — Contacts (`contacts`)

```bash
grep -E "name:|email:|phone:|wechat:|preferred_channel:" ~/.reva-turbo/config/partners.yaml 2>/dev/null
```

Present a complete contact directory:

> **Partner Contact Directory**
>
> | Partner | Contact Name | Title | Preferred Channel | Contact Info |
> |---------|-------------|-------|-------------------|--------------|
> | {{PARTNER}} | {{NAME}} | {{TITLE}} | {{CHANNEL}} | {{EMAIL/WECHAT/PHONE}} |

## Rules

1. **partners.yaml is authoritative.** All skills that need partner data read from this file. Do not create shadow copies.
2. **Quality rating changes are logged.** Every change to `quality_rating` or `quality_hold` is written to both partner-history.jsonl and audit-trail.jsonl.
3. **Slug is immutable.** Once set, a partner slug does not change — it is used as a foreign key across state files.
4. **Contacts are confidential.** Partner contact info (email, phone, WeChat) is internal to Rev A. Never include in customer-facing documents.
5. **HITL for F-rating.** Setting a partner to F rating requires PM confirmation and a mandatory notes field explaining the reason.

## Lifecycle

**Read by:** reva-turbo-partner-select (capability matching and scoring), reva-turbo-partner-scorecard (performance evaluation), reva-turbo-china-package (partner contact for package delivery)

**Written by:** PM via this skill, reva-turbo-partner-scorecard (updates quality_rating after scorecard review)
