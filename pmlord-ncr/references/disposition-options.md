# Disposition Options for Non-Conforming Parts

## Overview

When parts fail to meet specifications, one of four dispositions must be assigned. Each disposition has different requirements, authority levels, and cost implications.

---

## 1. Rework

### Definition

Correct the non-conforming parts through additional processing to bring them within specification.

### When to Use

- Defect is correctable (e.g., dimension can be re-machined, finish can be re-applied).
- Rework cost is less than replacement cost.
- Rework will not compromise material properties or structural integrity.
- Schedule allows time for rework.

### Requirements

| Field | Value |
|-------|-------|
| Approval authority | PM |
| Customer notification | Not required (unless delivery date affected) |
| Documentation | Rework plan, post-rework inspection results |
| Re-inspection | Required — all reworked parts must pass full inspection |

### Rework at Partner vs. Rev A

| Location | When |
|----------|------|
| Rework at partner (China) | Parts have not shipped yet, or partner has the required equipment |
| Rework at Rev A | Parts are already at Rev A, rework is simple (deburring, re-finishing) |
| Rework at third party | Neither partner nor Rev A has capability |

### Cost Responsibility

- Rework cost is the manufacturing partner's responsibility (standard terms).
- Document rework cost for partner scorecard.

---

## 2. Scrap

### Definition

Parts cannot be salvaged. Destroy or recycle the non-conforming parts.

### When to Use

- Defect is not correctable (e.g., wrong material, undersized, cracked).
- Rework cost exceeds replacement cost.
- Rework would compromise part integrity.
- Material is non-conforming and cannot be verified.

### Requirements

| Field | Value |
|-------|-------|
| Approval authority | PM + Senior PM |
| Customer notification | Not required (unless delivery date affected) |
| Documentation | Scrap justification, qty scrapped, replacement order plan |
| Material disposal | Per material type (recycle metals, dispose plastics per regulations) |

### Cost Responsibility

- Scrap cost (part value + disposal) is the manufacturing partner's responsibility.
- Replacement order cost: negotiate with partner (full replacement at partner's cost is standard).
- Document total cost for partner scorecard.

---

## 3. Use-As-Is (with Deviation)

### Definition

Accept the non-conforming parts without rework. The deviation from specification is documented and accepted.

### When to Use

- Deviation is minor and does not affect form, fit, or function.
- Parts are functional despite being out of specification.
- Cost/schedule impact of rejection is greater than the risk of the deviation.
- Engineering review confirms the deviation is acceptable.

### Requirements

| Field | Value |
|-------|-------|
| Approval authority | Senior PM (Ray Yeh or Harley Scott) |
| Customer approval | **Required** if deviation affects form, fit, or function |
| Engineering review | Required — document why deviation is acceptable |
| Documentation | Deviation notice, engineering justification, customer approval (if needed) |

### Deviation Notice Must Include

1. Part number and revision
2. Specification requirement
3. Actual condition
4. Engineering justification for acceptance
5. Any limitations or conditions on use
6. Approvals (Senior PM, customer if applicable)

### Important

- NEVER use this disposition without Senior PM review.
- NEVER ship use-as-is parts to a customer without documented approval.
- Track all deviations — repeated deviations for the same issue indicate a specification or process problem.

---

## 4. RTV (Return to Vendor)

### Definition

Return the non-conforming parts to the manufacturing partner for replacement or credit.

### When to Use

- Parts are clearly defective and not economically reworkable at Rev A.
- Partner agrees to accept return.
- Schedule allows for return shipping and replacement production.
- Multiple defects or systemic quality issue.

### Requirements

| Field | Value |
|-------|-------|
| Approval authority | PM |
| Partner notification | Required — send NCR details, photos, and RTV request |
| Documentation | RTV shipping record, partner acknowledgment, replacement timeline |
| Shipping | Return at partner's expense (standard terms) |

### RTV Process

1. Notify partner of NCR and intention to return.
2. Partner acknowledges and provides return shipping instructions.
3. Pack parts securely with NCR reference on all shipping labels.
4. Ship via trackable method.
5. Confirm partner received the return.
6. Partner provides replacement timeline or credit memo.
7. Track replacement order through `/pmlord-china-track`.

### Cost Responsibility

- Return shipping: partner's responsibility.
- Replacement parts: partner's responsibility.
- Expedite shipping for replacements: negotiate based on impact.

---

## Disposition Decision Matrix

| Factor | Rework | Scrap | Use-As-Is | RTV |
|--------|--------|-------|-----------|-----|
| Defect correctable? | Yes | No | N/A | N/A |
| Rework cost < replacement? | Yes | No | N/A | N/A |
| Affects function? | After rework: No | N/A | No | Yes |
| Schedule allows? | Yes | Order replacement | N/A | Yes |
| Parts at Rev A? | Yes | Yes | Yes | Yes |
| Parts still at partner? | Return & rework | Scrap at partner | Unlikely | N/A |

## Disposition Authority Summary

| Disposition | PM | Senior PM | Customer | Donovan Weber |
|------------|-----|-----------|----------|---------------|
| Rework | Approve | Inform | If delivery affected | — |
| Scrap | Recommend | Approve | If delivery affected | If cost > $5,000 |
| Use-As-Is | Recommend | Approve | Approve (if F/F/F) | If safety-related |
| RTV | Approve | Inform | If delivery affected | — |
