# Standardized Delay Codes

Use these codes when recording delays in manufacturing tracking. Every delay must have a code, a description, and an estimated impact in business days.

## Delay Code Format

```
DLY-{CATEGORY}-{###}
```

Example: `DLY-MTL-001` — Material not available from supplier.

---

## Material Delays (DLY-MTL)

| Code | Description | Typical Impact |
|------|-------------|---------------|
| DLY-MTL-001 | Raw material not available from supplier | 5-15 days |
| DLY-MTL-002 | Material failed incoming inspection at partner | 7-20 days |
| DLY-MTL-003 | Wrong material ordered/received | 10-20 days |
| DLY-MTL-004 | Material price increase, requires PO revision | 3-7 days |
| DLY-MTL-005 | Material certification delay | 2-5 days |

## Tooling Delays (DLY-TLG)

| Code | Description | Typical Impact |
|------|-------------|---------------|
| DLY-TLG-001 | Tooling design revision required | 5-15 days |
| DLY-TLG-002 | Tooling material not available | 5-10 days |
| DLY-TLG-003 | Tooling rework after first article | 7-21 days |
| DLY-TLG-004 | Tooling damaged during production | 10-30 days |
| DLY-TLG-005 | Tooling capacity — partner queue full | 5-15 days |

## Quality Delays (DLY-QTY)

| Code | Description | Typical Impact |
|------|-------------|---------------|
| DLY-QTY-001 | First article rejected — rework needed | 7-21 days |
| DLY-QTY-002 | In-process quality issue — production paused | 3-10 days |
| DLY-QTY-003 | Final QC failure — rework or rerun | 7-21 days |
| DLY-QTY-004 | Dimensional out of tolerance | 5-15 days |
| DLY-QTY-005 | Surface finish defect | 3-10 days |
| DLY-QTY-006 | Material test failure (hardness, composition) | 10-20 days |

## Shipping / Logistics Delays (DLY-SHP)

| Code | Description | Typical Impact |
|------|-------------|---------------|
| DLY-SHP-001 | Port congestion | 3-14 days |
| DLY-SHP-002 | Customs hold / documentation issue | 3-10 days |
| DLY-SHP-003 | Carrier capacity — no available booking | 3-7 days |
| DLY-SHP-004 | Weather delay (typhoon, storm) | 2-7 days |
| DLY-SHP-005 | Incorrect HS code / tariff classification | 3-10 days |
| DLY-SHP-006 | Packing/crating rework required | 2-5 days |

## Holiday Delays (DLY-HOL)

| Code | Description | Typical Impact |
|------|-------------|---------------|
| DLY-HOL-001 | Chinese New Year shutdown | 14-28 days |
| DLY-HOL-002 | National Day / Golden Week | 7-10 days |
| DLY-HOL-003 | Other Chinese public holiday | 1-3 days |
| DLY-HOL-004 | US holiday (Rev A closed) | 1-3 days |

## Capacity / Scheduling Delays (DLY-CAP)

| Code | Description | Typical Impact |
|------|-------------|---------------|
| DLY-CAP-001 | Partner at full capacity — order queued | 5-20 days |
| DLY-CAP-002 | Key operator/technician unavailable | 3-7 days |
| DLY-CAP-003 | Machine breakdown | 3-14 days |
| DLY-CAP-004 | Power outage / utility disruption | 1-5 days |
| DLY-CAP-005 | COVID or health-related shutdown | 7-30 days |

## Communication Delays (DLY-COM)

| Code | Description | Typical Impact |
|------|-------------|---------------|
| DLY-COM-001 | Partner unresponsive (no reply > 3 days) | 3-7 days |
| DLY-COM-002 | Spec clarification needed from Rev A | 2-5 days |
| DLY-COM-003 | Customer approval pending | 3-10 days |
| DLY-COM-004 | Language/translation misunderstanding | 2-5 days |

## Design Change Delays (DLY-DSG)

| Code | Description | Typical Impact |
|------|-------------|---------------|
| DLY-DSG-001 | Customer requested design change | 5-20 days |
| DLY-DSG-002 | Manufacturability issue — design revision | 5-15 days |
| DLY-DSG-003 | Drawing error discovered | 3-10 days |

---

## How to Record a Delay

When recording a delay in the tracking system, include:

1. **Delay code** (e.g., DLY-MTL-001)
2. **Date identified**
3. **Milestone affected** (e.g., M3)
4. **Estimated impact** (business days)
5. **Root cause notes** (1-2 sentences)
6. **Recovery plan** (what is being done to mitigate)
7. **Revised target date**
