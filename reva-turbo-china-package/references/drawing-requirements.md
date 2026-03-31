# Drawing Format Requirements for China Manufacturing Partners

## Accepted File Formats

| Format | Use | Required? |
|--------|-----|-----------|
| **PDF** | Reference viewing, printing | Yes — always include |
| **STEP (.stp / .step)** | 3D model for CAM programming | Yes — for machined and molded parts |
| **IGES (.igs / .iges)** | 3D model (legacy compatibility) | Optional — if partner requests |
| **DWG / DXF** | 2D CAD (AutoCAD native) | Optional — if 2D-only part |
| **SolidWorks (.sldprt / .sldasm)** | Native CAD | Do NOT send — convert to STEP |
| **Parasolid (.x_t)** | 3D model (alternative to STEP) | Optional — if partner requests |

## Title Block Requirements

Every drawing must include a title block with:

| Field | Example |
|-------|---------|
| Part number | RA-12345 |
| Part name | Motor Mount Bracket |
| Revision | Rev C |
| Date | 2026-03-30 |
| Material | Aluminum 6061-T6 |
| Finish | Anodize Type II, Black |
| Scale | 2:1 |
| Units | mm |
| Drawn by | Rev A Manufacturing |
| Sheet | 1 of 3 |
| General tolerance | ISO 2768-mK |

## Dimensioning Standards

1. **All dimensions in millimeters (mm).** No inches on partner-facing drawings.
2. **Decimal places:** Match the tolerance precision.
   - General dims: 1 decimal (25.4)
   - Precision dims: 2 decimals (25.40)
   - Critical dims: 3 decimals (25.400)
3. **Tolerance notation:** Bilateral preferred: `25.40 +0.02 / -0.01`
4. **GD&T per ISO 1101** (preferred) or ASME Y14.5. Specify which standard in the title block.

## View Requirements

| Part Type | Minimum Views Required |
|-----------|----------------------|
| Machined part (prismatic) | Front, Top, Right side, Isometric |
| Machined part (rotational) | Section view through axis, End view, Isometric |
| Sheet metal part | Flat pattern + Formed views (min 2) |
| Injection molded part | All 6 orthographic + Isometric + Gate location |
| Assembly | Exploded view + BOM + Assembly sequence |

## Section and Detail Views

- Use section views to show internal features (bores, pockets, channels).
- Use detail views for features smaller than 5 mm.
- Label all section views (A-A, B-B, etc.) and detail views (Detail A, Detail B, etc.).
- Reference these labels in the requirements list.

## Surface Finish Symbols

- Apply surface finish symbols (per ISO 1302) to all machined surfaces.
- Specify Ra value in micrometers.
- Common values:

| Application | Ra (um) | Symbol |
|------------|---------|--------|
| As-machined (rough) | 3.2 | Standard machining mark |
| General machined | 1.6 | Standard machining mark |
| Precision surface | 0.8 | Fine machining mark |
| Polished / sealing | 0.4 | Fine machining mark |
| Mirror finish | 0.1 | Lapping/polishing mark |

## Thread Callouts

- Use metric thread designations: M8x1.25, M10x1.5
- Specify thread depth and class/fit
- For tapped holes, show drill depth and tap depth separately
- Include thread direction if left-hand (LH)

## Notes Block

Include these standard notes on every drawing:

1. All dimensions in millimeters unless otherwise stated.
2. General tolerance per ISO 2768-mK unless otherwise specified.
3. Remove all burrs and sharp edges. Break edges 0.2-0.5 mm.
4. Surface finish Ra 3.2 um max unless otherwise specified.
5. Material certification required.
6. Part must be free of cracks, porosity, and surface defects.

## Common Issues to Avoid

| Issue | Impact | Prevention |
|-------|--------|------------|
| Missing dimensions | Partner will assume or guess | Fully dimension all features |
| Imperial units on drawing | Conversion errors | Convert all to metric before sending |
| Missing GD&T datums | Inconsistent measurement | Define datum features clearly |
| Low-resolution PDF | Unreadable details | Export at 300 DPI minimum |
| Missing thread callouts | Wrong thread manufactured | Dimension all threads explicitly |
| No flat pattern for sheet metal | Partner creates their own (may differ) | Always include flat pattern with bend lines |
