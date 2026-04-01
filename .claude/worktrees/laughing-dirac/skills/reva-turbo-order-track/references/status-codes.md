# Order Status Codes Reference

## Primary Status Codes

| Code | Name | Description |
|------|------|-------------|
| `ACTIVE` | Active | Order is progressing normally through stages |
| `DELAYED` | Delayed | Order is behind schedule but still progressing |
| `HOLD` | On Hold | Order is paused awaiting resolution of an issue |
| `ESCALATED` | Escalated | Issue escalated per escalation matrix |
| `NCR` | Non-Conformance | Quality issue identified, NCR in progress |
| `CANCELLED` | Cancelled | Order cancelled by customer or Rev A |
| `CLOSED` | Closed | Order complete, all tasks finished |

## Delay Severity Codes

| Code | Severity | Days Behind | Action Required |
|------|----------|-------------|-----------------|
| `D1` | Minor | 1-3 days | Monitor, no customer notification required |
| `D2` | Moderate | 4-7 days | Notify PM lead, consider customer heads-up |
| `D3` | Significant | 8-14 days | Customer notification required, corrective plan needed |
| `D4` | Critical | 15+ days | Mandatory escalation to Senior PM / Donovan Weber |

## Quality Status Codes

| Code | Name | Description |
|------|------|-------------|
| `QC-PASS` | QC Pass | Inspection passed, no issues |
| `QC-MINOR` | QC Minor Issue | Minor cosmetic or documentation issue, reworkable |
| `QC-MAJOR` | QC Major Issue | Functional or specification non-conformance |
| `QC-REJECT` | QC Reject | Product rejected, requires remake or return |

## Shipping Status Codes

| Code | Name | Description |
|------|------|-------------|
| `SH-PENDING` | Ship Pending | Awaiting pickup or booking |
| `SH-BOOKED` | Ship Booked | Freight booked, awaiting pickup |
| `SH-INTRANSIT` | In Transit | Product moving, tracking active |
| `SH-CUSTOMS` | In Customs | Held at customs clearance |
| `SH-DELIVERED` | Delivered | Carrier confirms delivery |
| `SH-EXCEPTION` | Ship Exception | Delivery exception (damage, address issue, hold) |

## Payment Status Codes

| Code | Name | Description |
|------|------|-------------|
| `PAY-PENDING` | Payment Pending | Invoice sent, payment not yet received |
| `PAY-PARTIAL` | Partial Payment | Deposit or partial payment received |
| `PAY-RECEIVED` | Payment Received | Full payment received |
| `PAY-OVERDUE` | Payment Overdue | Payment past due date |
| `PAY-DISPUTE` | Payment Dispute | Customer disputing charge |
