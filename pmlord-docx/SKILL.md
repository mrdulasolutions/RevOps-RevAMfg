---
name: pmlord-docx
preamble-tier: 2
version: 1.0.0
description: |
  Convert PMLORD markdown reports to Word .docx format. Parses markdown
  into structured document elements (headings, paragraphs, tables, lists)
  and generates a branded .docx using the docx npm package with Rev A
  Manufacturing header and PMLORD branding.
compatibility: Claude Code, Claude desktop, Claude CoWork
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - AskUserQuestion
---

## Preamble (run first)

```bash
mkdir -p ~/.pmlord/analytics
echo '{"skill":"pmlord-docx","ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"}' >> ~/.pmlord/analytics/skill-usage.jsonl 2>/dev/null || true
```

## Purpose

Convert any PMLORD markdown report to a professional Word .docx document with Rev A Manufacturing branding. Uses the `docx` npm package to build the document programmatically from parsed markdown.

## Flow

### Step 1: Input Identification

Determine which markdown file to convert:

> What report do you want to convert to .docx?
> A) Specify a file path
> B) Convert the last generated report
> C) Search for a report by name

If the PM provides a file path, validate it exists.

### Step 2: Dependency Check

Ensure the docx npm package is installed:

```bash
cd "$(dirname "$0")/../pmlord-docx/scripts" && npm ls docx 2>/dev/null || npm install
```

### Step 3: Convert

Run the converter:

```bash
node "/Volumes/X10 Pro/Mac Mini/Rev A Mfg/PMLORD/pmlord-docx/scripts/report-to-docx.mjs" "{{INPUT_FILE}}"
```

The output .docx will be saved in the same directory as the input file, with the `.md` extension replaced by `.docx`.

### Step 4: Confirm

> Report converted successfully:
> Input: {{INPUT_FILE}}
> Output: {{OUTPUT_FILE}}
> Size: {{FILE_SIZE}}
>
> The .docx file is ready at: {{OUTPUT_FILE}}

### Step 5: Log

```bash
echo '{"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","action":"docx_convert","input":"{{INPUT_FILE}}","output":"{{OUTPUT_FILE}}","pm":"{{PM_NAME}}"}' >> ~/.pmlord/state/docx-log.jsonl 2>/dev/null || true
```

## Rules

1. **Preserve all content.** The .docx must contain all content from the markdown source. No data loss.
2. **Rev A branding.** Every document includes the Rev A Manufacturing header.
3. **Report naming.** Output follows the same naming convention but with `.docx` extension.
4. **Table formatting.** Markdown tables must render as proper Word tables with borders and headers.
5. **No external dependencies beyond docx.** The converter is self-contained.

## Template References

- `scripts/package.json` — npm package manifest
- `scripts/report-to-docx.mjs` — Full converter implementation
