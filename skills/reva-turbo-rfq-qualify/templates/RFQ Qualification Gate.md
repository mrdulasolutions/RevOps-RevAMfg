# RFQ Qualification Gate

**RFQ ID:** {{RFQ_ID}}
**Customer:** {{CUSTOMER_COMPANY}}
**Contact:** {{CONTACT_NAME}}
**Assigned PM:** {{ASSIGNED_PM}}
**Date Qualified:** {{DATE_QUALIFIED}}

---

## Decision: {{DECISION}}

---

## Gate Results

### Gate 1: Customer Status — {{GATE_1_RESULT}}

{{GATE_1_DETAIL}}

### Gate 2: Capability Match — {{GATE_2_RESULT}}

| Requirement | Match | Notes |
|------------|-------|-------|
| Manufacturing Process | {{PROCESS_MATCH}} | {{PROCESS_NOTES}} |
| Material | {{MATERIAL_MATCH}} | {{MATERIAL_NOTES}} |
| Tolerances | {{TOLERANCE_MATCH}} | {{TOLERANCE_NOTES}} |
| Finish | {{FINISH_MATCH}} | {{FINISH_NOTES}} |
| Certifications | {{CERT_MATCH}} | {{CERT_NOTES}} |
| Volume | {{VOLUME_MATCH}} | {{VOLUME_NOTES}} |

{{GATE_2_DETAIL}}

### Gate 3: Complexity Score — {{GATE_3_SCORE}}/5 ({{GATE_3_LEVEL}})

**Scoring factors:**

| Factor | Assessment |
|--------|-----------|
| Number of processes | {{PROCESS_COUNT}} |
| Tolerance tightness | {{TOLERANCE_LEVEL}} |
| Material complexity | {{MATERIAL_COMPLEXITY}} |
| Tooling requirements | {{TOOLING_COMPLEXITY}} |
| Quality/cert requirements | {{QUALITY_COMPLEXITY}} |
| Assembly complexity | {{ASSEMBLY_COMPLEXITY}} |
| Export control | {{EXPORT_COMPLEXITY}} |

{{GATE_3_DETAIL}}

### Gate 4: Capacity Check — {{GATE_4_RESULT}}

| Metric | Value |
|--------|-------|
| PM active orders | {{PM_ACTIVE_ORDERS}} |
| PM workload status | {{PM_WORKLOAD_STATUS}} |
| Estimated lead time | {{ESTIMATED_LEAD_TIME}} |
| Customer requested delivery | {{DELIVERY_TIMELINE}} |
| Timeline feasibility | {{TIMELINE_FEASIBILITY}} |

{{GATE_4_DETAIL}}

### Gate 5: Credit Readiness — {{GATE_5_RESULT}}

| Metric | Value |
|--------|-------|
| Credit tier | {{CREDIT_TIER}} |
| Payment terms | {{PAYMENT_TERMS}} |
| Outstanding balance | {{OUTSTANDING_BALANCE}} |
| Payment history | {{PAYMENT_HISTORY}} |

{{GATE_5_DETAIL}}

---

## Rationale

{{RATIONALE}}

## Conditions (if CONDITIONAL)

{{CONDITIONS}}

## Escalation Notes

{{ESCALATION_NOTES}}

## PM Override

{{PM_OVERRIDE_NOTES}}

---

**Next step:** {{NEXT_SKILL}}
**Record created:** {{RECORD_CREATED_TIMESTAMP}}
