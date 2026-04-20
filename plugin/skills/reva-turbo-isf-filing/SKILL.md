---
name: reva-turbo-isf-filing
preamble-tier: 2
version: 1.0.0
description: |
  Manage Importer Security Filing (ISF / CBP 10+2) for all ocean freight shipments.
  Triggered by reva-turbo-logistics when shipping mode is Sea FCL or LCL. Ensures
  CBP 10+2 data is collected and filed at least 24 hours before vessel departure.
  Rev A Manufacturing is the Importer of Record. Penalty for late/missing ISF: $5,000
  per violation.
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
mkdir -p ~/.reva-turbo/analytics ~/.reva-turbo/state
echo '{"skill":"reva-turbo-isf-filing","ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"}' >> ~/.reva-turbo/analytics/skill-usage.jsonl 2>/dev/null || true
```

## Purpose

Manage ISF (Importer Security Filing) for all ocean freight shipments imported by Rev A Manufacturing. The ISF (also called CBP 10+2) must be filed with US Customs and Border Protection (CBP) at least **24 hours before vessel departure** from the foreign port. Rev A Manufacturing is the Importer of Record and is solely responsible for ISF compliance.

**Penalty for late or missing ISF: $5,000 per violation (CBP 19 CFR 149).**

This skill is triggered by `reva-turbo-logistics` whenever shipping mode is Sea FCL (Full Container Load) or Sea LCL (Less than Container Load).

## Triggered By

`reva-turbo-logistics` when `shipping_mode == sea_fcl OR sea_lcl`

## Feeds Into

- `reva-turbo-import-compliance` — ISF confirmation number passed for customs entry
- `reva-turbo-reminder` — Deadline alert if ETD is within 48 hours and ISF not filed

## Flow

### Step 1 — Identify Shipment and Calculate Deadline

Load shipment details from the workflow state or ask PM:

| Field | Source | Required |
|-------|--------|----------|
| PO Number | workflow-state | Yes |
| Vessel name | Partner / forwarder | Yes |
| Vessel ETD (Estimated Time of Departure) | Partner / forwarder | Yes |
| Port of loading (China) | Partner | Yes |
| Port of entry (US) | Routing decision | Yes |

Calculate the ISF filing deadline:

```bash
_VESSEL_ETD="{{VESSEL_ETD}}"  # Format: YYYY-MM-DD HH:MM UTC
_ISF_DEADLINE=$(date -u -d "$_VESSEL_ETD - 24 hours" +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || echo "Calculate: ETD minus 24 hours")
_HOURS_REMAINING=$(( ( $(date -d "$_VESSEL_ETD" +%s 2>/dev/null || echo 0) - $(date +%s) ) / 3600 ))
echo "ISF must be filed by: $_ISF_DEADLINE"
echo "Hours remaining: $_HOURS_REMAINING"
```

If hours remaining < 48, flag urgent status immediately:

> **URGENT: ISF Deadline Alert**
>
> Vessel ETD: {{VESSEL_ETD}}
> ISF must be filed by: {{ISF_DEADLINE}}
> Hours remaining: {{HOURS_REMAINING}}
>
> This is fewer than 48 hours. Proceed immediately to collect all 10+2 data elements.

### Step 2 — Collect ISF 10+2 Data Elements

The ISF requires exactly 10 data elements from the importer + 2 from the carrier ("10+2"). Rev A Manufacturing provides the 10 importer elements.

**Collect all 10 elements from the PM or partner documentation:**

| # | Element | Source | Value |
|---|---------|--------|-------|
| 1 | **Seller** (name and address) | Commercial invoice | |
| 2 | **Buyer** (name and address — Rev A Manufacturing) | Rev A records | Pre-filled |
| 3 | **Importer of Record number** (Rev A EIN or CBP bond #) | Rev A records | Pre-filled |
| 4 | **Consignee number** (same as IOR for most Rev A shipments) | Rev A records | Pre-filled |
| 5 | **Manufacturer** (factory name and address in China) | Partner profile | |
| 6 | **Ship-to party** (name and address — Rev A or end customer) | Routing decision | |
| 7 | **Country of origin** | Commercial invoice | China (CN) |
| 8 | **HTS-6** (first 6 digits of HTS code) | Import compliance record | |
| 9 | **Container stuffing location** (where goods were stuffed) | Partner / forwarder | |
| 10 | **Consolidator** (name and address — entity that stuffed the container) | Forwarder | |

Ask PM to provide or confirm any missing elements:

> I need the following ISF 10+2 data elements. Rev A standard fields are pre-filled. Please provide the missing items:
>
> **Missing elements:**
> - Element 1 (Seller): ___
> - Element 5 (Manufacturer/factory): ___
> - Element 6 (Ship-to): ___ [Rev A address or customer address?]
> - Element 8 (HTS-6): ___ [from import compliance record]
> - Element 9 (Container stuffing location): ___
> - Element 10 (Consolidator): ___

**Rev A Pre-filled Defaults:**
- Buyer: Rev A Manufacturing, [address from CLIENT.md]
- Importer of Record: Rev A Manufacturing EIN (from config)
- Consignee: Same as IOR
- Country of Origin: China (CN) [confirm if any component is from another country]

### Step 3 — HITL Checkpoint — PM Review

**HUMAN-IN-THE-LOOP — REQUIRED BEFORE FILING:**

Present all 10+2 data elements to the PM for review:

> ## ISF Filing Review — PO {{PO_NUMBER}}
>
> **Vessel:** {{VESSEL_NAME}} | **ETD:** {{VESSEL_ETD}} | **Filing Deadline:** {{ISF_DEADLINE}}
>
> | # | Element | Value |
> |---|---------|-------|
> | 1 | Seller | {{SELLER_NAME}}, {{SELLER_ADDRESS}} |
> | 2 | Buyer | Rev A Manufacturing, {{REVA_ADDRESS}} |
> | 3 | Importer of Record | Rev A Manufacturing — EIN: {{REVA_EIN}} |
> | 4 | Consignee Number | Same as IOR |
> | 5 | Manufacturer | {{FACTORY_NAME}}, {{FACTORY_ADDRESS}} |
> | 6 | Ship-To Party | {{SHIP_TO_NAME}}, {{SHIP_TO_ADDRESS}} |
> | 7 | Country of Origin | China (CN) |
> | 8 | HTS-6 | {{HTS_6_DIGITS}} |
> | 9 | Container Stuffing Location | {{STUFFING_LOCATION}} |
> | 10 | Consolidator | {{CONSOLIDATOR_NAME}}, {{CONSOLIDATOR_ADDRESS}} |
>
> **Review all 10 elements. Do you approve this ISF for filing?**
>
> A) Approve — proceed to generate ISF filing document
> B) Edit — I need to correct one or more elements
> C) Cancel — do not file ISF at this time (I will handle manually)

Do NOT proceed past this step without PM approval (Option A).

### Step 4 — Filing — Generate ISF Document and Submit

After PM approval, generate the ISF filing document:

```bash
mkdir -p ~/.reva-turbo/state/isf
_ISF_FILE="$HOME/.reva-turbo/state/isf/ISF-{{PO_NUMBER}}-$(date +%Y%m%d).md"
```

Write the completed ISF data to `templates/ISF Filing.md` filled with all 10 elements.

**Submission instructions for PM:**

> **ISF Filing Document Generated**
>
> File saved to: `~/.reva-turbo/state/isf/ISF-{{PO_NUMBER}}-{{DATE}}.md`
>
> **How to submit:**
>
> **Option A — Via Licensed Customs Broker (Recommended):**
> Forward the ISF filing document to your customs broker. They will file directly in CBP's ACE (Automated Commercial Environment) system on your behalf. Broker must file by: **{{ISF_DEADLINE}}**
>
> **Option B — Self-file via ACE (if Rev A has ACE access):**
> Log into ACE Portal (cbp.gov/trade/ace) → Select ISF → Enter all 10+2 elements → Submit.
>
> **Confirmation required:** Once filed, enter the ISF confirmation number below so it can be logged.

### Step 5 — Log Filing

After PM confirms filing and provides the confirmation number:

```bash
_TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)
_CONF_NUM="{{ISF_CONFIRMATION_NUMBER}}"
_PO="{{PO_NUMBER}}"
_VESSEL="{{VESSEL_NAME}}"
_ETD="{{VESSEL_ETD}}"
_DEADLINE="{{ISF_DEADLINE}}"
_PM="{{PM_NAME}}"

echo '{"ts":"'"$_TS"'","po":"'"$_PO"'","event":"isf_filed","confirmation_number":"'"$_CONF_NUM"'","vessel":"'"$_VESSEL"'","vessel_etd":"'"$_ETD"'","isf_deadline":"'"$_DEADLINE"'","filed_by":"'"$_PM"'","status":"filed"}' >> ~/.reva-turbo/state/isf-log.jsonl
```

Also update the shipment log:

```bash
echo '{"ts":"'"$_TS"'","po":"'"$_PO"'","action":"isf_confirmed","isf_confirmation":"'"$_CONF_NUM"'","vessel_etd":"'"$_ETD"'","pm":"'"$_PM"'"}' >> ~/.reva-turbo/shipments/shipment-log.jsonl
```

### Step 6 — Set Deadline Reminder

Check if ETD is within 48 hours. If filing has not occurred and ETD is within 48 hours, trigger an urgent alert via `reva-turbo-pulse`:

```bash
_HOURS_UNTIL_ETD={{HOURS_REMAINING}}
if [ "$_HOURS_UNTIL_ETD" -lt 48 ] && [ -z "$_CONF_NUM" ]; then
  echo '{"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","type":"urgent","skill":"reva-turbo-isf-filing","po":"{{PO_NUMBER}}","message":"ISF NOT FILED — Vessel ETD in {{HOURS_REMAINING}} hours. Penalty risk: $5,000. File immediately.","channel":"all"}' >> ~/.reva-turbo/state/pulse-queue.jsonl
fi
```

> **Reminder set:** If ISF is not confirmed filed by {{ISF_REMINDER_TIME}}, an urgent alert will be sent via reva-turbo-pulse.

### Step 7 — Suggest Next Step

> ISF filing for PO {{PO_NUMBER}} is complete.
> Confirmation number: **{{ISF_CONFIRMATION_NUMBER}}**
>
> Next steps:
> - **reva-turbo-import-compliance** — Provide ISF confirmation number for customs entry
> - **reva-turbo-logistics** — Continue shipment coordination

## Report Naming

```
REVA-TURBO-ISF-{YYYY-MM-DD}-{PO_NUMBER}.md
```

## State File

**`~/.reva-turbo/state/isf-log.jsonl`** — append-only ISF filing log.

One entry per ISF filing event:
```json
{
  "ts": "ISO 8601 UTC",
  "po": "PO_NUMBER",
  "event": "isf_filed|isf_amended|isf_cancelled",
  "confirmation_number": "CBP confirmation number",
  "vessel": "Vessel name",
  "vessel_etd": "YYYY-MM-DD",
  "isf_deadline": "YYYY-MM-DDTHH:MM:SSZ",
  "filed_by": "pm-name",
  "status": "filed|pending|overdue"
}
```

## Template References

- `templates/ISF Filing.md` — Complete ISF 10+2 filing document template

## References

- CBP ISF regulations: 19 CFR Part 149
- CBP ACE portal: ace.cbp.gov
- Penalty authority: 19 USC 1484(l) — $5,000 per violation for late/inaccurate ISF
