# REVA-TURBO Escalation Thresholds — Canonical Reference

This document is the **single source of truth** for all escalation and notification thresholds across the REVA-TURBO Skills Engine. Skills that reference escalation thresholds must cite this document rather than hardcoding values.

**Consuming skills:** reva-turbo-china-track, reva-turbo-order-track, reva-turbo-logistics, reva-turbo-escalate, reva-turbo-pulse, reva-turbo-partner-scorecard, reva-turbo-cost-tracking, reva-turbo-profit

Last updated: 2026-04-01

---

## 1. Manufacturing Delays

Applied by: `reva-turbo-china-track`

| Status | Definition | Days Behind Schedule |
|--------|------------|---------------------|
| **On Track** | Within 2 business days of baseline | 0–2 days |
| **At Risk** | Starting to slip; may impact delivery | 3–7 days |
| **Delayed** | Meaningful delay; delivery date at risk | 7–14 days |
| **Critical** | Severe delay; customer delivery impact likely | >14 days |

| Threshold | Action | Skill |
|-----------|--------|-------|
| >3 days (At Risk) | PM notification via pulse alert | `reva-turbo-pulse` |
| >7 days (Delayed) | PM notification + recommend customer comms | `reva-turbo-pulse` + `reva-turbo-customer-comms` |
| >14 days (Critical) | Auto-escalate trigger recommended | `reva-turbo-escalate` |
| Delivery date at risk (any delay) | Customer notification required | `reva-turbo-customer-comms` |

---

## 2. Quote Follow-Up

Applied by: `reva-turbo-customer-comms`, `reva-turbo-reminder`

| Event | Timing | Action |
|-------|--------|--------|
| First follow-up | 5 business days after quote sent with no response | Send follow-up email |
| Second follow-up | 10 business days after quote sent with no response | Send second follow-up + flag to PM |
| Quote close-out | 15 business days after quote sent with no response | Quote expires; log as lost; close RFQ |

---

## 3. Order Delivery

Applied by: `reva-turbo-order-track`, `reva-turbo-logistics`

| Status | Days Behind Committed Ship Date | Action |
|--------|--------------------------------|--------|
| **Alert** | >3 days | PM notification via pulse |
| **Escalate** | >7 days | Trigger reva-turbo-escalate |
| **Customer notification required** | >5 days | Draft customer communication via reva-turbo-customer-comms |

---

## 4. Cost Variance

Applied by: `reva-turbo-cost-tracking`, `reva-turbo-profit`, `reva-turbo-rfq-quote`

| Variance | Threshold | Action |
|----------|-----------|--------|
| **Warning** | >5% over estimated cost (single category) | Log for review; flag in cost report |
| **HITL required** | >10% over estimated cost (single category) | Stop; PM must acknowledge before proceeding |
| **Senior review required** | >20% over estimated cost (overall order) | Escalate to Senior PM (Ray Yeh or Harley Scott) |
| **Executive escalation** | >30% over estimated cost (overall order) | Escalate to Donovan Weber |
| **Below minimum margin** | Gross margin <15% | Immediate PM review required |
| **Negative margin** | Gross margin <0% | Immediate escalation to Donovan Weber |

---

## 5. Quality

Applied by: `reva-turbo-inspect`, `reva-turbo-ncr`, `reva-turbo-quality-gate`, `reva-turbo-partner-scorecard`

| Threshold | Action |
|-----------|--------|
| Any REJECT disposition on incoming inspection | Open NCR via reva-turbo-ncr |
| HOLD disposition on incoming inspection | Notify Senior PM (Ray Yeh or Harley Scott) via pulse |
| HOLD >3 business days without resolution | Escalate to Senior PM; notify Donovan Weber if customer impact |
| >2 NCRs against same partner in 90 days | Partner Quality Watch — note in partner scorecard; flag to PM |
| >3 NCRs against same partner in 90 days | Partner Quality Hold — do not place new orders without PM approval |
| 1 critical defect (severity = Critical) | Partner Quality Hold immediately, regardless of NCR count |
| Quality gate FAIL (G3 or G4) | HOLD shipment; PM must resolve before release |

---

## 6. Response SLAs

Applied by: `reva-turbo-escalate`, `reva-turbo-pulse`, `reva-turbo-customer-comms`

**Customer response SLAs:**
| Event | SLA |
|-------|-----|
| RFQ acknowledgment | Within 1 business day of receipt |
| Quote delivery | Within 3 business days (standard); 1 business day (expedited) |
| Customer inquiry response | Within 4 business hours |

**Internal escalation response SLAs:**
| Escalation Level | Response Required Within |
|-----------------|------------------------|
| Critical escalation | 2 business hours |
| High priority escalation | 4 business hours |
| Medium priority escalation | 1 business day |
| Low priority / informational | 3 business days |

---

## 7. Partner Performance Escalation

Applied by: `reva-turbo-partner-scorecard`, `reva-turbo-escalate`

| Score | Grade | Action |
|-------|-------|--------|
| 85–100 | A | No action required — preferred partner |
| 70–84 | B | Monitor; address minor issues |
| 55–69 | C | Schedule improvement meeting; 90-day re-evaluation |
| 40–54 | D | Issue formal corrective action request; 60-day re-evaluation; identify backup partner |
| <40 | F | Escalate to Donovan Weber; begin partner replacement process |

---

## 8. Escalation Routing

Applied by: `reva-turbo-escalate`

| Situation | First Contact | Second Contact | Final Authority |
|-----------|-------------|----------------|----------------|
| Manufacturing delay (Critical) | Assigned PM | Ray Yeh or Harley Scott | Donovan Weber |
| Quality HOLD >3 days | Assigned PM | Ray Yeh or Harley Scott | Donovan Weber |
| Cost variance >20% | Assigned PM | Ray Yeh or Harley Scott | Donovan Weber |
| Partner quality hold | Assigned PM | Ray Yeh or Harley Scott | Donovan Weber |
| Negative margin order | Assigned PM | Donovan Weber directly | — |
| Compliance issue (export) | Assigned PM | Donovan Weber directly | Legal counsel |
| Customer complaint (critical) | Assigned PM | Donovan Weber | — |

**Final escalation authority:** Donovan Weber is the final escalation point for all issues.

See `skills/revmyengine/references/team-directory.md` for contact information.
