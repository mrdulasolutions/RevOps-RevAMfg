# Customer Onboarding Gate

**Customer ID:** {{CUSTOMER_ID}}
**Onboarding Date:** {{ONBOARDING_DATE}}
**Status:** {{ONBOARDING_STATUS}}
**Assigned PM:** {{ASSIGNED_PM}}

---

## Company Information

| Field | Value |
|-------|-------|
| **Legal Name** | {{CUSTOMER_COMPANY}} |
| **DBA / Trade Name** | {{CUSTOMER_DBA}} |
| **Website** | {{CUSTOMER_WEBSITE}} |
| **HQ Address** | {{CUSTOMER_ADDRESS_HQ}} |
| **Shipping Address** | {{CUSTOMER_ADDRESS_SHIP}} |
| **Phone** | {{CUSTOMER_PHONE}} |
| **Industry** | {{CUSTOMER_INDUSTRY}} |
| **Company Size** | {{CUSTOMER_SIZE}} |
| **DUNS Number** | {{CUSTOMER_DUNS}} |

## Primary Contact

| Field | Value |
|-------|-------|
| **Name** | {{CONTACT_NAME}} |
| **Title** | {{CONTACT_TITLE}} |
| **Email** | {{CONTACT_EMAIL}} |
| **Phone** | {{CONTACT_PHONE}} |

## Source

| Field | Value |
|-------|-------|
| **How Found** | {{HOW_FOUND}} |
| **BD Rep** | {{BD_REP}} |
| **Referral Source** | {{REFERRAL_SOURCE}} |
| **Estimated Annual Spend** | ${{ANNUAL_SPEND_POTENTIAL}} |
| **Originating RFQ** | {{ORIGINATING_RFQ}} |

---

## Legitimacy Verification

| Check | Result | Notes |
|-------|--------|-------|
| Website verified | {{WEBSITE_CHECK}} | {{WEBSITE_NOTES}} |
| Email domain match | {{EMAIL_CHECK}} | {{EMAIL_NOTES}} |
| Business presence | {{BUSINESS_CHECK}} | {{BUSINESS_NOTES}} |
| Red flag screening | {{RED_FLAG_CHECK}} | {{RED_FLAG_NOTES}} |
| Export control screening | {{EXPORT_CHECK}} | {{EXPORT_NOTES}} |

**Overall Legitimacy Decision:** {{LEGITIMACY_DECISION}}

**Legitimacy Notes:**
{{LEGITIMACY_NOTES}}

---

## PM Assignment

| Field | Value |
|-------|-------|
| **Assigned PM** | {{ASSIGNED_PM}} |
| **Reason** | {{PM_ASSIGNMENT_REASON}} |

---

## Credit Terms

| Field | Value |
|-------|-------|
| **Initial Terms** | {{CREDIT_TERMS}} |
| **Credit Application** | {{CREDIT_APP_STATUS}} |
| **First Order Value** | ${{FIRST_ORDER_VALUE}} |
| **Approval Level** | {{CREDIT_APPROVAL_LEVEL}} |

**Credit Notes:**
{{CREDIT_NOTES}}

---

## Escalation

**Escalation Triggered:** {{ESCALATION_FLAG}}
**Escalation Details:** {{ESCALATION_DETAILS}}

---

## CRM Records Created

- [ ] Account record: {{CRM_ACCOUNT_ID}}
- [ ] Contact record: {{CRM_CONTACT_ID}}
- [ ] Linked to RFQ: {{ORIGINATING_RFQ}}

---

**Record created:** {{RECORD_CREATED_TIMESTAMP}}
**Next step:** {{NEXT_SKILL}}
