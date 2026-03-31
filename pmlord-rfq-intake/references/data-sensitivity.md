# Data Sensitivity — Customer Data Handling Rules

Rules for handling customer data during RFQ intake and throughout the PMLORD workflow.

## Classification Levels

### Level 1: Public
- Customer company name (if publicly known)
- General capability inquiries
- Published specifications (from public datasheets)

### Level 2: Business Confidential
- Contact names, emails, phone numbers
- Part descriptions and quantities
- Pricing discussions and target prices
- Delivery timelines
- Standard business terms

**Handling:** Store in PMLORD state directory (`~/.pmlord/`). Do not write to shared/public directories. Do not include in logs that may be shared.

### Level 3: Proprietary / NDA-Protected
- Customer drawings, CAD files, 3D models
- Proprietary specifications and tolerances
- Custom tooling designs
- Assembly procedures unique to the customer
- Test procedures and acceptance criteria

**Handling:** Flag NDA status. Do not share with manufacturing partners until PM confirms NDA compliance. Do not copy to unprotected locations. Note file references only — do not embed proprietary content in intake records.

### Level 4: Restricted
- ITAR-controlled technical data
- EAR-controlled specifications
- Customer financial data beyond standard payment terms
- Personal Identifiable Information (PII) beyond business contact info

**Handling:** Stop processing. Escalate to Donovan Weber. Do not store, copy, or transmit without explicit authorization.

## Rules

### Rule 1: Minimum Necessary
Only extract and store data necessary for the RFQ process. Do not capture or retain data that is not relevant to quoting, qualifying, or fulfilling the order.

### Rule 2: NDA Check
Before processing any RFQ from a customer with an NDA on file:
- Confirm the NDA covers the type of work being quoted
- Note NDA status on the intake record
- Ensure all downstream skills (qualify, quote, china-package) inherit the NDA flag

### Rule 3: No Proprietary Content in Logs
PMLORD analytics and telemetry logs must never contain:
- Customer names
- Part descriptions
- Drawing content
- Pricing data
- Contact information

Logs should only contain: skill name, timestamp, duration, outcome, generic metadata.

### Rule 4: Drawing and File Handling
- Note filenames and types in the intake record
- Do not attempt to open, parse, or embed binary files (PDFs, DWGs, STEP, etc.)
- Store file references only: `[Drawing: filename.pdf, Rev B, received 2026-03-15]`
- Physical files remain in the PM's email/file system — PMLORD tracks references only

### Rule 5: Export Control Screening
If any of the following keywords appear in the RFQ, flag for export control review:
- ITAR, defense, military, munitions, satellite, space
- EAR, ECCN, dual-use, encryption
- Embargoed countries or restricted entities

Flag format: `[EXPORT CONTROL FLAG — review required before proceeding]`

### Rule 6: Retention
- Active RFQ records: Retain for the duration of the opportunity plus 12 months
- Declined RFQs: Retain for 6 months, then archive
- Customer contact data: Retain as long as the customer relationship is active
- Analytics/telemetry: Retain for 24 months, then purge

### Rule 7: Breach Protocol
If customer data is inadvertently written to an unprotected location:
1. Delete the data immediately
2. Note the incident in `~/.pmlord/state/incident-log.jsonl`
3. Notify the assigned PM
4. Escalate to Donovan Weber if proprietary or restricted data was involved
