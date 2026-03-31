# Customer Report

**Report ID:** PMLORD-CustomerReport-{{REPORT_DATE}}-{{CUSTOMER_SHORT_NAME}}
**Customer:** {{CUSTOMER_COMPANY}}
**Period:** {{REPORT_PERIOD}}
**Generated:** {{TIMESTAMP}}
**Prepared By:** {{PM_NAME}}, Rev A Manufacturing

---

## Customer Profile

| Field | Value |
|-------|-------|
| Company | {{CUSTOMER_COMPANY}} |
| Primary Contact | {{PRIMARY_CONTACT}} |
| Email | {{CONTACT_EMAIL}} |
| Phone | {{CONTACT_PHONE}} |
| Address | {{CUSTOMER_ADDRESS}} |
| Relationship Since | {{RELATIONSHIP_START}} |
| Account PM | {{ASSIGNED_PM}} |
| Customer Tier | {{CUSTOMER_TIER}} |

---

## Account Summary

| Metric | Period | All-Time |
|--------|--------|----------|
| Total Orders | {{PERIOD_ORDERS}} | {{ALLTIME_ORDERS}} |
| Total Revenue | ${{PERIOD_REVENUE}} | ${{ALLTIME_REVENUE}} |
| Average Order Value | ${{PERIOD_AOV}} | ${{ALLTIME_AOV}} |
| On-Time Delivery Rate | {{PERIOD_OTD}}% | {{ALLTIME_OTD}}% |
| Quality Rate | {{PERIOD_QUALITY}}% | {{ALLTIME_QUALITY}}% |

---

## Order History

| PO | Date | Part Description | Qty | Value | Status | Delivered |
|----|------|-----------------|-----|-------|--------|-----------|
| {{ORDER_ROW_1}} |
| {{ORDER_ROW_2}} |
| {{ORDER_ROW_3}} |
| {{ORDER_ROW_4}} |
| {{ORDER_ROW_5}} |

---

## Active Orders

| PO | Part | Qty | Stage | Expected Delivery | On Track |
|----|------|-----|-------|-------------------|----------|
| {{ACTIVE_ROW_1}} |
| {{ACTIVE_ROW_2}} |

---

## Quality Record

### NCR Summary

| Metric | Value |
|--------|-------|
| Total NCRs (period) | {{PERIOD_NCRS}} |
| NCRs Resolved | {{NCRS_RESOLVED}} |
| NCRs Open | {{NCRS_OPEN}} |
| Average Resolution Time | {{AVG_RESOLUTION}} days |

### NCR Details

| NCR ID | PO | Issue | Root Cause | Resolution | Date |
|--------|-----|-------|-----------|------------|------|
| {{NCR_ROW_1}} |
| {{NCR_ROW_2}} |

---

## Delivery Performance

| Metric | Value |
|--------|-------|
| Orders Delivered (period) | {{DELIVERIES}} |
| On-Time | {{ON_TIME}} |
| Late (1-3 days) | {{LATE_MINOR}} |
| Late (4+ days) | {{LATE_MAJOR}} |
| On-Time Rate | {{OTD_RATE}}% |
| Average Lead Time | {{AVG_LEAD_TIME}} days |

---

## Communication Log

| Date | Type | Summary | PM |
|------|------|---------|-----|
| {{COMM_ROW_1}} |
| {{COMM_ROW_2}} |
| {{COMM_ROW_3}} |

---

## Recommendations

{{RECOMMENDATIONS}}

---

*Prepared by Rev A Manufacturing (revamfg.com)*
*This report is confidential and intended for {{CUSTOMER_COMPANY}} and Rev A Manufacturing internal use.*
