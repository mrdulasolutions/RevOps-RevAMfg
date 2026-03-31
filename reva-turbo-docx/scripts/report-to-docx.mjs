#!/usr/bin/env node

/**
 * REVA-TURBO Report-to-DOCX Converter
 *
 * Converts REVA-TURBO markdown reports to Word .docx format with
 * Rev A Manufacturing branding.
 *
 * Usage: node report-to-docx.mjs <input-markdown-file>
 * Output: Same directory as input, with .docx extension
 */

import { readFileSync, writeFileSync } from "fs";
import { basename, dirname, extname, join } from "path";
import {
  Document,
  Packer,
  Paragraph,
  TextRun,
  HeadingLevel,
  Table,
  TableRow,
  TableCell,
  WidthType,
  BorderStyle,
  AlignmentType,
  Header,
  Footer,
  PageNumber,
  NumberFormat,
  ShadingType,
  convertInchesToTwip,
  LevelFormat,
} from "docx";

// --- Configuration ---

const BRAND = {
  companyName: "Rev A Manufacturing",
  website: "revamfg.com",
  engine: "REVA-TURBO Engine v1.0.0",
  primaryColor: "1B3A5C",
  secondaryColor: "4A90D9",
  accentColor: "E8F0FE",
  headerGray: "F2F2F2",
  textColor: "333333",
  lightGray: "D9D9D9",
};

// --- Markdown Parsing ---

function classifyLine(line) {
  const trimmed = line.trim();
  if (trimmed === "") return { type: "blank" };
  if (/^#{1}\s/.test(trimmed))
    return { type: "h1", text: trimmed.replace(/^#\s+/, "") };
  if (/^#{2}\s/.test(trimmed))
    return { type: "h2", text: trimmed.replace(/^#{2}\s+/, "") };
  if (/^#{3}\s/.test(trimmed))
    return { type: "h3", text: trimmed.replace(/^#{3}\s+/, "") };
  if (/^#{4}\s/.test(trimmed))
    return { type: "h4", text: trimmed.replace(/^#{4}\s+/, "") };
  if (/^#{5,6}\s/.test(trimmed))
    return { type: "h5", text: trimmed.replace(/^#{5,6}\s+/, "") };
  if (/^---+$/.test(trimmed) || /^\*\*\*+$/.test(trimmed))
    return { type: "hr" };
  if (/^\|.*\|$/.test(trimmed)) {
    if (/^\|[\s\-:|]+\|$/.test(trimmed)) return { type: "table_separator" };
    return { type: "table_row", text: trimmed };
  }
  if (/^[-*+]\s\[[ x]\]\s/.test(trimmed)) {
    const checked = /^[-*+]\s\[x\]/i.test(trimmed);
    const text = trimmed.replace(/^[-*+]\s\[[ x]\]\s+/i, "");
    return { type: "checklist", text, checked };
  }
  if (/^[-*+]\s/.test(trimmed))
    return { type: "bullet", text: trimmed.replace(/^[-*+]\s+/, "") };
  if (/^\d+[.)]\s/.test(trimmed))
    return {
      type: "numbered",
      text: trimmed.replace(/^\d+[.)]\s+/, ""),
      num: parseInt(trimmed),
    };
  if (/^>\s/.test(trimmed))
    return { type: "blockquote", text: trimmed.replace(/^>\s*/, "") };
  if (/^```/.test(trimmed)) return { type: "code_fence", text: trimmed };
  return { type: "paragraph", text: trimmed };
}

function parseInlineFormatting(text) {
  const runs = [];
  const regex = /(\*\*\*(.+?)\*\*\*|\*\*(.+?)\*\*|\*(.+?)\*|`(.+?)`|([^*`]+))/g;
  let match;
  while ((match = regex.exec(text)) !== null) {
    if (match[2]) {
      runs.push(
        new TextRun({ text: match[2], bold: true, italics: true, size: 20, font: "Calibri" })
      );
    } else if (match[3]) {
      runs.push(
        new TextRun({ text: match[3], bold: true, size: 20, font: "Calibri" })
      );
    } else if (match[4]) {
      runs.push(
        new TextRun({ text: match[4], italics: true, size: 20, font: "Calibri" })
      );
    } else if (match[5]) {
      runs.push(
        new TextRun({
          text: match[5],
          font: "Consolas",
          size: 18,
          shading: { type: ShadingType.SOLID, color: BRAND.accentColor },
        })
      );
    } else if (match[6]) {
      runs.push(new TextRun({ text: match[6], size: 20, font: "Calibri" }));
    }
  }
  if (runs.length === 0) {
    runs.push(new TextRun({ text, size: 20, font: "Calibri" }));
  }
  return runs;
}

function parseTableRow(line) {
  return line
    .split("|")
    .slice(1, -1)
    .map((cell) => cell.trim());
}

// --- Document Building ---

function buildTableBorders() {
  const border = {
    style: BorderStyle.SINGLE,
    size: 1,
    color: BRAND.lightGray,
  };
  return {
    top: border,
    bottom: border,
    left: border,
    right: border,
    insideHorizontal: border,
    insideVertical: border,
  };
}

function buildDocxTable(headerCells, dataRows) {
  const columnCount = headerCells.length;
  const columnWidth = Math.floor(9000 / columnCount);

  const headerRow = new TableRow({
    tableHeader: true,
    children: headerCells.map(
      (cell) =>
        new TableCell({
          width: { size: columnWidth, type: WidthType.DXA },
          shading: {
            type: ShadingType.SOLID,
            color: BRAND.primaryColor,
          },
          children: [
            new Paragraph({
              children: [
                new TextRun({
                  text: cell,
                  bold: true,
                  size: 18,
                  font: "Calibri",
                  color: "FFFFFF",
                }),
              ],
              spacing: { before: 40, after: 40 },
            }),
          ],
        })
    ),
  });

  const rows = dataRows.map(
    (row, rowIndex) =>
      new TableRow({
        children: row.map(
          (cell) =>
            new TableCell({
              width: { size: columnWidth, type: WidthType.DXA },
              shading:
                rowIndex % 2 === 1
                  ? { type: ShadingType.SOLID, color: BRAND.accentColor }
                  : undefined,
              children: [
                new Paragraph({
                  children: parseInlineFormatting(cell),
                  spacing: { before: 30, after: 30 },
                }),
              ],
            })
        ),
      })
  );

  return new Table({
    rows: [headerRow, ...rows],
    width: { size: 9000, type: WidthType.DXA },
    borders: buildTableBorders(),
  });
}

function createHeader() {
  return new Header({
    children: [
      new Paragraph({
        children: [
          new TextRun({
            text: BRAND.companyName,
            bold: true,
            size: 20,
            font: "Calibri",
            color: BRAND.primaryColor,
          }),
          new TextRun({
            text: "  |  ",
            size: 20,
            font: "Calibri",
            color: BRAND.lightGray,
          }),
          new TextRun({
            text: BRAND.website,
            size: 18,
            font: "Calibri",
            color: BRAND.secondaryColor,
          }),
          new TextRun({
            text: "  |  ",
            size: 20,
            font: "Calibri",
            color: BRAND.lightGray,
          }),
          new TextRun({
            text: BRAND.engine,
            size: 18,
            font: "Calibri",
            color: "999999",
          }),
        ],
        alignment: AlignmentType.CENTER,
        border: {
          bottom: {
            style: BorderStyle.SINGLE,
            size: 2,
            color: BRAND.primaryColor,
          },
        },
        spacing: { after: 200 },
      }),
    ],
  });
}

function createFooter() {
  return new Footer({
    children: [
      new Paragraph({
        children: [
          new TextRun({
            text: "Generated by " + BRAND.engine + " for " + BRAND.companyName,
            size: 16,
            font: "Calibri",
            color: "999999",
          }),
          new TextRun({
            text: "  |  Page ",
            size: 16,
            font: "Calibri",
            color: "999999",
          }),
          new TextRun({
            children: [PageNumber.CURRENT],
            size: 16,
            font: "Calibri",
            color: "999999",
          }),
          new TextRun({
            text: " of ",
            size: 16,
            font: "Calibri",
            color: "999999",
          }),
          new TextRun({
            children: [PageNumber.TOTAL_PAGES],
            size: 16,
            font: "Calibri",
            color: "999999",
          }),
        ],
        alignment: AlignmentType.CENTER,
        border: {
          top: {
            style: BorderStyle.SINGLE,
            size: 1,
            color: BRAND.lightGray,
          },
        },
        spacing: { before: 200 },
      }),
    ],
  });
}

// --- Main Conversion ---

function convertMarkdownToDocx(markdownContent) {
  const lines = markdownContent.split("\n");
  const children = [];
  let inCodeBlock = false;
  let codeLines = [];
  let tableHeader = null;
  let tableRows = [];
  let inTable = false;

  function flushTable() {
    if (tableHeader && tableRows.length > 0) {
      children.push(buildDocxTable(tableHeader, tableRows));
      children.push(new Paragraph({ spacing: { after: 120 } }));
    } else if (tableHeader) {
      children.push(buildDocxTable(tableHeader, []));
      children.push(new Paragraph({ spacing: { after: 120 } }));
    }
    tableHeader = null;
    tableRows = [];
    inTable = false;
  }

  function flushCode() {
    if (codeLines.length > 0) {
      children.push(
        new Paragraph({
          children: [
            new TextRun({
              text: codeLines.join("\n"),
              font: "Consolas",
              size: 16,
            }),
          ],
          shading: {
            type: ShadingType.SOLID,
            color: BRAND.headerGray,
          },
          spacing: { before: 100, after: 100 },
        })
      );
      codeLines = [];
    }
    inCodeBlock = false;
  }

  for (let i = 0; i < lines.length; i++) {
    const classified = classifyLine(lines[i]);

    // Handle code fences
    if (classified.type === "code_fence") {
      if (inCodeBlock) {
        flushCode();
      } else {
        if (inTable) flushTable();
        inCodeBlock = true;
      }
      continue;
    }

    if (inCodeBlock) {
      codeLines.push(lines[i]);
      continue;
    }

    // Handle table accumulation
    if (classified.type === "table_row") {
      if (!inTable) {
        inTable = true;
        tableHeader = parseTableRow(classified.text);
      } else {
        tableRows.push(parseTableRow(classified.text));
      }
      continue;
    }

    if (classified.type === "table_separator") {
      continue;
    }

    // If we were in a table and hit a non-table line, flush
    if (inTable) {
      flushTable();
    }

    // Handle each line type
    switch (classified.type) {
      case "blank":
        children.push(new Paragraph({ spacing: { after: 60 } }));
        break;

      case "h1":
        children.push(
          new Paragraph({
            children: [
              new TextRun({
                text: classified.text,
                bold: true,
                size: 36,
                font: "Calibri",
                color: BRAND.primaryColor,
              }),
            ],
            heading: HeadingLevel.HEADING_1,
            spacing: { before: 240, after: 120 },
            border: {
              bottom: {
                style: BorderStyle.SINGLE,
                size: 2,
                color: BRAND.primaryColor,
              },
            },
          })
        );
        break;

      case "h2":
        children.push(
          new Paragraph({
            children: [
              new TextRun({
                text: classified.text,
                bold: true,
                size: 28,
                font: "Calibri",
                color: BRAND.primaryColor,
              }),
            ],
            heading: HeadingLevel.HEADING_2,
            spacing: { before: 200, after: 100 },
          })
        );
        break;

      case "h3":
        children.push(
          new Paragraph({
            children: [
              new TextRun({
                text: classified.text,
                bold: true,
                size: 24,
                font: "Calibri",
                color: BRAND.secondaryColor,
              }),
            ],
            heading: HeadingLevel.HEADING_3,
            spacing: { before: 160, after: 80 },
          })
        );
        break;

      case "h4":
        children.push(
          new Paragraph({
            children: [
              new TextRun({
                text: classified.text,
                bold: true,
                size: 22,
                font: "Calibri",
                color: BRAND.textColor,
              }),
            ],
            heading: HeadingLevel.HEADING_4,
            spacing: { before: 120, after: 60 },
          })
        );
        break;

      case "h5":
        children.push(
          new Paragraph({
            children: [
              new TextRun({
                text: classified.text,
                bold: true,
                italics: true,
                size: 20,
                font: "Calibri",
                color: BRAND.textColor,
              }),
            ],
            heading: HeadingLevel.HEADING_5,
            spacing: { before: 100, after: 60 },
          })
        );
        break;

      case "hr":
        children.push(
          new Paragraph({
            border: {
              bottom: {
                style: BorderStyle.SINGLE,
                size: 1,
                color: BRAND.lightGray,
              },
            },
            spacing: { before: 120, after: 120 },
          })
        );
        break;

      case "bullet":
        children.push(
          new Paragraph({
            children: parseInlineFormatting(classified.text),
            bullet: { level: 0 },
            spacing: { before: 40, after: 40 },
          })
        );
        break;

      case "numbered":
        children.push(
          new Paragraph({
            children: parseInlineFormatting(classified.text),
            numbering: { reference: "reva-turbo-numbering", level: 0 },
            spacing: { before: 40, after: 40 },
          })
        );
        break;

      case "checklist":
        children.push(
          new Paragraph({
            children: [
              new TextRun({
                text: classified.checked ? "[x] " : "[ ] ",
                font: "Consolas",
                size: 20,
              }),
              ...parseInlineFormatting(classified.text),
            ],
            bullet: { level: 0 },
            spacing: { before: 40, after: 40 },
          })
        );
        break;

      case "blockquote":
        children.push(
          new Paragraph({
            children: parseInlineFormatting(classified.text),
            indent: { left: convertInchesToTwip(0.5) },
            border: {
              left: {
                style: BorderStyle.SINGLE,
                size: 4,
                color: BRAND.secondaryColor,
              },
            },
            shading: {
              type: ShadingType.SOLID,
              color: BRAND.accentColor,
            },
            spacing: { before: 80, after: 80 },
          })
        );
        break;

      case "paragraph":
        children.push(
          new Paragraph({
            children: parseInlineFormatting(classified.text),
            spacing: { before: 60, after: 60 },
          })
        );
        break;

      default:
        children.push(
          new Paragraph({
            children: [
              new TextRun({ text: lines[i], size: 20, font: "Calibri" }),
            ],
          })
        );
    }
  }

  // Flush any remaining table or code block
  if (inTable) flushTable();
  if (inCodeBlock) flushCode();

  return children;
}

function buildDocument(markdownContent) {
  const bodyChildren = convertMarkdownToDocx(markdownContent);

  return new Document({
    creator: BRAND.engine,
    title: "REVA-TURBO Report",
    description: "Generated by " + BRAND.engine,
    numbering: {
      config: [
        {
          reference: "reva-turbo-numbering",
          levels: [
            {
              level: 0,
              format: LevelFormat.DECIMAL,
              text: "%1.",
              alignment: AlignmentType.LEFT,
              style: {
                paragraph: {
                  indent: {
                    left: convertInchesToTwip(0.5),
                    hanging: convertInchesToTwip(0.25),
                  },
                },
              },
            },
          ],
        },
      ],
    },
    sections: [
      {
        properties: {
          page: {
            margin: {
              top: convertInchesToTwip(1),
              bottom: convertInchesToTwip(1),
              left: convertInchesToTwip(1),
              right: convertInchesToTwip(1),
            },
          },
        },
        headers: {
          default: createHeader(),
        },
        footers: {
          default: createFooter(),
        },
        children: bodyChildren,
      },
    ],
  });
}

// --- Main ---

async function main() {
  const args = process.argv.slice(2);

  if (args.length === 0) {
    console.error("Usage: node report-to-docx.mjs <input-markdown-file>");
    console.error("Example: node report-to-docx.mjs REVA-TURBO-WeeklySummary-2026-03-27-RY.md");
    process.exit(1);
  }

  const inputPath = args[0];
  let markdownContent;

  try {
    markdownContent = readFileSync(inputPath, "utf-8");
  } catch (err) {
    console.error(`Error reading file: ${inputPath}`);
    console.error(err.message);
    process.exit(1);
  }

  const ext = extname(inputPath);
  const outputPath = join(
    dirname(inputPath),
    basename(inputPath, ext) + ".docx"
  );

  console.log(`Converting: ${inputPath}`);
  console.log(`Output:     ${outputPath}`);

  const doc = buildDocument(markdownContent);
  const buffer = await Packer.toBuffer(doc);

  writeFileSync(outputPath, buffer);

  const sizeMB = (buffer.length / 1024 / 1024).toFixed(2);
  console.log(`Done. Output size: ${sizeMB} MB`);
  console.log(`File saved to: ${outputPath}`);
}

main().catch((err) => {
  console.error("Conversion failed:", err.message);
  process.exit(1);
});
