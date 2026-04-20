# Cost Categories Reference

Complete definitions for all cost categories used in profitability analysis at Rev A Manufacturing.

## 1. Material Cost

**Definition:** The cost of raw materials consumed in manufacturing the parts.

**Includes:**
- Raw material purchase price (metal stock, resin pellets, sheet stock, castings)
- Material surcharges (tariff surcharges, alloy surcharges)
- Material testing/certification costs (mill certs, material certs)
- Freight to manufacturing partner (if billed separately from material)

**Excludes:**
- Packaging materials (see Repackaging)
- Consumables used during manufacturing (cutting fluid, abrasives -- include in Manufacturing)
- Hardware/fasteners added during assembly (see Assembly if applicable, or Manufacturing)

**Allocation notes:**
- If partner invoice bundles material + manufacturing, attempt to separate. If partner provides a material cost breakdown, use it. Otherwise, use industry-standard material cost ratios:
  - CNC Machining: material typically 25-40% of part cost
  - Injection Molding: material typically 30-50% of part cost
  - Sheet Metal: material typically 35-55% of part cost
  - Die Casting: material typically 20-35% of part cost
- Material waste/scrap factor should be estimated at quote time and compared to actual:
  - CNC Machining: 10-30% waste (buy-to-fly ratio)
  - Injection Molding: 2-5% waste (runners, rejects)
  - Sheet Metal: 10-25% waste (nesting efficiency)
  - Die Casting: 5-15% waste (gates, runners, flash)

## 2. Manufacturing Cost

**Definition:** The cost of converting raw material into finished parts. This is the partner's value-add.

**Includes:**
- Machine time (cycle time * machine rate)
- Labor (operator time, setup time)
- Setup/changeover charges
- Programming (CNC programming, if charged separately)
- Secondary operations (deburring, tapping, drilling not covered by primary process)
- In-process quality checks by manufacturing partner
- Consumables (tooling inserts, cutting fluid, etc.)

**Excludes:**
- Tooling/mold fabrication (see Tooling)
- Finishing operations (see Finishing)
- Material (see Material)
- Partner profit margin (this is embedded in their pricing; do not separate)

**Allocation notes:**
- If partner quotes a single per-part price that includes material, the manufacturing cost = partner price - estimated material cost
- Setup charges should be captured separately when possible, as they affect per-unit economics differently at different volumes

## 3. Tooling Cost (NRE)

**Definition:** Non-recurring engineering costs for tooling, fixtures, molds, and dies required to manufacture the parts.

**Includes:**
- Injection molds (single cavity, multi-cavity, family molds)
- Die casting dies
- Stamping dies and progressive dies
- CNC fixtures and jigs
- Checking fixtures and gauges
- Tooling modifications and repairs during production
- Tooling engineering and design (if charged)
- Tooling trials/samples (T1, T2 samples)

**Excludes:**
- Standard cutting tools and inserts (include in Manufacturing)
- Tooling maintenance for existing tools on repeat orders (include in Manufacturing unless major repair)

**Shared cost handling:**
- When tooling is used across multiple orders (common for repeat production), allocate the tooling cost proportionally:
  ```
  Tooling cost per order = (Total tooling cost / Expected lifetime units) * Units in this order
  ```
- Track total units produced against the tooling to maintain accurate amortization
- If tooling is customer-owned (customer paid for the mold), the tooling cost to Rev A is $0 but track it for reference
- If Rev A owns the tooling and charges the customer, the tooling cost is Rev A's investment and the charge is revenue

## 4. Finishing Cost

**Definition:** Cost of surface treatment, coating, or finishing operations applied after primary manufacturing.

**Includes:**
- Anodizing (Type II, Type III/hardcoat)
- Plating (nickel, chrome, zinc, gold)
- Powder coating
- Painting (wet paint, e-coat)
- Polishing and buffing
- Passivation
- Heat treatment
- Bead blasting, sandblasting
- Laser marking and engraving
- Silk screening and pad printing

**Excludes:**
- Deburring performed by the manufacturing partner (include in Manufacturing)
- Cleaning/washing that is part of the manufacturing process

**Allocation notes:**
- Finishing is often subcontracted by the primary manufacturing partner. The cost may appear on the partner invoice as a line item or may be a separate invoice from the finishing vendor.
- Reject rate for finishing operations is typically 2-5%. Factor this into per-unit cost.

## 5. Shipping Cost (International)

**Definition:** Cost to transport goods from the manufacturing origin (typically China) to the US port of entry or Rev A warehouse.

**Includes:**
- Freight charges (ocean FCL/LCL, air freight, courier)
- Origin charges (pickup, loading, container stuffing)
- Export documentation and customs clearance (origin)
- Freight insurance
- US customs duties and tariffs (HTS classification-based)
- US customs brokerage fees
- US port handling and terminal charges
- Drayage (port to warehouse)
- ISF (Importer Security Filing) filing fee

**Excludes:**
- Domestic shipping from Rev A to customer (see Domestic Shipping)
- Packaging materials for international shipment (typically included in partner pricing)

**Allocation notes:**
- Ocean freight rates fluctuate significantly. Quote-time estimates should use current market rates plus 10% buffer.
- Duties are calculated on the declared value. Ensure HTS classification is correct -- misclassification can cause significant variance.
- Section 301 tariffs (China-origin goods): check current rate for the specific HTS code. Currently 25% on most manufactured goods, but rates vary.

## 6. Shipping Cost (Domestic)

**Definition:** Cost to transport goods from Rev A warehouse to the customer's delivery address.

**Includes:**
- Carrier charges (UPS, FedEx, LTL, truckload)
- Packaging materials for domestic shipment (if separate from repackaging)
- Liftgate or special delivery requirements
- Residential delivery surcharges

**Excludes:**
- Return shipping for defective goods (see Warranty/Returns)

## 7. Quality/Inspection Cost

**Definition:** Cost of quality assurance activities performed by Rev A upon receipt of goods.

**Includes:**
- Incoming inspection labor (Rev A staff time)
- Dimensional inspection (CMM time, measurement tools)
- First Article Inspection Report (FAIR) preparation
- PPAP documentation preparation
- Material testing (hardness, tensile, chemical analysis)
- Third-party testing and certification (if required by customer)
- Inspection consumables (gauges, test pieces)

**Excludes:**
- Quality checks performed by the manufacturing partner (include in Manufacturing)
- Re-inspection after rework (include in Scrap/Rework)

**Allocation notes:**
- Standard incoming inspection: estimate 0.5-1 hour per lot for simple parts, 2-4 hours for complex/critical parts
- FAIR/PPAP adds 4-8 hours of documentation work
- Third-party testing costs vary widely; always get a quote before estimating

## 8. Scrap/Rework Cost

**Definition:** Cost of quality failures discovered at Rev A or by the customer, including rework to bring parts to specification.

**Includes:**
- Value of scrapped parts (material + manufacturing cost of rejected units)
- Rework labor (Rev A internal or subcontracted)
- Re-inspection after rework
- Additional material purchased for replacement parts
- Expedited manufacturing for replacement parts
- Expedited shipping for replacement parts
- Cost of sorting (100% inspection to separate good from bad)

**Excludes:**
- Root cause investigation time (include in Overhead)
- NCR documentation time (include in Overhead)

**Cost of Poor Quality (COPQ) calculation:**
```
COPQ = Scrap cost + Rework cost + Re-inspection cost + Replacement cost + Expedite premium
COPQ % = COPQ / Total order revenue * 100
```

Target COPQ: <2% of order revenue. Above 5% = escalate.

## 9. Warranty/Return Cost

**Definition:** Cost incurred after delivery to the customer for defective goods, warranty claims, or returns.

**Includes:**
- Return shipping (inbound from customer)
- Inspection of returned goods
- Rework of returned goods
- Replacement parts manufacturing and shipping
- Credit notes or refunds issued
- Customer visit/meeting costs related to quality escape
- Sorting at customer site (if Rev A sends personnel)

**Excludes:**
- Returns due to customer error (overordering, wrong spec provided) -- these are handled as change orders

**Allocation notes:**
- Warranty costs are the most damaging to profitability because they occur after revenue is booked
- Always track warranty costs even if small; they indicate quality escape and systemic issues

## 10. Repackaging Cost

**Definition:** Cost of repackaging goods at Rev A warehouse for domestic shipment to the customer.

**Includes:**
- Repackaging labor
- Packaging materials (boxes, foam, bags, labels, desiccant)
- Custom packaging (kitting, branded packaging, retail packaging)
- Labeling (part labels, barcode labels, shipping labels)

**Excludes:**
- Packaging done by the manufacturing partner for international shipment

**Allocation notes:**
- Standard repackaging: estimate $0.50-$2.00 per unit for small parts, $5-$15 for larger parts
- Custom/retail packaging can be significantly more; always get a specific quote

## 11. Overhead Allocation

**Definition:** Rev A internal costs that support the order but are not directly billable to a specific cost category.

**Includes:**
- PM time (order management, customer communication, partner coordination)
- Warehouse storage and handling
- Administrative costs (invoicing, accounts receivable, documentation)
- Insurance (general liability, product liability allocation)
- Facility costs allocation (rent, utilities for warehouse/office)
- IT systems and tools
- NCR/quality system documentation

**Default allocation rate:** 12% of total direct costs (material + manufacturing + finishing)

**Adjustable factors:**
- Complex orders with high PM involvement: increase to 15-18%
- Simple repeat orders with minimal PM touch: decrease to 8-10%
- Orders requiring extensive documentation (PPAP, AS9100): increase to 15-20%

## 12. Other/Miscellaneous

**Definition:** Catch-all for costs that do not fit neatly into the categories above.

**Examples:**
- Engineering consultation fees
- Prototype samples sent to customer before production
- Travel costs for supplier visits related to this order
- Legal costs (contract review, IP-related)
- Bank fees for international wire transfers

**Rule:** If "Other" exceeds 5% of total order cost, break it down into specific line items. Do not let this category become a dumping ground.
