# Order Stages Reference

## The 12-Stage Order Pipeline

### Stage 01: PO Received
- **Code:** `01-po-received`
- **Description:** Purchase order received from customer
- **Owner:** PM (Ray Yeh or Harley Scott)
- **Entry Criteria:** Signed PO or written order confirmation from customer
- **Exit Criteria:** PO logged, order record created
- **Typical Duration:** 0-1 days

### Stage 02: PO Acknowledged
- **Code:** `02-po-acknowledged`
- **Description:** PO confirmed and acknowledgment sent to customer
- **Owner:** PM
- **Entry Criteria:** PO reviewed for completeness and accuracy
- **Exit Criteria:** Acknowledgment email/letter sent to customer with confirmed pricing, quantity, and delivery timeline
- **Typical Duration:** 1-2 days

### Stage 03: Specs Sent to China
- **Code:** `03-specs-sent`
- **Description:** Manufacturing specifications transmitted to China partner
- **Owner:** PM
- **Entry Criteria:** PO acknowledged, specs/drawings finalized
- **Exit Criteria:** Specs received and confirmed by manufacturing partner
- **Typical Duration:** 1-3 days

### Stage 04: Manufacturing in Progress
- **Code:** `04-mfg-in-progress`
- **Description:** Manufacturing underway at China facility
- **Owner:** Manufacturing Partner
- **Entry Criteria:** Partner confirms production has started
- **Exit Criteria:** Partner confirms production complete with QC documentation
- **Typical Duration:** 14-45 days (varies by part complexity)

### Stage 05: Manufacturing Complete
- **Code:** `05-mfg-complete`
- **Description:** Manufacturing finished, awaiting shipment
- **Owner:** Manufacturing Partner
- **Entry Criteria:** Production QC pass, packaging complete
- **Exit Criteria:** Ready for pickup/shipment from China facility
- **Typical Duration:** 1-3 days

### Stage 06: Shipped from China
- **Code:** `06-shipped-china`
- **Description:** Product in transit from China
- **Owner:** Freight Forwarder / Logistics
- **Entry Criteria:** Tracking number or bill of lading issued
- **Exit Criteria:** Product arrives at destination (Rev A or customer)
- **Typical Duration:** 3-7 days (air) / 25-40 days (sea)

### Stage 07: Received at Rev A
- **Code:** `07-received-reva`
- **Description:** Product received at Rev A Manufacturing facility
- **Owner:** Rev A Warehouse
- **Entry Criteria:** Physical receipt at Rev A, receiving log entry
- **Exit Criteria:** Product checked in and staged for inspection
- **Typical Duration:** 1 day
- **Note:** Skipped for direct-to-customer routing

### Stage 08: Inspection Complete
- **Code:** `08-inspection-complete`
- **Description:** Quality inspection completed
- **Owner:** QC Team / PM
- **Entry Criteria:** Product staged for inspection
- **Exit Criteria:** Inspection report generated — PASS or NCR issued
- **Typical Duration:** 1-3 days
- **Note:** Skipped for direct-to-customer routing. If NCR, triggers pmlord-ncr

### Stage 09: Repackaged
- **Code:** `09-repackaged`
- **Description:** Product repackaged per customer requirements
- **Owner:** Rev A Warehouse
- **Entry Criteria:** Inspection passed, repackaging work order issued
- **Exit Criteria:** Repackaging work order completed, product ready for domestic shipment
- **Typical Duration:** 1-2 days
- **Note:** Skipped for direct-to-customer routing. Triggers pmlord-repackage

### Stage 10: Shipped to Customer
- **Code:** `10-shipped-customer`
- **Description:** Product shipped to end customer
- **Owner:** PM / Logistics
- **Entry Criteria:** Domestic tracking number generated
- **Exit Criteria:** Product in transit to customer
- **Typical Duration:** 1-5 days (domestic ground/air)

### Stage 11: Delivered
- **Code:** `11-delivered`
- **Description:** Product delivered to customer
- **Owner:** PM
- **Entry Criteria:** Carrier delivery confirmation or customer acknowledgment
- **Exit Criteria:** Delivery confirmed, satisfaction follow-up scheduled
- **Typical Duration:** 0-1 days

### Stage 12: Closed
- **Code:** `12-closed`
- **Description:** Order fully closed
- **Owner:** PM
- **Entry Criteria:** All of the following completed:
  - Delivery confirmed
  - Payment received
  - Documentation filed
  - Customer satisfaction check (T+3 days post-delivery)
  - Partner scorecard updated
- **Exit Criteria:** Order archived
- **Typical Duration:** 3-10 days after delivery

## Routing Variants

### Direct-to-Customer
Stages 07, 08, 09 are skipped. Product ships directly from China to the end customer. Stage 06 exits directly to Stage 10.

### Inspect-and-Forward
All 12 stages apply. Product ships from China to Rev A for inspection and repackaging before forwarding to the customer.
