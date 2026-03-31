# CHANGE IMPACT SUMMARY

**For PM Decision**

---

**Change Order:** {{CO_NUMBER}}
**Date:** {{CO_DATE}}
**Order:** {{ORDER_ID}} -- {{CUSTOMER}} -- {{PART_NAME}} ({{CURRENT_REVISION}})

---

## What Changed

| | Original | Requested |
|---|----------|-----------|
| **{{CHANGE_TYPE}}** | {{ORIGINAL_VALUE}} | {{NEW_VALUE}} |

**Reason:** {{REASON}}
**Requested by:** {{REQUESTED_BY}}
**Urgency:** {{URGENCY}}
**Current production stage:** {{CURRENT_STAGE}}

---

## Impact at a Glance

| Dimension | Impact | Summary |
|-----------|--------|---------|
| **Cost** | {{COST_IMPACT_LEVEL}} | {{COST_SUMMARY}} |
| **Lead Time** | {{TIME_IMPACT_LEVEL}} | {{TIME_SUMMARY}} |
| **Tooling** | {{TOOLING_IMPACT_LEVEL}} | {{TOOLING_SUMMARY}} |
| **Quality** | {{QUALITY_IMPACT_LEVEL}} | {{QUALITY_SUMMARY}} |
| **Partner** | {{PARTNER_IMPACT_LEVEL}} | {{PARTNER_SUMMARY}} |
| **Logistics** | {{LOGISTICS_IMPACT_LEVEL}} | {{LOGISTICS_SUMMARY}} |

Impact levels: None / Low / Moderate / High / Critical

---

## The Numbers

| Metric | Original | Revised | Delta |
|--------|----------|---------|-------|
| **Total Price** | {{ORIG_TOTAL}} | {{NEW_TOTAL}} | **{{DELTA_TOTAL}}** |
| **Unit Price** | {{ORIG_UNIT}} | {{NEW_UNIT}} | {{DELTA_UNIT}} |
| **Delivery Date** | {{ORIG_DELIVERY}} | {{NEW_DELIVERY}} | **{{DELTA_DELIVERY}}** |
| **Change Fee** | -- | {{CHANGE_FEE}} | {{CHANGE_FEE}} |
| **Scrap Cost** | -- | {{SCRAP_COST}} | {{SCRAP_COST}} |

---

## Recommendation

**{{RECOMMENDATION}}**

{{RECOMMENDATION_DETAIL}}

---

## Decision

- **A) Approve change order** -- proceed with revised specs, pricing, and timeline
- **B) Reject change order** -- maintain original order as-is
- **C) Approve with modifications** -- proceed with adjustments (specify)
- **D) Request more analysis** -- need additional information before deciding

---

*PM: {{PM_NAME}} | Order: {{ORDER_ID}} | CO: {{CO_NUMBER}}*
