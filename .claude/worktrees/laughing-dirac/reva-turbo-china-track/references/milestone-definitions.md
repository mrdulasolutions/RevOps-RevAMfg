# 10-Milestone Definitions for China Manufacturing Tracking

## Overview

Every order tracked through a Chinese manufacturing partner follows these 10 milestones. Each milestone has defined entry criteria, exit criteria, expected duration, and key actions.

---

## M1 — Specs Confirmed

| Field | Value |
|-------|-------|
| **Description** | Manufacturing partner has received and confirmed understanding of all specifications, drawings, and requirements. |
| **Entry criteria** | Manufacturing package sent to partner (via `/reva-turbo-china-package`). |
| **Exit criteria** | Partner provides written confirmation (email/WeChat) that specs are understood, no questions remain. |
| **Expected duration** | 1-3 business days after package delivery. |
| **Key actions** | Confirm partner received all files. Address any questions. Get written confirmation. |
| **Risk indicators** | Partner asks many clarifying questions (may indicate spec ambiguity). No response within 3 days. |

## M2 — Tooling Started

| Field | Value |
|-------|-------|
| **Description** | Partner has begun tooling, fixture, or jig fabrication. For non-tooled parts (standard machining), this is programming and setup. |
| **Entry criteria** | M1 complete. Partner has confirmed timeline and pricing. |
| **Exit criteria** | Partner confirms tooling/setup has started with photos or update. |
| **Expected duration** | 1-5 business days after M1. |
| **Key actions** | Confirm tooling approach. Request progress photos. Verify tool steel/material. |
| **Risk indicators** | Delayed start may indicate material sourcing issues or capacity constraints. |

## M3 — Tooling Complete / First Article Produced

| Field | Value |
|-------|-------|
| **Description** | Tooling is complete and first article samples have been produced. |
| **Entry criteria** | M2 complete. |
| **Exit criteria** | First article parts produced. Partner sends photos, measurements, and/or samples. |
| **Expected duration** | 2-6 weeks after M2, depending on complexity. Injection molds: 4-8 weeks. Machining fixtures: 1-2 weeks. |
| **Key actions** | Schedule First Article Inspection (FAI). Request dimensional report from partner. Request sample shipment if needed. |
| **Risk indicators** | Delays here are common. Monitor weekly. Tooling rework adds 1-3 weeks. |

## M4 — First Article Approved

| Field | Value |
|-------|-------|
| **Description** | First article has been inspected and approved by Rev A PM. |
| **Entry criteria** | First article received or remote inspection completed. FAI report reviewed. |
| **Exit criteria** | PM signs off on first article. Written approval sent to partner. |
| **Expected duration** | 3-7 business days after M3 (includes shipping time for samples if physical review needed). |
| **Key actions** | Run `/reva-turbo-inspect` for FAI. Document any deviations. Approve or request rework. |
| **Risk indicators** | First article rejection restarts M3. Average adds 2-4 weeks. |

## M5 — Production Started

| Field | Value |
|-------|-------|
| **Description** | Full production run has begun. |
| **Entry criteria** | M4 complete. Production PO confirmed. |
| **Exit criteria** | Partner confirms production is running with estimated completion date. |
| **Expected duration** | 1-3 business days after M4. |
| **Key actions** | Confirm production quantity. Verify raw material availability. Set M6 check-in date. |
| **Risk indicators** | Delay between M4 and M5 may indicate material shortage or capacity issues. |

## M6 — Production 50% Complete

| Field | Value |
|-------|-------|
| **Description** | Approximately half of the order quantity has been produced. |
| **Entry criteria** | M5 complete. |
| **Exit criteria** | Partner confirms ~50% of parts produced. Progress photos/report. |
| **Expected duration** | Varies by quantity and process. Calculate from production rate. |
| **Key actions** | Schedule in-process quality check. Review progress photos. Assess quality consistency. |
| **Risk indicators** | Quality drift at 50% is common. Dimensional checks critical. Production rate slower than planned. |

## M7 — Production Complete

| Field | Value |
|-------|-------|
| **Description** | All parts in the order have been produced. |
| **Entry criteria** | M6 complete. |
| **Exit criteria** | Partner confirms 100% of order quantity produced. Final count matches PO. |
| **Expected duration** | Varies by quantity. Typically mirrors M5-M6 duration. |
| **Key actions** | Confirm final quantity (including any overage/shortage). Request final QC schedule. |
| **Risk indicators** | Short count (produced less than ordered). Quality rejects reducing yield. |

## M8 — QC Passed

| Field | Value |
|-------|-------|
| **Description** | Partner's quality control inspection is complete and parts have passed. |
| **Entry criteria** | M7 complete. |
| **Exit criteria** | Partner provides QC report (dimensional, visual, material cert). Report reviewed and accepted by Rev A. |
| **Expected duration** | 2-5 business days after M7. |
| **Key actions** | Review partner QC report. Compare against original specs. Flag any deviations. Accept or reject. |
| **Risk indicators** | QC failure requires rework (back to M5) or scrap. Partner QC reports that show 100% pass rate on all dims should be verified. |

## M9 — Packed and Ready to Ship

| Field | Value |
|-------|-------|
| **Description** | Parts are packed, labeled, and ready for pickup/shipment. |
| **Entry criteria** | M8 complete. |
| **Exit criteria** | Partner provides packing photos, packing list, weight, and box count. |
| **Expected duration** | 1-3 business days after M8. |
| **Key actions** | Verify packing meets requirements (protection, labeling). Confirm shipping details (carrier, route, customs docs). |
| **Risk indicators** | Incorrect packing can cause damage in transit. Missing customs documentation causes port delays. |

## M10 — Shipped

| Field | Value |
|-------|-------|
| **Description** | Parts have left the partner facility and are in transit to Rev A. |
| **Entry criteria** | M9 complete. Shipping documents prepared. |
| **Exit criteria** | Tracking number provided. Bill of lading or air waybill issued. |
| **Expected duration** | 1-2 business days after M9. |
| **Key actions** | Record tracking number. Calculate ETA at Rev A dock. Set up `/reva-turbo-inspect` for incoming inspection. Notify PM of expected arrival. |
| **Risk indicators** | Customs holds. Shipping delays (weather, port congestion). Incorrect HS codes. |

---

## Typical Total Lead Times

| Part Type | M1 to M10 (weeks) | Notes |
|-----------|-------------------|-------|
| Simple machined part | 3-5 | No tooling needed |
| Complex machined part | 4-7 | Fixture fabrication at M2 |
| Injection molded part | 8-14 | Mold fabrication is the long pole |
| Sheet metal part | 3-6 | Die/fixture dependent |
| Assembly | 6-12 | Depends on component lead times |

## Transit Times (after M10)

| Method | China to US West Coast | China to US East Coast |
|--------|----------------------|----------------------|
| Sea freight | 14-21 days | 25-35 days |
| Air freight | 3-5 days | 4-7 days |
| Express (DHL/FedEx/UPS) | 2-4 days | 3-5 days |
