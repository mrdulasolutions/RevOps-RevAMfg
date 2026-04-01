# REVA-TURBO Template Inventory

Complete catalog of all templates across all REVA-TURBO skills.

## Template Registry

### reva-turbo-rfq-intake
| Template | File | Purpose | Report Naming |
|----------|------|---------|--------------|
| RFQ Intake Record | `reva-turbo-rfq-intake/templates/RFQ Intake Record.md` | Structured RFQ data extraction output | `REVA-TURBO-RFQIntake-{YYYY-MM-DD}-{CustomerShortName}.md` |

### reva-turbo-rfq-qualify
| Template | File | Purpose | Report Naming |
|----------|------|---------|--------------|
| Qualification Gate Report | `reva-turbo-rfq-qualify/templates/Qualification Gate Report.md` | RFQ qualification assessment | `REVA-TURBO-RFQQualify-{YYYY-MM-DD}-{CustomerShortName}.md` |

### reva-turbo-rfq-quote
| Template | File | Purpose | Report Naming |
|----------|------|---------|--------------|
| Quote Document | `reva-turbo-rfq-quote/templates/Quote Document.md` | Formal customer quotation | `REVA-TURBO-Quote-{YYYY-MM-DD}-{CustomerShortName}.md` |

### reva-turbo-order-track
| Template | File | Purpose | Report Naming |
|----------|------|---------|--------------|
| Order Status Report | `reva-turbo-order-track/templates/Order Status Report.md` | Full order status with timeline and details | `REVA-TURBO-OrderStatus-{YYYY-MM-DD}-{PO_NUMBER}.md` |

### reva-turbo-logistics
| Template | File | Purpose | Report Naming |
|----------|------|---------|--------------|
| Shipping Coordination | `reva-turbo-logistics/templates/Shipping Coordination.md` | Shipment setup document with all logistics details | `REVA-TURBO-Shipping-{YYYY-MM-DD}-{PO_NUMBER}.md` |
| Customs Documentation Checklist | `reva-turbo-logistics/templates/Customs Documentation Checklist.md` | Checklist for customs document completeness | `REVA-TURBO-CustomsDocs-{YYYY-MM-DD}-{PO_NUMBER}.md` |

### reva-turbo-repackage
| Template | File | Purpose | Report Naming |
|----------|------|---------|--------------|
| Repackaging Work Order | `reva-turbo-repackage/templates/Repackaging Work Order.md` | Work order for repackaging operations | `REVA-TURBO-Repackage-{YYYY-MM-DD}-{PO_NUMBER}.md` |

### reva-turbo-inspect
| Template | File | Purpose | Report Naming |
|----------|------|---------|--------------|
| Inspection Report | `reva-turbo-inspect/templates/Inspection Report.md` | Quality inspection results | `REVA-TURBO-Inspection-{YYYY-MM-DD}-{PO_NUMBER}.md` |

### reva-turbo-ncr
| Template | File | Purpose | Report Naming |
|----------|------|---------|--------------|
| NCR Report | `reva-turbo-ncr/templates/NCR Report.md` | Non-conformance report | `REVA-TURBO-NCR-{YYYY-MM-DD}-{NCR_NUMBER}.md` |

### reva-turbo-dashboard
| Template | File | Purpose | Report Naming |
|----------|------|---------|--------------|
| PM Dashboard | `reva-turbo-dashboard/templates/PM Dashboard.md` | Workload dashboard snapshot | `REVA-TURBO-Dashboard-{YYYY-MM-DD}-{PM_INITIALS}.md` |

### reva-turbo-report
| Template | File | Purpose | Report Naming |
|----------|------|---------|--------------|
| Weekly PM Summary | `reva-turbo-report/templates/Weekly PM Summary.md` | Weekly activity and status summary | `REVA-TURBO-WeeklySummary-{YYYY-MM-DD}-{PM_INITIALS}.md` |
| Monthly Performance | `reva-turbo-report/templates/Monthly Performance.md` | Monthly KPI and performance report | `REVA-TURBO-MonthlyPerf-{YYYY-MM}-RevA.md` |
| Quarterly Review | `reva-turbo-report/templates/Quarterly Review.md` | Quarterly business review | `REVA-TURBO-QuarterlyReview-{YYYY}-Q{N}-RevA.md` |
| Customer Report | `reva-turbo-report/templates/Customer Report.md` | Customer-specific order and quality report | `REVA-TURBO-CustomerReport-{YYYY-MM-DD}-{CustomerShortName}.md` |

### reva-turbo-audit-trail
| Template | File | Purpose | Report Naming |
|----------|------|---------|--------------|
| Audit Trail Entry | `reva-turbo-audit-trail/templates/Audit Trail Entry.md` | Formatted audit trail report | `REVA-TURBO-AuditReport-{YYYY-MM-DD}-{Reference}.md` |

### reva-turbo-escalate
| Template | File | Purpose | Report Naming |
|----------|------|---------|--------------|
| Escalation Note | `reva-turbo-escalate/templates/Escalation Note.md` | Issue escalation documentation | `REVA-TURBO-Escalation-{YYYY-MM-DD}-{Reference}.md` |

### reva-turbo-customer-comms
| Template | File | Purpose | Report Naming |
|----------|------|---------|--------------|
| Customer Communication | `reva-turbo-customer-comms/templates/Customer Communication.md` | Outbound customer communication | `REVA-TURBO-CustomerComm-{YYYY-MM-DD}-{CustomerShortName}.md` |

### reva-turbo-partner-scorecard
| Template | File | Purpose | Report Naming |
|----------|------|---------|--------------|
| Partner Scorecard | `reva-turbo-partner-scorecard/templates/Partner Scorecard.md` | Partner performance scorecard | `REVA-TURBO-PartnerScore-{YYYY-MM-DD}-{PartnerShortName}.md` |

### reva-turbo-china-package
| Template | File | Purpose | Report Naming |
|----------|------|---------|--------------|
| China Package Spec | `reva-turbo-china-package/templates/China Package Spec.md` | Packaging spec for China partner | `REVA-TURBO-ChinaPkg-{YYYY-MM-DD}-{PO_NUMBER}.md` |

### reva-turbo-quality-gate
| Template | File | Purpose | Report Naming |
|----------|------|---------|--------------|
| Quality Gate Report | `reva-turbo-quality-gate/templates/Quality Gate Report.md` | Quality gate assessment | `REVA-TURBO-QualityGate-{YYYY-MM-DD}-{PO_NUMBER}.md` |

## Template Variable Convention

All templates use `{{VARIABLE_NAME}}` format:

- Variable names are UPPER_SNAKE_CASE
- Variables surrounded by double curly braces
- No default values — all must be explicitly filled
- Missing values should be marked as `[MISSING — follow up required]`

## Report File Naming Convention

All generated reports follow: `REVA-TURBO-{Type}-{YYYY-MM-DD}-{ShortName}.md`

| Component | Format | Example |
|-----------|--------|---------|
| Prefix | `REVA-TURBO` | Always |
| Type | PascalCase abbreviation | `OrderStatus`, `WeeklySummary`, `NCR` |
| Date | `YYYY-MM-DD` | `2026-03-30` |
| ShortName | CamelCase or PO number | `AcmeCorp`, `PO-2026-0042` |
| Extension | `.md` or `.docx` | `.md` for markdown, `.docx` after conversion |

## Version History

All templates are at v1.0.0 (initial release). Version tracks with parent skill version.
