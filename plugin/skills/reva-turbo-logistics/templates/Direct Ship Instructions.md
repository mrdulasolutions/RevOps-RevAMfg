# Direct Ship Instructions
<!-- STUB: This reference file needs to be populated. Created by audit remediation. -->

**REVA-TURBO Template — Direct China-to-Customer Ship Instructions**

Fill all `{{PLACEHOLDER}}` variables before sending to the manufacturing partner.

---

# DIRECT SHIP INSTRUCTIONS
## Rev A Manufacturing — Partner Shipping Guide

**Date:** {{SHIP_INSTRUCTIONS_DATE}}
**PO Number (Rev A):** {{REVA_PO_NUMBER}}
**Partner PO Number:** {{PARTNER_PO_NUMBER}}
**Part Name / Number:** {{PART_NAME}} / {{PART_NUMBER}}
**Quantity:** {{QUANTITY}}

---

## 1. Shipping Address (Ultimate Consignee)

Ship goods DIRECTLY to:

**{{CUSTOMER_COMPANY}}**
{{CUSTOMER_ADDRESS_LINE1}}
{{CUSTOMER_ADDRESS_LINE2}}
{{CUSTOMER_CITY}}, {{CUSTOMER_STATE}} {{CUSTOMER_ZIP}}
{{CUSTOMER_COUNTRY}}

Attention: {{CUSTOMER_CONTACT_NAME}}
Phone: {{CUSTOMER_PHONE}}

---

## 2. Notify Party (Required on all shipping documents)

**Rev A Manufacturing**
{{REVA_ADDRESS}}
Attn: {{REVA_PM_NAME}} — {{REVA_PM_EMAIL}}
Phone: {{REVA_PHONE}}

---

## 3. Importer of Record

**Rev A Manufacturing** is the Importer of Record (IOR) for US Customs purposes.
- EIN / IRS Number: [On file with customs broker]
- CBP Surety Bond: [On file with customs broker]

Do NOT list the end customer as the Importer of Record. Rev A Manufacturing retains all import compliance responsibility.

---

## 4. Shipping Instructions

| Field | Requirement |
|-------|-------------|
| Shipping Mode | {{SHIPPING_MODE}} (Air / Sea FCL / Sea LCL) |
| Incoterm | {{INCOTERM}} |
| Carrier | {{PREFERRED_CARRIER}} (or carrier of your choice if not specified) |
| Service Level | {{SERVICE_LEVEL}} |
| Target Ship Date | {{TARGET_SHIP_DATE}} |
| Target Arrival Date | {{TARGET_ARRIVAL_DATE}} |

---

## 5. Commercial Invoice Requirements

The commercial invoice MUST include:
- Rev A Manufacturing PO number: **{{REVA_PO_NUMBER}}**
- Description of goods (in English): {{PART_DESCRIPTION}}
- Country of Origin: China
- HTS Code (US): {{HTS_CODE}}
- Unit value (USD): ${{UNIT_VALUE}}
- Total invoice value (USD): ${{TOTAL_VALUE}}
- Manufacturer name and address (your factory)
- Seller name and address (your company)
- Buyer: Rev A Manufacturing (Importer of Record)
- Ultimate consignee: {{CUSTOMER_COMPANY}}

---

## 6. Packing List Requirements

The packing list must include:
- Part number (Rev A): {{PART_NUMBER}}
- Part description: {{PART_DESCRIPTION}}
- Quantity per carton and total quantity
- Gross weight and net weight (kg)
- Carton dimensions (cm, L × W × H)
- Number of cartons

---

## 7. ISF / Ocean Freight Notice (Ocean Shipments Only)

If shipping by ocean (FCL or LCL):
- Notify Rev A Manufacturing at **{{REVA_PM_EMAIL}}** with vessel name, ETD, and bill of lading details at least **48 hours before vessel departure**.
- Rev A is responsible for filing ISF (Importer Security Filing) with CBP. We require vessel name, voyage number, ETD, and B/L number to complete this filing.
- Failure to provide ETD details 48 hours in advance may result in ISF late-filing penalties assessed to the partner.

---

## 8. Customs Documentation Package

Ship the following documents with the goods (in packing):
- [ ] Commercial Invoice (3 originals)
- [ ] Packing List (2 copies)
- [ ] Certificate of Origin (if applicable)
- [ ] Material Certificate / CoC (if required per Rev A quality spec)
- [ ] Inspection report (if required)

Email copies of all documents to: **{{REVA_PM_EMAIL}}** at time of shipment.

---

## 9. Tracking Notification

Provide tracking information (AWB / B/L number, carrier name, ETD, ETA) to:
- **{{REVA_PM_NAME}}** at **{{REVA_PM_EMAIL}}**
- Send within 24 hours of shipment pickup/departure

---

## 10. Contact

For questions on these shipping instructions:

**{{REVA_PM_NAME}}**
Rev A Manufacturing
{{REVA_PM_EMAIL}}
{{REVA_PM_PHONE}}

---

*These instructions supersede any previous shipping instructions for this PO. Rev A Manufacturing | Confidential*
