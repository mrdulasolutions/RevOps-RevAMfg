# Customs Documentation Reference

## Required Documents for China Imports

### 1. Commercial Invoice
- **Purpose:** Declares the transaction details, value, and terms of sale
- **Required Fields:**
  - Seller name and address (China supplier)
  - Buyer name and address (Rev A Manufacturing)
  - Invoice number and date
  - Description of goods (detailed, matching HTS classification)
  - Quantity and unit of measure
  - Unit price and total value (USD)
  - Currency and Incoterms (FOB, CIF, DDP, etc.)
  - Country of origin: China
  - PO number reference
- **Copies:** Original + 3 copies

### 2. Packing List
- **Purpose:** Details the physical contents of the shipment
- **Required Fields:**
  - Shipper and consignee information
  - Number of packages/cartons/pallets
  - Gross weight and net weight per package
  - Dimensions per package
  - Description of contents per package
  - Marks and numbers on packages
  - Total weight and volume
- **Copies:** Original + 2 copies

### 3. Bill of Lading (Ocean) / Air Waybill (Air)
- **Purpose:** Contract of carriage and receipt of goods
- **Type:**
  - **Ocean B/L:** Negotiable or non-negotiable. Original required for release at destination.
  - **Air Waybill (AWB):** Non-negotiable. Consignee identified for pickup.
- **Key Fields:** Shipper, consignee, notify party, port of loading/discharge, description of goods, freight charges

### 4. CBP Form 7501 (Entry Summary)
- **Purpose:** U.S. Customs and Border Protection entry declaration
- **Filed By:** Licensed customs broker
- **Contains:** HTS classification, duty rate, value, country of origin, entry type
- **Deadline:** Filed within 15 days of arrival at U.S. port

### 5. HTS Classification
- **Purpose:** Harmonized Tariff Schedule code determines duty rate
- **Who Determines:** Customs broker, can be verified via USITC HTS database
- **Format:** 10-digit code (e.g., 8481.80.5090 for industrial valves)
- **Importance:** Incorrect classification risks penalties, delayed clearance, or overpayment of duties
- **Section 301 Tariffs:** Many China-origin products subject to additional 7.5-25% tariff. Verify current rates.

### 6. Country of Origin Certificate
- **Purpose:** Certifies where the goods were manufactured
- **Issued By:** China Chamber of Commerce or manufacturer
- **Required When:** Preferential duty rates or when requested by CBP

### 7. ISF (Importer Security Filing) - Ocean Only
- **Purpose:** Advance cargo information for U.S. Customs (10+2 filing)
- **Deadline:** Must be filed at least 24 hours before vessel loading at origin port
- **Penalty for Late Filing:** $5,000 per violation
- **Filed By:** Importer or customs broker
- **Key Data Points:**
  - Manufacturer name and address
  - Seller name and address
  - Buyer name and address
  - Ship-to name and address
  - Container stuffing location
  - Consolidator name and address
  - HTS number (6-digit minimum)
  - Country of origin

## Additional Documents (As Required)

### 8. Certificate of Conformity / Test Reports
- **When:** Products subject to safety standards (CPSC, FDA, FCC, etc.)
- **Purpose:** Proves product meets U.S. regulatory requirements

### 9. Material Safety Data Sheet (MSDS/SDS)
- **When:** Shipment contains chemicals, coatings, or hazardous materials
- **Purpose:** Hazmat classification and handling requirements

### 10. Power of Attorney (POA)
- **When:** First shipment with a customs broker
- **Purpose:** Authorizes the broker to act on behalf of Rev A Manufacturing
- **Duration:** Typically remains in effect until revoked

### 11. Customs Bond
- **Type:** Continuous bond (covers all entries for 12 months) or single entry bond
- **Amount:** Typically 10% of total duties paid in prior year (minimum $50,000 for continuous)
- **Purpose:** Guarantees payment of duties, taxes, and fees to CBP

## Duty and Tax Reference

| Fee Type | Typical Range | Notes |
|----------|--------------|-------|
| Standard Duty | 0-25% | Based on HTS classification |
| Section 301 Tariff | 7.5-25% | Additional tariff on China-origin goods |
| Merchandise Processing Fee | 0.3464% | Min $31.67, Max $614.35 per entry |
| Harbor Maintenance Fee | 0.125% | Ocean shipments only |
| State Sales/Use Tax | Varies | If applicable at destination state |

## Document Retention

All customs documents must be retained for **5 years** from the date of entry per 19 USC 1508. Store copies in:

```
~/.reva-turbo/orders/{{PO_NUMBER}}/customs/
```
