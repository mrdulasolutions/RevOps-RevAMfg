# PMLORD Template Inventory

Complete catalog of all templates across all PMLORD skills.

## Template Registry

### pmlord-rfq-intake
| Template | File | Purpose | Report Naming |
|----------|------|---------|--------------|
| RFQ Intake Record | `pmlord-rfq-intake/templates/RFQ Intake Record.md` | Structured RFQ data extraction output | `PMLORD-RFQIntake-{YYYY-MM-DD}-{CustomerShortName}.md` |

### pmlord-rfq-qualify
| Template | File | Purpose | Report Naming |
|----------|------|---------|--------------|
| Qualification Gate Report | `pmlord-rfq-qualify/templates/Qualification Gate Report.md` | RFQ qualification assessment | `PMLORD-RFQQualify-{YYYY-MM-DD}-{CustomerShortName}.md` |

### pmlord-rfq-quote
| Template | File | Purpose | Report Naming |
|----------|------|---------|--------------|
| Quote Document | `pmlord-rfq-quote/templates/Quote Document.md` | Formal customer quotation | `PMLORD-Quote-{YYYY-MM-DD}-{CustomerShortName}.md` |

### pmlord-order-track
| Template | File | Purpose | Report Naming |
|----------|------|---------|--------------|
| Order Status Report | `pmlord-order-track/templates/Order Status Report.md` | Full order status with timeline and details | `PMLORD-OrderStatus-{YYYY-MM-DD}-{PO_NUMBER}.md` |

### pmlord-logistics
| Template | File | Purpose | Report Naming |
|----------|------|---------|--------------|
| Shipping Coordination | `pmlord-logistics/templates/Shipping Coordination.md` | Shipment setup document with all logistics details | `PMLORD-Shipping-{YYYY-MM-DD}-{PO_NUMBER}.md` |
| Customs Documentation Checklist | `pmlord-logistics/templates/Customs Documentation Checklist.md` | Checklist for customs document completeness | `PMLORD-CustomsDocs-{YYYY-MM-DD}-{PO_NUMBER}.md` |

### pmlord-repackage
| Template | File | Purpose | Report Naming |
|----------|------|---------|--------------|
| Repackaging Work Order | `pmlord-repackage/templates/Repackaging Work Order.md` | Work order for repackaging operations | `PMLORD-Repackage-{YYYY-MM-DD}-{PO_NUMBER}.md` |

### pmlord-inspect
| Template | File | Purpose | Report Naming |
|----------|------|---------|--------------|
| Inspection Report | `pmlord-inspect/templates/Inspection Report.md` | Quality inspection results | `PMLORD-Inspection-{YYYY-MM-DD}-{PO_NUMBER}.md` |

### pmlord-ncr
| Template | File | Purpose | Report Naming |
|----------|------|---------|--------------|
| NCR Report | `pmlord-ncr/templates/NCR Report.md` | Non-conformance report | `PMLORD-NCR-{YYYY-MM-DD}-{NCR_NUMBER}.md` |

### pmlord-dashboard
| Template | File | Purpose | Report Naming |
|----------|------|---------|--------------|
| PM Dashboard | `pmlord-dashboard/templates/PM Dashboard.md` | Workload dashboard snapshot | `PMLORD-Dashboard-{YYYY-MM-DD}-{PM_INITIALS}.md` |

### pmlord-report
| Template | File | Purpose | Report Naming |
|----------|------|---------|--------------|
| Weekly PM Summary | `pmlord-report/templates/Weekly PM Summary.md` | Weekly activity and status summary | `PMLORD-WeeklySummary-{YYYY-MM-DD}-{PM_INITIALS}.md` |
| Monthly Performance | `pmlord-report/templates/Monthly Performance.md` | Monthly KPI and performance report | `PMLORD-MonthlyPerf-{YYYY-MM}-RevA.md` |
| Quarterly Review | `pmlord-report/templates/Quarterly Review.md` | Quarterly business review | `PMLORD-QuarterlyReview-{YYYY}-Q{N}-RevA.md` |
| Customer Report | `pmlord-report/templates/Customer Report.md` | Customer-specific order and quality report | `PMLORD-CustomerReport-{YYYY-MM-DD}-{CustomerShortName}.md` |

### pmlord-audit-trail
| Template | File | Purpose | Report Naming |
|----------|------|---------|--------------|
| Audit Trail Entry | `pmlord-audit-trail/templates/Audit Trail Entry.md` | Formatted audit trail report | `PMLORD-AuditReport-{YYYY-MM-DD}-{Reference}.md` |

### pmlord-escalate
| Template | File | Purpose | Report Naming |
|----------|------|---------|--------------|
| Escalation Note | `pmlord-escalate/templates/Escalation Note.md` | Issue escalation documentation | `PMLORD-Escalation-{YYYY-MM-DD}-{Reference}.md` |

### pmlord-customer-comms
| Template | File | Purpose | Report Naming |
|----------|------|---------|--------------|
| Customer Communication | `pmlord-customer-comms/templates/Customer Communication.md` | Outbound customer communication | `PMLORD-CustomerComm-{YYYY-MM-DD}-{CustomerShortName}.md` |

### pmlord-partner-scorecard
| Template | File | Purpose | Report Naming |
|----------|------|---------|--------------|
| Partner Scorecard | `pmlord-partner-scorecard/templates/Partner Scorecard.md` | Partner performance scorecard | `PMLORD-PartnerScore-{YYYY-MM-DD}-{PartnerShortName}.md` |

### pmlord-china-package
| Template | File | Purpose | Report Naming |
|----------|------|---------|--------------|
| China Package Spec | `pmlord-china-package/templates/China Package Spec.md` | Packaging spec for China partner | `PMLORD-ChinaPkg-{YYYY-MM-DD}-{PO_NUMBER}.md` |

### pmlord-quality-gate
| Template | File | Purpose | Report Naming |
|----------|------|---------|--------------|
| Quality Gate Report | `pmlord-quality-gate/templates/Quality Gate Report.md` | Quality gate assessment | `PMLORD-QualityGate-{YYYY-MM-DD}-{PO_NUMBER}.md` |

## Template Variable Convention

All templates use `{{VARIABLE_NAME}}` format:

- Variable names are UPPER_SNAKE_CASE
- Variables surrounded by double curly braces
- No default values — all must be explicitly filled
- Missing values should be marked as `[MISSING — follow up required]`

## Report File Naming Convention

All generated reports follow: `PMLORD-{Type}-{YYYY-MM-DD}-{ShortName}.md`

| Component | Format | Example |
|-----------|--------|---------|
| Prefix | `PMLORD` | Always |
| Type | PascalCase abbreviation | `OrderStatus`, `WeeklySummary`, `NCR` |
| Date | `YYYY-MM-DD` | `2026-03-30` |
| ShortName | CamelCase or PO number | `AcmeCorp`, `PO-2026-0042` |
| Extension | `.md` or `.docx` | `.md` for markdown, `.docx` after conversion |

## Version History

All templates are at v1.0.0 (initial release). Version tracks with parent skill version.
