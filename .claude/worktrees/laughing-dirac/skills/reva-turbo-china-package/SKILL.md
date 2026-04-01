---
name: reva-turbo-china-package
description: |
  Package client specs, drawings, and requirements into a standardized format
  for Chinese manufacturing partners. Handles metric conversion, translation
  considerations, IP protection, and drawing format requirements.
compatibility: Claude Code, Claude desktop, Claude CoWork
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Glob
  - Grep
---

## Preamble (run first)

```bash
mkdir -p ~/.reva-turbo/analytics
echo '{"skill":"reva-turbo-china-package","ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"}' >> ~/.reva-turbo/analytics/skill-usage.jsonl 2>/dev/null || true
```

## Purpose

Build a complete, standardized manufacturing package for Chinese manufacturing partners from client specifications. Ensure all specs use metric units, include translation-ready terminology, protect intellectual property, and meet drawing format requirements.

## Flow

### Step 1 — Data Sensitivity Gate

Before proceeding, confirm:

1. **NDA status:** Ask the PM — "Does this customer have an NDA on file with Rev A Mfg?"
2. **IP classification:** Ask — "Are any of these specs or drawings classified as proprietary or trade-secret?"
3. **Authorization:** Ask — "Are you authorized to share these specs with the manufacturing partner?"

> **HUMAN-IN-THE-LOOP:** Do not proceed until the PM confirms all three. If NDA is active, apply IP protection measures from `references/ip-protection.md`.

### Step 2 — Collect Specifications

Gather the following from the PM (use the template in `prompts/packaging-user-template.md`):

| Field | Required | Notes |
|-------|----------|-------|
| Part name / number | Yes | Internal Rev A part identifier |
| Material | Yes | Alloy, grade, resin type |
| Finish | Yes | Anodize, plate, powder coat, polish, etc. |
| Tolerances | Yes | Critical dims flagged separately |
| Quantity | Yes | MOQ and order qty |
| Delivery date | Yes | Target date at Rev A dock |
| Drawing files | Yes | PDF, STEP, IGES, DWG |
| Special instructions | No | Notes for manufacturer |

If any required field is missing, ask the PM before continuing.

### Step 3 — Standardize Format

Apply the format standard from `references/spec-format-standard.md`:

1. **Convert all dimensions to metric (mm).** If source is imperial, show both: `25.4 mm (1.000 in)`.
2. **Number all requirements** sequentially: REQ-001, REQ-002, etc.
3. **Flag critical tolerances** with a `[CRITICAL]` tag and highlight.
4. **Add drawing callouts** — reference specific drawing views/details for each requirement.
5. **Material specification** — use international standard designations (e.g., ASTM, ISO, GB/T).
6. **Surface finish** — specify Ra values in micrometers where applicable.

### Step 4 — Translation Notes

Reference `references/translation-notes.md` and:

1. Include key manufacturing terms in both English and Chinese (Simplified).
2. Add a terminology glossary section to the package.
3. Flag any terms that are ambiguous or have multiple translations.
4. Use clear, simple English throughout — avoid idioms or colloquialisms.

### Step 5 — IP Protection

Reference `references/ip-protection.md` and apply:

1. **Split specifications** — separate geometry from material/finish if IP sensitivity is high.
2. **Watermark drawings** — add "CONFIDENTIAL — Rev A Manufacturing" watermark note.
3. **NDA reminder** — include NDA reference number and date in package header.
4. **Redact customer identity** — use Rev A part numbers only; do not include end-customer name unless PM authorizes.
5. **Version control** — stamp each document with version, date, and distribution list.

### Step 6 — Drawing Requirements

Reference `references/drawing-requirements.md` and verify:

1. Drawings are in acceptable format (PDF for reference, STEP/IGES for 3D).
2. Title block includes Rev A part number, revision, date, and material.
3. All dimensions are in metric with appropriate GD&T callouts.
4. Section views and detail views are adequate for manufacturing.
5. Surface finish symbols are present on all machined surfaces.

### Step 7 — Build Package

Generate the manufacturing package using `templates/Manufacturing Package.md`:

1. Fill all `{{PLACEHOLDER}}` variables with collected data.
2. Organize sections: Cover Sheet, Requirements List, Drawing Index, Material Spec, Finish Spec, Tolerances, Special Instructions, Glossary.
3. Name the file: `REVA-TURBO-MFG-PKG-{{DATE}}-{{PART_NAME}}.md`

> **HUMAN-IN-THE-LOOP:** Present the completed package to the PM for review before finalizing. Ask: "Please review this manufacturing package. Approve to send, or note any changes needed."

### Step 8 — Suggest Next Skill

After the package is approved, suggest:

> "Manufacturing package is ready. Next step: `/reva-turbo:reva-turbo-china-track` to set up milestone tracking for this order. Want me to run it?"

## Report Naming

`REVA-TURBO-MFG-PKG-{YYYY-MM-DD}-{PartName}.docx`

## References

- `references/spec-format-standard.md` — Standardized spec format
- `references/translation-notes.md` — English/Chinese manufacturing terms
- `references/ip-protection.md` — IP handling procedures
- `references/drawing-requirements.md` — Drawing format requirements for China partners
