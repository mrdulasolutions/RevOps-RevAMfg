# Email Matching Rules

How to match incoming emails to REVA-TURBO entities: orders, customers, partners, and workflow actions.

---

## Matching Pipeline

Process each incoming email through these stages in order:

### Stage 1: Sender Identification

| Method | Priority | Match Logic |
|--------|----------|-------------|
| Email address exact match | 1 (highest) | sender@domain matches a customer or partner contact email |
| Email domain match | 2 | @domain.com matches a customer or partner company domain |
| Sender name fuzzy match | 3 | "John Smith" fuzzy matches a contact name in REVA-TURBO |
| Reply-to thread | 4 | Email is a reply to a thread REVA-TURBO already tracks |
| Unknown | 5 | No match found — flag for PM triage |

**Domain-to-entity mapping (loaded from customer/partner profiles):**
```
acmecorp.com → Acme Corporation (customer)
prototech.io → ProtoTech Industries (customer)
szmfg.cn → Shenzhen MFG Co. (partner)
gdprecision.com → Guangdong Precision (partner)
```

### Stage 2: Reference Number Extraction

Scan subject line and body for reference numbers:

| Pattern | Regex | Entity Type |
|---------|-------|-------------|
| REVA-TURBO Order ID | `ORD-\d{4}-\d{3,4}` | Order |
| PO Number | `PO[-#]?\s?\d{4,}` | Order / Quote |
| Quote ID | `QUO-\d{4}-\d{3,4}` | Quote |
| NCR Number | `NCR-\d{4}-\d{3}` | NCR |
| Part Number | `PART-\w{2,10}` or `P/N:?\s?\w+` | Part |
| Invoice Number | `INV-\d{4}-\d{3,4}` | Invoice |
| Change Order | `CO-ORD-\d{4}-\d{4}-\d{2}` | Change Order |
| Tracking Number | `[A-Z]{2}\d{9}[A-Z]{2}` (international) | Shipment |
| Tracking Number | `\d{10,22}` (UPS/FedEx/DHL) | Shipment |
| Container Number | `[A-Z]{4}\d{7}` | Shipment |
| Bill of Lading | `BL[-/]?\w{6,}` | Shipment |

### Stage 3: Content Classification

Classify the email intent based on subject line and body keywords:

#### RFQ / Quote Request

**Subject patterns (high confidence):**
- "RFQ" or "RFQ:" or "RE: RFQ"
- "Request for Quote"
- "Request for Quotation"
- "Quotation Request"

**Body patterns (medium confidence):**
- "Can you quote"
- "What's your price for"
- "Looking for a supplier"
- "Need pricing on"
- "Attached are drawings for quoting"

**Attachment indicators:**
- .pdf, .step, .stp, .iges, .dxf drawings
- .xlsx BOM or part list
- Multiple files suggesting a package

**Action:** Create RFQ intake record. PM confirms.

#### Purchase Order

**Subject patterns (high confidence):**
- "PO" + number
- "Purchase Order"
- "Order Confirmation"

**Body patterns:**
- "Please find attached PO"
- "Attached is our purchase order"
- "We would like to proceed"
- "Approved. Please proceed."

**Attachment indicators:**
- .pdf with "Purchase Order" in filename
- .pdf matching customer PO template

**Action:** Match to pending quote by customer + approximate amount. PM confirms link.

**Matching logic for PO-to-Quote:**
1. Same customer (by sender domain)
2. Amount within 5% of quote value
3. Part number matches
4. Quote date within last 90 days
5. If multiple quotes match: present all to PM

#### Partner Milestone Update

**Sender:** From a known partner email domain

**Subject/body keywords:**

| Keyword Group | Milestone |
|--------------|-----------|
| "tooling complete", "mold ready", "tool approved" | Tooling Complete |
| "T1 sample", "first article", "sample ready", "sample shipped" | First Article |
| "production start", "mass production started", "in production" | Production Started |
| "production complete", "order complete", "all parts ready" | Production Complete |
| "QC report", "inspection report", "quality report" | QC Complete |
| "packing", "packed", "ready to ship" | Packing Complete |
| "shipped", "dispatched", "on the way", "left factory" | Shipped |
| "tracking number", "AWB", "BL number" | Shipping Update |
| "delay", "behind schedule", "delayed", "push back" | Delay Alert |
| "issue", "problem", "defect found", "quality issue" | Quality Alert |

**Action:** Update china-track milestone for matched order. PM confirms.

#### Customer Complaint / Issue

**Subject patterns:**
- "Complaint"
- "Issue with order"
- "Problem"
- "Defect"
- "Not as expected"
- "Return"

**Action:** Flag for PM review. May trigger NCR or escalation.

#### Change Request

**Subject patterns:**
- "Change" + order reference
- "Revision"
- "Updated drawing"
- "Modified spec"
- "New quantity"

**Action:** Route to change-order review. PM confirms.

#### Financial / Invoice

**Subject patterns:**
- "Invoice"
- "Payment"
- "Statement"
- "Remittance"
- "Past due"

**Action:** Flag for PM review. Link to order if reference number found.

### Stage 4: Attachment Classification

| File Extension | Type | Routing |
|---------------|------|---------|
| .pdf | Drawing, PO, Invoice, Report | Context-dependent |
| .step, .stp | 3D CAD model | RFQ intake / change order |
| .iges, .igs | 3D CAD model | RFQ intake / change order |
| .dxf, .dwg | 2D drawing | RFQ intake / change order |
| .xlsx, .xls | BOM, spec sheet, price list | RFQ intake / quote |
| .docx, .doc | Spec document, report | Context-dependent |
| .jpg, .png | Photo (inspection, defect) | NCR / inspection |
| .zip | Package of files | Expand and classify individually |

---

## Matching Confidence Levels

| Confidence | Criteria | PM Action |
|-----------|----------|-----------|
| **High** | Exact reference number match + known sender | Auto-link, PM confirms |
| **Medium** | Domain match + keyword match, no exact reference | Show match, PM confirms |
| **Low** | Keyword match only, unknown sender | Show as suggestion, PM decides |
| **None** | No patterns matched | Show in unmatched queue |

---

## Unmatched Email Queue

Emails that don't match any pattern go to the unmatched queue:

```bash
echo '{"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","from":"{{FROM}}","subject":"{{SUBJECT}}","classification":"unmatched","status":"pending_review"}' >> ~/.reva-turbo/state/email-queue.jsonl
```

PM reviews the queue periodically and either:
- Manually links to a REVA-TURBO entity
- Dismisses as not relevant
- Creates a new entity from the email
