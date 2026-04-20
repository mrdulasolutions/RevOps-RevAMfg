# Quoting User Template

Input and output variables for quote generation.

## From Intake/Qualification Records

- **{{RFQ_ID}}** — RFQ identifier
- **{{CUSTOMER_COMPANY}}** — Customer company name
- **{{CONTACT_NAME}}** — Primary contact
- **{{PART_DESCRIPTION}}** — Part description
- **{{PART_NUMBER}}** — Customer part number
- **{{MATERIAL}}** — Material specification
- **{{FINISH}}** — Finish requirements
- **{{TOLERANCES}}** — Critical tolerances
- **{{MANUFACTURING_PROCESS}}** — Process type
- **{{QUANTITY}}** — Requested quantity (all tiers)
- **{{DELIVERY_TIMELINE}}** — Customer requested delivery
- **{{TARGET_PRICE}}** — Customer target price
- **{{SPECIAL_REQUIREMENTS}}** — Special requirements
- **{{ASSIGNED_PM}}** — PM assigned
- **{{COMPLEXITY_SCORE}}** — From qualification (1-5)
- **{{DRAWING_REF}}** — Drawing references

## Cost Variables (calculated or PM-provided)

- **{{MATERIAL_COST_UNIT}}** — Material cost per unit
- **{{MATERIAL_COST_EXT}}** — Material cost extended
- **{{MFG_COST_UNIT}}** — Manufacturing cost per unit
- **{{MFG_COST_EXT}}** — Manufacturing cost extended
- **{{FINISH_COST_UNIT}}** — Finishing cost per unit
- **{{FINISH_COST_EXT}}** — Finishing cost extended
- **{{ASSEMBLY_COST_UNIT}}** — Assembly cost per unit
- **{{ASSEMBLY_COST_EXT}}** — Assembly cost extended
- **{{QUALITY_COST_UNIT}}** — Quality/inspection cost per unit
- **{{QUALITY_COST_EXT}}** — Quality/inspection cost extended
- **{{COGS_UNIT}}** — Total COGS per unit
- **{{COGS_EXT}}** — Total COGS extended
- **{{TOOLING_COST}}** — Tooling/NRE cost
- **{{SHIPPING_COST}}** — Shipping cost

## Pricing Variables (calculated)

- **{{TARGET_MARGIN}}** — Target margin percentage
- **{{QUOTED_PRICE_UNIT}}** — Quoted price per unit
- **{{QUOTED_PRICE_EXT}}** — Quoted price extended
- **{{TOOLING_QUOTED}}** — Tooling price to customer
- **{{SHIPPING_QUOTED}}** — Shipping price to customer
- **{{TOTAL_QUOTE}}** — Total quote amount
- **{{ACTUAL_MARGIN}}** — Actual margin percentage achieved
- **{{PRICE_DELTA}}** — Delta vs customer target price

## Lead Time Variables

- **{{ORDER_PROCESSING_TIME}}** — Order processing duration
- **{{TOOLING_TIME}}** — Tooling lead time
- **{{MFG_TIME}}** — Manufacturing duration
- **{{FINISH_TIME}}** — Finishing duration
- **{{SHIPPING_TIME}}** — International shipping duration
- **{{CUSTOMS_TIME}}** — Customs clearance duration
- **{{INSPECTION_TIME}}** — Incoming inspection duration
- **{{REPACK_TIME}}** — Repackaging duration
- **{{DOMESTIC_SHIP_TIME}}** — Domestic shipping duration
- **{{TOTAL_LEAD_TIME}}** — Total lead time

## Quote Metadata

- **{{QUOTE_NUMBER}}** — Generated quote number (QT-YYYYMMDD-NNN)
- **{{QUOTE_DATE}}** — Date quote was generated
- **{{QUOTE_VALIDITY}}** — Quote expiration date
- **{{PAYMENT_TERMS}}** — Payment terms
- **{{SHIPPING_TERMS}}** — Shipping terms (FOB, DDP, etc.)
