# Standard Inspection Procedures

## Inspection Sequence

Always follow this sequence for incoming inspections:

1. **Receiving check** — Verify quantity, packing list, packaging condition
2. **Visual inspection** — Workmanship, surface, defects, finish, labeling
3. **Dimensional inspection** — Critical dims first, then general dims
4. **Material verification** — Certificates, hardness, composition
5. **Functional check** — Assembly, fit, thread, operation (if applicable)
6. **Documentation** — Record all findings, assign disposition

## 1. Receiving Check

### Procedure

1. Compare packing list against PO (part number, quantity, revision).
2. Count or weigh parts to verify quantity.
3. Inspect packaging for damage (dents, moisture, crushing).
4. Note any discrepancies immediately.
5. If packaging is damaged, photograph before opening and note condition.

### Accept/Reject Criteria

| Condition | Action |
|-----------|--------|
| Quantity matches PO | Continue inspection |
| Quantity short (< ordered) | Note shortage, inspect what was received, notify PM |
| Quantity over (> ordered + 5%) | Note overage, inspect ordered quantity, hold extras |
| Packaging damaged, parts appear OK | Note in report, continue inspection with extra vigilance |
| Packaging damaged, parts may be affected | HOLD pending full inspection |
| No packing list | Note as finding, verify against PO directly |

## 2. Visual Inspection

### Procedure

1. Inspect under adequate lighting (daylight or equivalent, min 500 lux).
2. Use magnification (10x loupe) for surface finish checks.
3. Compare part shape and features against the drawing.
4. Check all surfaces for defects: cracks, scratches, dents, burrs, porosity.
5. Verify finish (anodize color, plating coverage, powder coat adhesion).
6. Check for contamination (chips, oil, foreign material).
7. Verify any markings, engravings, or labels.

### Common Visual Defects

| Defect | Description | Severity |
|--------|-------------|----------|
| Scratch | Linear surface mark | Minor (cosmetic) or Major (functional surface) |
| Dent | Localized deformation | Major |
| Burr | Raised edge from machining | Minor (if removable) or Major (if on mating surface) |
| Porosity | Small holes in casting/molding | Major |
| Crack | Fracture in material | Critical |
| Discoloration | Color variation in finish | Minor (cosmetic) |
| Orange peel | Textured finish defect | Minor to Major depending on spec |
| Flash | Excess material at parting line (molded parts) | Minor (if removable) |
| Sink mark | Depression in molded part | Major if exceeds spec |
| Weld line | Visible line in molded part | Minor to Major depending on location |

## 3. Dimensional Inspection

### Procedure

1. Allow parts to reach room temperature (20 +/- 2 C) before measuring.
2. Clean parts and measurement surfaces before measuring.
3. Measure critical dimensions first (tagged [CRITICAL] in spec).
4. Use the appropriate measurement tool for the tolerance range.
5. Record actual measured values (not just pass/fail).
6. For GD&T, use appropriate gauging or CMM.

### Sample Size Selection

| Order Qty | Critical Dims | General Dims |
|-----------|--------------|--------------|
| 1-10 | 100% | 100% |
| 11-50 | 100% | 50% (min 5 pcs) |
| 51-200 | 100% of sample per AQL | AQL Level II, AQL 2.5 |
| 201-1000 | AQL Level II, AQL 1.0 | AQL Level II, AQL 2.5 |
| 1000+ | AQL Level II, AQL 1.0 | AQL Level II, AQL 4.0 |

### Measurement Recording

Record measurements to one decimal place beyond the tolerance. Example: if tolerance is +/- 0.01 mm, record to 0.001 mm.

## 4. Material Verification

### Procedure

1. Check for Certificate of Conformance (CoC) in the shipment.
2. Verify CoC lists correct material, grade, and heat/lot number.
3. If hardness testing is required, perform per the applicable standard.
4. If material composition verification is needed, use XRF or send sample to lab.
5. Compare material cert data against the spec requirements.

### Hardness Testing Reference

| Material | Expected Hardness | Test Method |
|----------|------------------|-------------|
| Al 6061-T6 | 95-105 HRB | Rockwell B |
| Al 7075-T6 | 85-90 HRB | Rockwell B |
| 304 SS | 70-90 HRB | Rockwell B |
| 1018 Steel | 70-80 HRB | Rockwell B |
| 1045 Steel (hardened) | 50-55 HRC | Rockwell C |

## 5. Functional Check

### Procedure

1. Attempt assembly with mating parts (if available).
2. Check thread engagement with go/no-go gauges.
3. Verify fit and clearance per drawing.
4. Perform any specified functional tests (pressure, flow, electrical, etc.).

## 6. Documentation

- Record every check result in the inspection report.
- Photograph any defects with a scale reference.
- Reference specific drawing views and dimension numbers.
- Note measurement tools used (with calibration status).
- Sign and date the inspection report.
