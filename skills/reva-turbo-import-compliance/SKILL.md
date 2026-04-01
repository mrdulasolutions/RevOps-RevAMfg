---
name: reva-turbo-import-compliance
preamble-tier: 2
version: 1.0.0
description: |
  Import compliance gate for Rev A Manufacturing. HTS classification, duty
  calculation, tariff analysis, and customs documentation for goods arriving
  from China manufacturing partners. Powered by TradeInsights.ai API for
  classification intelligence. Integrates with logistics and inspection flow.
compatibility: Claude Code, Claude desktop, Claude CoWork
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - AskUserQuestion
---

## Preamble (run first)

```bash
mkdir -p ~/.reva-turbo/analytics
echo '{"skill":"reva-turbo-import-compliance","ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"}' >> ~/.reva-turbo/analytics/skill-usage.jsonl 2>/dev/null || true
```

## Purpose

Import compliance ensures that goods arriving from China manufacturing partners clear U.S. Customs and Border Protection (CBP) correctly. Every shipment into the U.S. requires proper classification, valuation, and documentation. Getting this wrong means delays, fines, or seizure.

This skill handles:
- **HTS classification** — Harmonized Tariff Schedule code assignment for each product
- **Duty calculation** — Duty rates, Section 301 tariffs (China-specific), anti-dumping/countervailing duties
- **Customs documentation** — Commercial invoice, packing list, entry summary (CBP 7501)
- **Country of origin** — Marking requirements, substantial transformation analysis
- **Free Trade Agreement** — Determine if any FTA benefits apply (generally not for China-origin goods)
- **Tariff engineering** — Identify legal opportunities to reduce duty burden

This skill uses **TradeInsights.ai** for HTS classification intelligence and tariff data when available, with manual classification fallback.

Read CLIENT.md for Rev A defaults before running.

## Step 0 — TradeInsights.ai Detection

Check for TradeInsights.ai API connectivity:

```bash
# Check for TradeInsights API key in config
_TI_API_KEY=$(~/.claude/skills/reva-turbo/bin/reva-turbo-config get tradeinsights_api_key 2>/dev/null || echo "")
_TI_AVAILABLE="no"

if [ -n "$_TI_API_KEY" ] && [ "$_TI_API_KEY" != "" ]; then
  _TI_AVAILABLE="yes"
fi

echo "TRADEINSIGHTS_AVAILABLE: $_TI_AVAILABLE"
echo "TRADEINSIGHTS_API_KEY: $([ -n "$_TI_API_KEY" ] && echo "configured" || echo "not configured")"
```

### If TradeInsights IS configured → Skip to Step 1

### If TradeInsights is NOT configured → Offer setup

> **Import Classification Engine**
>
> REVA-TURBO uses TradeInsights.ai (tradeinsights.ai) for HTS classification
> and tariff intelligence. API key not detected.
>
> **Options:**
>
> A) **Configure TradeInsights.ai API** — Enter your API key to enable
>    AI-powered HTS classification, duty calculation, and tariff analysis.
>    Visit tradeinsights.ai for API access.
>
> B) **Proceed with manual classification** — Use built-in HTS reference
>    tables and manual classification. Suitable for common items but less
>    accurate for complex/novel products.
>
> C) **Skip import compliance** — Proceed without import screening.
>    **WARNING:** Incorrect HTS classification can result in CBP penalties,
>    shipment delays, and retroactive duty assessments.
>
> Select A, B, or C: ___

**If A (Configure API):**

> Enter your TradeInsights.ai API key: ___

```bash
~/.claude/skills/reva-turbo/bin/reva-turbo-config set tradeinsights_api_key "{{API_KEY}}"
echo "TradeInsights.ai API key saved."
_TI_AVAILABLE="yes"
```

> **TradeInsights.ai connected.**
>
> Features enabled:
> - AI-powered HTS classification
> - Duty rate lookup (MFN, Section 301, AD/CVD)
> - Tariff trend analysis
> - Ruling database search
> - Country of origin analysis
>
> Proceeding to import screening...

**If B (Manual):**

> Manual classification mode. Using built-in HTS reference tables.
> Reference: `references/hts-common-codes.md`
>
> For complex items, consider getting a TradeInsights.ai API key or
> consulting a licensed customs broker.

**If C (Skip):**

Log and warn:

```bash
echo '{"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","type":"compliance_skip","gate":"import","reason":"user_opted_out","pm":"{{PM_NAME}}"}' >> ~/.reva-turbo/state/workflow-state.jsonl
```

---

## Step 0b — Determine Import Flow

Before collecting shipment details, identify the physical routing:

> **How is this shipment moving?**
>
> A) **Direct China→Customer** — Vendor ships directly to customer. Rev A is Importer of Record
>    but goods do not physically arrive at Rev A. Rev A handles customs remotely.
>
> B) **Inspect & Forward** — Goods ship to Rev A facility first for inspection,
>    then Rev A ships to customer.
>
> C) **Rev A Stock** — Goods ship to Rev A and enter inventory (not tied to a specific customer order).
>
> Select A-C: ___

**If Direct China→Customer (A):**

Rev A's role is remote importer of record. Key differences in this flow:
- **Entry filing:** Rev A's customs broker files CBP entry on Rev A's behalf (Rev A's IOR/EIN)
- **Delivery address on CBP entry:** Customer address (ultimate consignee)
- **Rev A address:** Listed as notify party and importer of record
- **Inspection:** Pre-shipment inspection (if required) must be arranged at origin — flag for `reva-turbo-inspect` to coordinate 3rd-party inspection in China
- **Duty payment:** Rev A pays duties (factor into landed cost / customer invoice)
- **No physical custody:** Rev A never touches the goods — compliance is entirely paperwork

Note this routing in state:
```bash
echo '{"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","type":"import_flow","po":"{{PO}}","routing":"direct_to_customer","ior":"Rev A Manufacturing","customer":"{{CUSTOMER}}"}' >> ~/.reva-turbo/state/workflow-state.jsonl
```

After flow identification, proceed to Step 1 with the appropriate context.

---

## Step 1 — Collect Shipment Details

> **Import Compliance Screening**
>
> **Shipment details:**
>
> 1. Order / PO number: ___
> 2. Manufacturing partner (shipper): ___
> 3. Country of manufacture: ___ (default: China)
> 4. Port of export: ___ (e.g., Shenzhen, Shanghai, Ningbo)
> 5. Port of entry (U.S.): ___ (e.g., Long Beach, Chicago, Newark)
> 6. Shipping method: Air / Ocean / Express courier
> 7. Estimated arrival date: ___
>
> **Product details** (repeat for each line item):
>
> 8. Product description: ___
> 9. Material composition: ___
>    (e.g., aluminum 6061, ABS plastic, 304 stainless steel)
> 10. Manufacturing process: ___
>     (CNC machining, injection molding, sheet metal, casting, etc.)
> 11. Quantity: ___
> 12. Unit value (FOB): ___
> 13. Total value: ___
> 14. Weight (kg): ___
> 15. Existing HTS code (if known): ___
> 16. End-use / application: ___

---

## Step 2 — HTS Classification

### With TradeInsights.ai

Use the TradeInsights API to classify each line item:

**API Request** (conceptual — adapt to actual TradeInsights API format):

```
POST /api/classify
{
  "description": "{{PRODUCT_DESCRIPTION}}",
  "material": "{{MATERIAL}}",
  "process": "{{PROCESS}}",
  "end_use": "{{END_USE}}",
  "country_of_origin": "{{COUNTRY}}"
}
```

**Expected Response:**
- Primary HTS code (10-digit)
- HTS description
- Confidence score
- Alternative HTS codes (if ambiguous)
- General duty rate
- Special duty rates (Section 301, AD/CVD)
- Relevant rulings

If the API returns multiple possible codes or low confidence, present options to PM:

> **Classification Ambiguity**
>
> TradeInsights suggests multiple HTS codes for "{{ITEM}}":
>
> | HTS Code | Description | Duty Rate | Confidence |
> |----------|-------------|-----------|------------|
> | {{CODE_1}} | {{DESC_1}} | {{RATE_1}} | {{CONF_1}} |
> | {{CODE_2}} | {{DESC_2}} | {{RATE_2}} | {{CONF_2}} |
>
> A) Use {{CODE_1}} (highest confidence)
> B) Use {{CODE_2}}
> C) Request binding ruling from CBP
> D) Consult customs broker
>
> Select: ___

### Without TradeInsights (Manual Classification)

Use the built-in HTS reference tables. Reference: `references/hts-common-codes.md`

Walk the PM through classification:

> **Manual HTS Classification for "{{ITEM}}"**
>
> 1. What is the primary material?
>    - Metal (Chapter 72-83) → Go to metals table
>    - Plastic (Chapter 39) → Go to plastics table
>    - Rubber (Chapter 40) → Go to rubber table
>
> 2. What is the form?
>    - Raw material / stock
>    - Semi-finished (bar, plate, tube)
>    - Finished part (machined, molded, fabricated)
>    - Assembly / mechanism
>
> 3. What is the function?
>    - Structural / mechanical
>    - Electrical / electronic
>    - Fluid handling
>    - Fastening / connecting

Use the classification tree in `references/hts-classification-tree.md` to narrow down.

---

## Step 3 — Duty Calculation

Calculate total landed cost impact:

### Standard Duty (MFN Rate)

Look up the MFN (Most Favored Nation) duty rate for the HTS code. This is the base rate for China (China has MFN/NTR status).

### Section 301 Tariffs (China-Specific)

China-origin goods are subject to additional Section 301 tariffs. Check which list the HTS code falls under:

| List | Additional Tariff | Coverage |
|------|------------------|----------|
| List 1 | 25% | $34B in goods (industrial, tech) |
| List 2 | 25% | $16B in goods (semiconductors, chemicals) |
| List 3 | 25% | $200B in goods (broad industrial/consumer) |
| List 4A | 7.5% | $120B in goods (consumer, some industrial) |

Reference: `references/section-301-lists.md`

> **NOTE:** Section 301 tariff rates change frequently. If using manual mode,
> verify current rates at ustr.gov or hts.usitc.gov. TradeInsights.ai provides
> real-time rates.

### Anti-Dumping / Countervailing Duties (AD/CVD)

Check if the product is subject to AD/CVD orders:
- Aluminum extrusions from China (AD/CVD)
- Steel products from China (various AD/CVD orders)
- Certain castings from China

Reference: `references/adcvd-orders.md`

### Total Duty Calculation

```
Base duty (MFN rate):           ${{MFN_DUTY}}
Section 301 tariff:             ${{SECTION_301}}
AD/CVD duty (if applicable):    ${{ADCVD}}
Merchandise Processing Fee:     ${{MPF}} (0.3464% of value, min $31.67, max $614.35)
Harbor Maintenance Fee:         ${{HMF}} (0.125% for ocean shipments)
─────────────────────────────────────────
Total duties & fees:            ${{TOTAL_DUTIES}}
Effective duty rate:            {{EFFECTIVE_RATE}}%
Landed cost per unit:           ${{LANDED_COST}}
```

Present to PM:

> ## Duty Impact Summary — {{ORDER_ID}}
>
> | Line Item | HTS Code | Value | MFN Duty | Sec 301 | AD/CVD | Total Duty | Eff. Rate |
> |-----------|----------|-------|----------|---------|--------|------------|-----------|
> | {{ITEM_1}} | {{HTS_1}} | ${{VAL_1}} | ${{MFN_1}} | ${{301_1}} | ${{AD_1}} | ${{TOT_1}} | {{RATE_1}}% |
>
> **Total shipment value:** ${{TOTAL_VALUE}}
> **Total duties & fees:** ${{TOTAL_DUTIES}}
> **Effective duty rate:** {{OVERALL_RATE}}%
> **Landed cost impact on margin:** {{MARGIN_IMPACT}}

---

## Step 4 — Customs Documentation Check

Verify all required documentation is available:

> ## Customs Documentation Checklist
>
> **Required for ALL shipments:**
> - [ ] Commercial invoice (with seller, buyer, description, value, terms)
> - [ ] Packing list (with weights, dimensions, quantities per carton)
> - [ ] Bill of lading (ocean) or airway bill (air)
> - [ ] Country of origin marking compliance
>
> **Required for formal entry (value > $2,500):**
> - [ ] CBP Entry Summary (Form 7501) — filed by customs broker
> - [ ] Bond (continuous or single entry)
> - [ ] Importer of record number (Rev A's IOR/EIN)
>
> **May be required:**
> - [ ] Material certifications (if quality gate requires)
> - [ ] Test reports
> - [ ] FDA prior notice (if applicable)
> - [ ] CPSC certificates (if consumer product)
> - [ ] FCC declaration (if electronic)
> - [ ] Lacey Act declaration (if wood products)
>
> **China-specific:**
> - [ ] Certificate of origin (for AD/CVD cases)
> - [ ] Section 301 exclusion documentation (if granted)

Flag any missing documents and route to `reva-turbo-logistics` for follow-up.

---

## Step 5 — Tariff Mitigation Opportunities

Analyze legal opportunities to reduce duty burden:

> ## Tariff Optimization Analysis
>
> **Current duty burden:** ${{TOTAL_DUTIES}} ({{EFFECTIVE_RATE}}%)
>
> **Potential mitigation strategies:**
>
> 1. **First Sale Valuation** — If the China partner buys materials from
>    a sub-supplier, the "first sale" price (lower) may be used for duty
>    calculation instead of the transaction price to Rev A.
>    Potential savings: ${{FIRST_SALE_SAVINGS}}
>
> 2. **Foreign Trade Zone (FTZ)** — If Rev A operates in or near an FTZ,
>    goods can be admitted duty-free and duties paid only on goods entering
>    U.S. commerce (or at finished product rate if lower).
>    Applicable: {{FTZ_APPLICABLE}}
>
> 3. **Tariff Engineering** — Importing components separately vs assembled
>    may result in lower duty rates depending on HTS classification.
>    Applicable: {{TE_APPLICABLE}}
>
> 4. **Section 301 Exclusion** — Check if any exclusions have been granted
>    for this HTS code. Exclusions eliminate the Section 301 tariff.
>    Status: {{EXCLUSION_STATUS}}
>
> 5. **Duty Drawback** — If Rev A re-exports the finished goods, duties
>    paid on imported materials may be recoverable (99% refund).
>    Applicable: {{DRAWBACK_APPLICABLE}}

---

## Step 6 — Compliance Decision Gate

**HUMAN-IN-THE-LOOP CHECKPOINT**

> ## Import Compliance Summary — {{ORDER_ID}}
>
> **Shipment:** {{PARTNER}} → {{PORT_OF_ENTRY}}
> **Products:** {{LINE_ITEM_COUNT}} line items
> **Total value:** ${{TOTAL_VALUE}}
> **Total duties:** ${{TOTAL_DUTIES}} ({{EFFECTIVE_RATE}}%)
>
> ### Classification Status
> | Item | HTS | Method | Confidence |
> |------|-----|--------|------------|
> | {{ITEM}} | {{HTS}} | {{METHOD}} | {{CONFIDENCE}} |
>
> ### Documentation Status
> - Required docs: {{DOCS_REQUIRED}}
> - Available: {{DOCS_AVAILABLE}}
> - Missing: {{DOCS_MISSING}}
>
> ### Flags
> {{FLAGS_IF_ANY}}
>
> ---
>
> A) **PROCEED** — Classification confirmed, documentation ready, duties calculated.
>    Clear for customs entry.
> B) **HOLD** — Missing documentation or classification uncertainty. Pause until resolved.
> C) **ESCALATE** — Potential AD/CVD issue, classification dispute, or compliance concern.
>    Route to customs broker or legal.
> D) **ADJUST** — Modify classification or explore tariff mitigation before entry.
>
> Select A-D: ___

### If PROCEED:

Log clearance:

```bash
echo '{"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","type":"import_compliance","gate":"CLEARED","order_id":"{{ORDER_ID}}","hts_codes":["{{HTS_CODES}}"],"total_duties":"{{TOTAL_DUTIES}}","effective_rate":"{{EFFECTIVE_RATE}}","method":"{{CLASSIFICATION_METHOD}}","pm":"{{PM_NAME}}"}' >> ~/.reva-turbo/state/workflow-state.jsonl
```

Feed duty costs to `reva-turbo-profit` for actual cost tracking:

```bash
echo '{"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","type":"actual_cost","order_id":"{{ORDER_ID}}","category":"duties_tariffs","amount":{{TOTAL_DUTIES}},"details":"HTS {{HTS_CODES}}, MFN {{MFN_RATE}}%, Sec301 {{SEC301_RATE}}%"}' >> ~/.reva-turbo/state/active-orders.jsonl
```

### If HOLD:

Identify missing items, create action list, notify PM via pulse.

### If ESCALATE:

Route to `reva-turbo-escalate` with import compliance context.

### If ADJUST:

Loop back to Step 2 or Step 5 for reclassification or mitigation analysis.

---

## Step 7 — Generate Import Compliance Record

Save documentation for audit trail. Use template: `templates/Import Compliance Record.md`

Save as `REVA-TURBO-ImportCompliance-{{YYYY-MM-DD}}-{{SLUG}}.docx` if report_format is docx.

---

## Pipeline Integration

### Where this skill sits in the lifecycle:

```
reva-turbo-china-track (goods shipped from China)
  -> *** reva-turbo-import-compliance *** (HARD GATE — before customs entry)
    -> reva-turbo-logistics (customs clearance with classification data)
      -> reva-turbo-inspect (goods received at Rev A)
```

### Autopilot integration:

Import compliance is a **PAUSE** gate in autopilot mode when:
- Any classification has low confidence
- Documentation is missing
- AD/CVD flags are present
- Total duties exceed a threshold (configurable via rules engine)

Import compliance can **AUTO-ADVANCE** in autopilot mode when:
- All items are EAR99 with high-confidence HTS codes
- All documentation is complete
- No AD/CVD flags
- Duties within expected range

### Rules integration:

- RULE-IMP01: Auto-flag shipments with duties > $5,000 for finance review
- RULE-IMP02: Require customs broker review for any AD/CVD-subject items
- RULE-IMP03: Alert when effective duty rate exceeds quoted duty estimate by >5%
- RULE-IMP04: Flag new HTS codes not previously imported (first-time classification review)

### Connector integration:

- **reva-turbo-profit:** Duty costs feed into actual vs estimated cost tracking
- **reva-turbo-logistics:** Classification data used for customs entry preparation
- **reva-turbo-pulse:** Alert on duty spikes, missing docs, AD/CVD flags
- **reva-turbo-crm-connector:** Duty cost data available for customer-facing reporting
- **reva-turbo-audit-trail:** All classification decisions logged
- **reva-turbo-change-order:** If specs change mid-stream, re-classify (HTS may change)

---

## TradeInsights.ai Reference

| Resource | Details |
|----------|---------|
| Website | tradeinsights.ai |
| API | REST API (key-based authentication) |
| Capabilities | HTS classification, duty rates, tariff analysis, ruling search |
| Integration | API calls from REVA-TURBO skill, results parsed and displayed |
| Fallback | Manual classification using built-in HTS reference tables |

---

## Lifecycle

- **Previous skill:** reva-turbo-china-track (goods shipped from partner)
- **Next skill:** reva-turbo-logistics (customs entry and clearance) → reva-turbo-inspect
- **On HOLD/ESCALATE:** reva-turbo-escalate with import compliance context
- **Data feed:** reva-turbo-profit (actual duty costs)
