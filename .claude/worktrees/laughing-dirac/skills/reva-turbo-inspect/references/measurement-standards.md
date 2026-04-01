# Measurement Standards and Tools

## Measurement Tool Selection

Select the measurement tool based on the tolerance of the dimension being inspected. The tool resolution should be at least 10x finer than the tolerance (10:1 rule).

| Tolerance Range | Recommended Tool | Resolution |
|----------------|-----------------|------------|
| +/- 1.0 mm or larger | Steel rule, tape measure | 0.5 mm |
| +/- 0.5 mm | Digital calipers | 0.01 mm |
| +/- 0.1 mm | Digital calipers | 0.01 mm |
| +/- 0.05 mm | Micrometer | 0.001 mm |
| +/- 0.025 mm | Micrometer or CMM | 0.001 mm |
| +/- 0.01 mm or tighter | CMM or precision gauge | 0.001 mm |

## Common Measurement Tools

### Calipers (Digital)

- **Range:** 0-150 mm, 0-200 mm, 0-300 mm
- **Resolution:** 0.01 mm
- **Accuracy:** +/- 0.02 mm (typical)
- **Use for:** OD, ID, depth, step measurements
- **Calibration:** Annual, with NIST-traceable standards

### Micrometers (Outside)

- **Range:** 0-25 mm, 25-50 mm, 50-75 mm, etc.
- **Resolution:** 0.001 mm
- **Accuracy:** +/- 0.002 mm (typical)
- **Use for:** Precision OD measurements, thickness
- **Calibration:** Annual, with gauge blocks

### Micrometers (Inside)

- **Range:** Various
- **Resolution:** 0.001 mm
- **Use for:** Precision bore/ID measurements
- **Calibration:** Annual, with ring gauges

### Height Gauge

- **Resolution:** 0.01 mm
- **Use for:** Height, step, and perpendicularity checks on a surface plate
- **Calibration:** Annual

### Coordinate Measuring Machine (CMM)

- **Resolution:** 0.001 mm
- **Accuracy:** +/- 0.003 mm (typical)
- **Use for:** Complex geometry, GD&T, true position, profile
- **Calibration:** Annual, with certified artifacts

### Thread Gauges (Go / No-Go)

- **Use for:** Thread verification (M threads, UNC, UNF)
- **Go gauge must pass:** Thread is not too tight
- **No-Go gauge must not pass:** Thread is not too loose
- **Calibration:** Annual

### Pin Gauges

- **Accuracy:** Class ZZ (+0.000 / -0.001 mm)
- **Use for:** Hole diameter verification
- **Calibration:** Annual, with micrometer verification

### Surface Roughness Tester (Profilometer)

- **Use for:** Ra, Rz surface roughness measurement
- **Resolution:** 0.01 um
- **Calibration:** Annual, with roughness standard

### Hardness Tester

- **Rockwell (HRA, HRB, HRC):** Metals
- **Shore A/D:** Plastics, rubber
- **Calibration:** Annual, with test blocks

## Measurement Conditions

| Condition | Requirement |
|-----------|-------------|
| Temperature | 20 +/- 2 C (68 +/- 3.6 F) |
| Part condition | Clean, dry, free of burrs |
| Tool condition | Clean, calibrated, zero-checked |
| Technique | Consistent force, perpendicular contact |
| Readings | Take 3 readings per feature, report average |

## Calibration Requirements

All measurement tools used for inspection must be:

1. Calibrated to NIST-traceable standards.
2. Within their calibration interval (typically 12 months).
3. Labeled with calibration date and due date.
4. Stored properly to prevent damage.
5. Removed from service immediately if damaged or suspect.

## Measurement Uncertainty

When reporting measurements near tolerance boundaries, consider measurement uncertainty:

| Tool | Typical Uncertainty (k=2) |
|------|--------------------------|
| Digital calipers | +/- 0.03 mm |
| Micrometer | +/- 0.004 mm |
| CMM | +/- 0.005 mm |
| Height gauge | +/- 0.02 mm |

If a measurement falls within the uncertainty band of a tolerance limit, mark the dimension as BORDERLINE and escalate to Senior PM for disposition.
