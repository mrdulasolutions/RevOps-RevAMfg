# reva-turbo-china-package

Package client specifications, drawings, and requirements into a standardized manufacturing package for Chinese manufacturing partners.

## What It Does

- Collects part specs, drawings, materials, tolerances, and delivery requirements from the PM
- Converts all dimensions to metric (mm) with imperial reference where applicable
- Applies IP protection measures (watermarking, spec splitting, customer identity redaction)
- Adds English/Chinese terminology glossary for key manufacturing terms
- Numbers all requirements (REQ-001, REQ-002, ...) for traceability
- Validates drawing format compliance
- Generates a complete manufacturing package document

## Usage

```
/reva-turbo-china-package
```

Or via the engine orchestrator when context matches "send to China", "manufacturing package", or "specs for partner".

## Flow

1. Data sensitivity gate (NDA, IP, authorization check)
2. Collect specifications from PM
3. Standardize format (metric units, numbered requirements)
4. Add translation notes and glossary
5. Apply IP protection measures
6. Verify drawing requirements
7. Build and review package (human-in-the-loop approval)
8. Suggest china-track for milestone tracking

## Files

| File | Purpose |
|------|---------|
| `SKILL.md` | Skill instructions and flow |
| `skill.yaml` | Skill metadata |
| `prompts/packaging-system.md` | System prompt for package generation |
| `prompts/packaging-user-template.md` | User input collection template |
| `references/spec-format-standard.md` | Standardized spec format rules |
| `references/translation-notes.md` | English/Chinese manufacturing terms |
| `references/ip-protection.md` | IP handling procedures |
| `references/drawing-requirements.md` | Drawing format requirements |
| `templates/Manufacturing Package.md` | Output template with placeholders |

## Output

`REVA-TURBO-MFG-PKG-{YYYY-MM-DD}-{PartName}.docx`
