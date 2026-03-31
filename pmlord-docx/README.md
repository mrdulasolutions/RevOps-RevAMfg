# pmlord-docx

Markdown to Word .docx converter skill for the PMLORD engine.

## What It Does

Converts any PMLORD markdown report into a professional Word .docx document:

1. Reads the markdown file
2. Parses headings, paragraphs, tables, lists, and horizontal rules
3. Generates a .docx with Rev A Manufacturing branding
4. Saves the .docx alongside the source markdown file

## Usage

```
/pmlord-docx
```

Or ask PMLORD to convert a report to Word format.

## Prerequisites

The `docx` npm package must be installed. Run:

```bash
cd /Volumes/X10\ Pro/Mac\ Mini/Rev\ A\ Mfg/PMLORD/pmlord-docx/scripts && npm install
```

## Files

| File | Purpose |
|------|---------|
| `SKILL.md` | Skill instructions and flow |
| `skill.yaml` | Skill manifest |
| `scripts/package.json` | npm package manifest (depends on "docx") |
| `scripts/report-to-docx.mjs` | Full converter implementation |

## How It Works

The converter (`report-to-docx.mjs`) performs the following:

1. Reads the input markdown file
2. Splits into lines and classifies each line (heading, table row, list item, horizontal rule, paragraph)
3. Builds a docx document using the `docx` npm package:
   - Rev A Manufacturing header with company name and PMLORD branding
   - Proper heading hierarchy (H1, H2, H3)
   - Tables with header row styling and borders
   - Bulleted and numbered lists
   - Section dividers from horizontal rules
4. Saves the .docx to the same directory as the input file

## Output

The output file uses the same filename as the input but with `.docx` extension:
- Input: `PMLORD-WeeklySummary-2026-03-27-RY.md`
- Output: `PMLORD-WeeklySummary-2026-03-27-RY.docx`
