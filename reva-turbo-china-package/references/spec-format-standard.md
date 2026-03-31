# Standardized Specification Format for China Manufacturing Partners

## Units

- **Primary unit system:** Metric (SI)
- **Length:** Millimeters (mm)
- **Weight:** Kilograms (kg) or grams (g)
- **Temperature:** Celsius (C)
- **Pressure:** MPa or bar
- **Surface roughness:** Ra in micrometers (um)

### Dual-Unit Display

When converting from imperial source documents, display both units:

```
25.40 mm (1.000 in)
```

Metric is always listed first. Imperial in parentheses for reference only.

### Common Conversions

| Imperial | Metric | Notes |
|----------|--------|-------|
| 1 inch | 25.4 mm | Exact |
| 1 thou (mil) | 0.0254 mm | 25.4 um |
| 1 lb | 0.4536 kg | |
| 1 oz | 28.35 g | |
| 1 psi | 0.006895 MPa | |
| 1 microinch Ra | 0.0254 um Ra | |

## Requirement Numbering

All requirements are numbered sequentially:

```
REQ-001: Material shall be Aluminum 6061-T6 per ASTM B209.
REQ-002: All machined surfaces shall have Ra 1.6 um or better.
REQ-003: [CRITICAL] Bore diameter shall be 25.00 +/- 0.01 mm.
```

### Numbering Rules

1. Start at REQ-001 for each package.
2. Number continuously — do not restart numbering per section.
3. Tag critical requirements with `[CRITICAL]`.
4. Tag requirements that need first-article verification with `[FAI]`.
5. Group related requirements but maintain sequential numbering.

## Sections (in order)

1. **Cover Sheet** — Part ID, revision, date, distribution, NDA reference
2. **Requirements Summary** — Numbered list of all REQ items
3. **Drawing Index** — List of all drawings with file names, formats, sheet counts
4. **Material Specification** — Material type, grade, standard, cert requirements
5. **Finish Specification** — Surface treatment, color, roughness targets
6. **Dimensional Tolerances** — General and critical tolerances, GD&T summary
7. **Special Instructions** — Assembly, packaging, inspection, certifications
8. **Terminology Glossary** — English/Chinese term pairs

## Drawing Callouts

Every requirement that references a dimension or feature must include a drawing callout:

```
REQ-003: [CRITICAL] Bore diameter shall be 25.00 +/- 0.01 mm.
         Reference: Drawing RA-12345, Sheet 1, Detail A.
```

## Material Designation Cross-Reference

| Common Name | ASTM / SAE | ISO | GB/T (China) |
|------------|------------|-----|--------------|
| Aluminum 6061-T6 | ASTM B209 / SAE AMS-QQ-A-250/11 | ISO 6361 AlMg1SiCu | GB/T 3880 6061-T6 |
| Aluminum 7075-T6 | ASTM B209 / SAE AMS-QQ-A-250/12 | ISO 6361 AlZn5.5MgCu | GB/T 3880 7075-T6 |
| 304 Stainless | ASTM A240 / SAE 30304 | ISO 15510 X5CrNi18-10 | GB/T 3280 0Cr18Ni9 |
| 316 Stainless | ASTM A240 / SAE 30316 | ISO 15510 X2CrNiMo17-12-2 | GB/T 3280 0Cr17Ni12Mo2 |
| ABS | ASTM D4673 | ISO 2580 | GB/T 12672 |
| Nylon 6/6 | ASTM D4066 | ISO 1874 | GB/T 16867 |
| Carbon Steel 1018 | ASTM A108 / SAE 1018 | ISO 683 C15E | GB/T 699 15 |
| Carbon Steel 1045 | ASTM A108 / SAE 1045 | ISO 683 C45E | GB/T 699 45 |
