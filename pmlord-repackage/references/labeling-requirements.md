# Labeling Requirements

## Mandatory Labels

### 1. Product Identification Label

Applied to each product or innermost packaging unit.

**Required Fields:**
- Part Number: {{PART_NUMBER}}
- Part Description: {{PART_DESCRIPTION}}
- Quantity: {{QUANTITY_PER_PACKAGE}}
- Rev A Lot Number: {{LOT_NUMBER}} (format: RA-YYYYMMDD-SEQ)
- Manufacturing Date: {{MFG_DATE}}
- Country of Origin: Made in China

**Format:** Printed label, minimum 2"x3", black text on white background, barcode optional.

### 2. Shipping Label

Applied to outer packaging, visible on at least two sides.

**Required Fields:**
- Ship From:
  Rev A Manufacturing
  [Rev A facility address]
- Ship To:
  {{CUSTOMER_COMPANY}}
  {{SHIP_TO_ADDRESS}}
  {{SHIP_TO_CITY}}, {{SHIP_TO_STATE}} {{SHIP_TO_ZIP}}
- PO Number: {{PO_NUMBER}}
- Package: {{PACKAGE_NUM}} of {{TOTAL_PACKAGES}}
- Weight: {{PACKAGE_WEIGHT}}
- Carrier tracking label (applied by carrier or pre-printed)

### 3. Country of Origin Marking

**Legal Requirement:** 19 CFR Part 134 requires all imported articles to be marked with the country of origin in a conspicuous location, in English, in a manner that is legible, indelible, and permanent.

**Acceptable markings:**
- "Made in China"
- "Product of China"
- "Manufactured in China"

**Placement:** On the product itself if practical, otherwise on the innermost container that reaches the ultimate purchaser.

**Exceptions:** Check 19 CFR 134.32 for J-list exceptions (articles exempt from marking).

## Conditional Labels

### 4. Handling Labels

Apply when appropriate:

| Label | When to Apply |
|-------|--------------|
| FRAGILE | Glass, precision instruments, delicate parts |
| THIS SIDE UP (with arrows) | Products with orientation requirements |
| DO NOT STACK | Crush-sensitive items |
| KEEP DRY | Moisture-sensitive products |
| HANDLE WITH CARE | General delicate items |
| HEAVY (weight in lbs) | Packages >50 lbs |

### 5. Customer-Specific Labels

Some customers require additional labeling:

| Requirement | Example |
|------------|---------|
| Customer part number label | Customer's internal PN on each piece |
| Barcode label (Code 128, QR) | For customer receiving/inventory system |
| Lot traceability label | Customer's lot tracking requirements |
| Branded packaging label | Customer logo or branding on outer box |
| Shelf-ready label | Retail-ready labeling with UPC/EAN |

**Always check the PO and customer profile for specific labeling instructions.**

### 6. Regulatory Labels

Apply when product falls under regulatory requirements:

| Regulation | Label Type | When Required |
|-----------|-----------|---------------|
| CPSC | Safety warning labels | Consumer products |
| FCC | FCC compliance label | Electronic devices |
| UL | UL listing mark | Electrical components |
| DOT | Hazmat diamond labels | Hazardous materials |
| OSHA | Safety/warning labels | Industrial equipment |
| Prop 65 | California Prop 65 warning | Products sold in California with listed chemicals |
| RoHS | RoHS compliance label | Electronic/electrical products for applicable markets |

## Label Specifications

### Print Quality
- Minimum 300 DPI resolution
- Thermal transfer or laser printed (not inkjet for shipping labels)
- Labels must withstand shipping conditions without smearing or fading

### Adhesive
- Permanent adhesive for product labels
- Permanent adhesive for shipping labels
- Removable adhesive only if customer specifically requests

### Size Guidelines
- Product labels: 2"x3" minimum
- Shipping labels: 4"x6" standard
- Warning labels: Per applicable regulation
- Customer labels: Per customer specification

## Label Generation

Labels can be generated from the work order data. Standard label templates are stored in the Rev A label printer system. For custom labels, allow 1 additional business day for setup.
