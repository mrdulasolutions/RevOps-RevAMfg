# Quality Checkpoint Scheduling Guide

## Overview

Quality checkpoints are scheduled at specific milestones to catch issues early and prevent costly rework or returns. The type and depth of inspection depends on part value, complexity, order history, and customer requirements.

## Checkpoint Schedule

### CP1 — First Article Inspection (at M3)

| Field | Value |
|-------|-------|
| **Trigger** | M3 — Tooling complete / First article produced |
| **Purpose** | Verify that the first produced parts meet all dimensional and quality requirements before authorizing full production. |
| **Inspection type** | Remote (standard) or Onsite (high-value/critical) |
| **Remote method** | Partner sends: photos (all sides), dimensional report, material cert |
| **Onsite method** | Third-party inspector or Rev A representative visits partner facility |
| **Deliverables** | FAI report, dimensional data, photos, material certification |
| **Pass criteria** | All critical dims within tolerance. Material cert matches spec. No visual defects. |
| **Fail action** | Issue NCR via `/reva-turbo-ncr`. Partner reworks tooling. Return to M2/M3. |

### CP2 — In-Process Check (at M6)

| Field | Value |
|-------|-------|
| **Trigger** | M6 — Production 50% complete |
| **Purpose** | Verify quality consistency during production run. Catch drift before full production is complete. |
| **Inspection type** | Remote (standard) or Onsite (high-value/high-qty) |
| **Remote method** | Partner sends: sample photos, dimensional spot-check on 5-10 pieces, process photos |
| **Onsite method** | Third-party inspector checks random sample per AQL table |
| **Deliverables** | In-process inspection report, sample measurements, process photos |
| **Pass criteria** | Sampled parts within tolerance. No systematic defects. Process stable. |
| **Fail action** | Pause production. Investigate root cause. Issue NCR if needed. |

### CP3 — Final QC (at M8)

| Field | Value |
|-------|-------|
| **Trigger** | M8 — QC passed (partner's own QC) |
| **Purpose** | Verify partner's QC results. Independent confirmation before shipping. |
| **Inspection type** | Partner QC report review (standard) or Onsite (high-value/new partner) |
| **Remote method** | Review partner's QC report, dimensional data, photos. Cross-check against specs. |
| **Onsite method** | Third-party inspector performs AQL inspection at partner facility |
| **Deliverables** | Final QC report, certificate of conformance, packing photos |
| **Pass criteria** | QC report shows all dims in spec. AQL sampling passes. CoC issued. |
| **Fail action** | Reject lot. Issue NCR. Determine disposition (rework, sort, scrap). |

### CP4 — Pre-Ship Verification (at M9)

| Field | Value |
|-------|-------|
| **Trigger** | M9 — Packed and ready to ship |
| **Purpose** | Verify correct quantity, packing integrity, labeling, and shipping documentation. |
| **Inspection type** | Remote (photos/video) |
| **Remote method** | Partner sends: packing photos, box/crate labels, packing list, weight, customs docs |
| **Deliverables** | Packing verification photos, packing list, shipping documents |
| **Pass criteria** | Quantity matches PO. Packing adequate for transit. Labels correct. Docs complete. |
| **Fail action** | Repack. Correct documentation. Delay shipment until resolved. |

## When to Require Onsite Inspection

| Condition | CP1 | CP2 | CP3 | CP4 |
|-----------|-----|-----|-----|-----|
| New partner (first order) | Onsite | Remote | Onsite | Remote |
| Part value > $10,000 per order | Onsite | Onsite | Onsite | Remote |
| Critical application (medical, aero) | Onsite | Onsite | Onsite | Remote |
| Previous quality issues with partner | Onsite | Onsite | Onsite | Remote |
| Repeat order, good history | Remote | Remote | Remote | Remote |
| High quantity (> 10,000 pcs) | Remote | Onsite | Onsite | Remote |

## AQL Sampling Levels

For in-process and final inspections, use AQL (Acceptable Quality Level) sampling per ISO 2859-1:

| Order Quantity | Sample Size (Level II) | AQL 1.0 Accept/Reject | AQL 2.5 Accept/Reject |
|---------------|----------------------|----------------------|----------------------|
| 2-8 | 2 | 0/1 | 0/1 |
| 9-15 | 3 | 0/1 | 0/1 |
| 16-25 | 5 | 0/1 | 0/1 |
| 26-50 | 8 | 0/1 | 0/1 |
| 51-90 | 13 | 0/1 | 1/2 |
| 91-150 | 20 | 0/1 | 1/2 |
| 151-280 | 32 | 1/2 | 2/3 |
| 281-500 | 50 | 1/2 | 3/4 |
| 501-1200 | 80 | 2/3 | 5/6 |
| 1201-3200 | 125 | 3/4 | 7/8 |
| 3201-10000 | 200 | 5/6 | 10/11 |

Use AQL 1.0 for critical dimensions and AQL 2.5 for non-critical dimensions.

## Third-Party Inspection Services

For onsite inspections in China, Rev A uses third-party inspection companies. The PM should coordinate scheduling at least 3-5 business days in advance.
