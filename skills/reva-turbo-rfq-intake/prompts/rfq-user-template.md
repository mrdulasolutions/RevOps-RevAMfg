# RFQ User Template — Fields to Extract

Extract the following variables from the incoming RFQ. If a field cannot be determined, mark it `[MISSING — follow up required]`.

## Customer Information

- **{{CUSTOMER_COMPANY}}** — Company name of the requesting customer
- **{{CONTACT_NAME}}** — Primary contact person (first and last name)
- **{{CONTACT_EMAIL}}** — Contact email address
- **{{CONTACT_PHONE}}** — Contact phone number
- **{{CONTACT_TITLE}}** — Contact job title or role
- **{{CUSTOMER_ADDRESS}}** — Ship-to or billing address if provided
- **{{CUSTOMER_TYPE}}** — New or Returning customer

## Part Information

- **{{PART_DESCRIPTION}}** — Description of the part or assembly requested
- **{{PART_NUMBER}}** — Customer part number (if provided)
- **{{DRAWING_REF}}** — Drawing or CAD file references (filenames, revision levels)
- **{{MATERIAL}}** — Material specification (e.g., 6061-T6 Aluminum, ABS, 304 SS)
- **{{FINISH}}** — Surface finish or coating requirements (e.g., anodize, powder coat, Ra 32)
- **{{TOLERANCES}}** — Critical tolerances or dimensional callouts
- **{{MANUFACTURING_PROCESS}}** — Identified process type (machining, molding, sheet metal, etc.)

## Commercial Information

- **{{QUANTITY}}** — Requested quantity (include all tiers if multiple)
- **{{DELIVERY_TIMELINE}}** — Requested delivery date or lead time
- **{{TARGET_PRICE}}** — Customer target price (if stated)
- **{{ANNUAL_USAGE}}** — Expected annual volume (if stated)
- **{{TOOLING_EXPECTATION}}** — Whether customer expects to pay for tooling separately

## Special Requirements

- **{{SPECIAL_REQUIREMENTS}}** — Certifications (ISO, AS9100, ITAR), testing, inspection requirements, packaging, marking, or other special callouts
- **{{QUALITY_REQUIREMENTS}}** — Specific quality documentation (PPAP, FAIR, CoC, material certs)
- **{{EXPORT_CONTROL}}** — Any ITAR, EAR, or export control flags

## Metadata

- **{{RFQ_SOURCE}}** — Source of the RFQ (email, website, crm, phone, referral, tradeshow)
- **{{DATE_RECEIVED}}** — Date the RFQ was received (YYYY-MM-DD)
- **{{ASSIGNED_PM}}** — PM assigned to this RFQ (Ray Yeh or Harley Scott)
- **{{BD_SOURCE}}** — BD rep who originated the lead (Matt Nebo, Barry Coyle, Bryce Martel, Ryan Knight — if applicable)
- **{{RFQ_ID}}** — Generated RFQ identifier (format: RFQ-YYYYMMDD-NNN)
- **{{PRIORITY}}** — Priority level (Standard, Rush, Critical)
