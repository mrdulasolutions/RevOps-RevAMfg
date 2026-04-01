# HTS Classification Tree
<!-- STUB: This reference file needs to be populated. Created by audit remediation. -->

This document provides a structured decision tree for HTS (Harmonized Tariff Schedule) classification of goods commonly imported by Rev A Manufacturing from China manufacturing partners.

## How to Use

Navigate the tree by answering each decision question. When you reach a leaf node, that is the recommended HTS chapter/heading to research. Always confirm the final 10-digit HTS code against the official USITC tariff schedule at usitc.gov.

---

## Top-Level Classification Decision

**What is the primary composition or function of the item?**

1. **Metals and metal products** → Chapter 72–83
2. **Plastics and rubber articles** → Chapter 39–40
3. **Electrical/electronic components** → Chapter 84–85
4. **Optical, measuring, or precision instruments** → Chapter 90
5. **Machinery and mechanical appliances** → Chapter 84
6. **Chemical products** → Chapter 28–38
7. **Other manufactured goods** → Chapter 94–96

---

## Branch 1: Metals and Metal Products (Chapters 72–83)

**Is the item made primarily of:**

- Iron or steel (unalloyed) → Chapter 72 (Iron and steel)
- Steel alloy (stainless, tool, HSS) → Chapter 72, headings 72.19–72.29
- Aluminum or aluminum alloy → Chapter 76
- Copper or copper alloy → Chapter 74
- Titanium → Chapter 81
- Other base metals → Chapters 74–81

**Common Rev A classifications:**
| Part Type | Likely HTS Heading | Notes |
|-----------|-------------------|-------|
| CNC machined aluminum parts | 7616.99 | Articles of aluminum, NEC |
| CNC machined steel parts | 7326.90 | Other articles of iron or steel |
| Stainless steel machined parts | 7326.90 | Verify alloy composition |
| Sheet metal brackets (steel) | 7326.20 | Wire/rod fabricated articles |
| Cast aluminum housings | 7616.99 | Die-cast aluminum articles |
| Injection-molded plastic parts | 3926.90 | Other articles of plastics |

---

## Branch 2: Plastics (Chapter 39)

**Is the item:**
- A molded plastic part (functional) → 3926.90 (Other articles of plastics)
- A plastic tube or pipe → 3917
- A plastic film or sheet → 3920
- A plastic container → 3923
- A plastic fastener → 3926.10

---

## Branch 3: Electrical/Electronic (Chapters 84–85)

**Is the item:**
- A motor or generator → 8501
- A transformer or inductor → 8504
- A printed circuit board assembly → 8537 or 8543
- A connector or terminal → 8536
- A cable or wire harness → 8544
- A switch → 8536.50
- A sensor → 9026 or 8543

---

## Common Rev A Part Types — Quick Reference

| Category | HTS Code (First 6 digits) | Notes |
|----------|--------------------------|-------|
| Machined aluminum (general) | 7616.99 | Verify: anodized may still apply |
| Machined steel (general) | 7326.90 | Check for Section 301 tariff |
| Machined stainless | 7326.90 | 316 vs 304 does not change HTS |
| Injection-molded plastic | 3926.90 | |
| Die-cast zinc | 7907.00 | |
| Sheet metal fabrication | 7326.90 | |
| Springs (steel) | 7320 | Compression, tension, torsion |
| Fasteners (steel) | 7318 | Bolts, screws, nuts |
| Fasteners (aluminum) | 7616.10 | |

---

## Notes

- Always verify the full 10-digit US HTS code before filing. The first 6 digits are internationally harmonized; digits 7–10 are US-specific.
- Section 301 List 3 applies to most goods from China classified in Chapters 72–84. See `references/section-301-lists.md` for duty rates.
- Anti-dumping/countervailing duty orders may apply independently of HTS. See `references/adcvd-orders.md`.
- When in doubt, engage a licensed customs broker for binding ruling.
