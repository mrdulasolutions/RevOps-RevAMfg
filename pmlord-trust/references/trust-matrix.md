# Trust Level x Skill Behavior Matrix

This matrix defines how each major skill category behaves at each trust level. Use this as the authoritative reference when implementing trust-aware behavior in any skill.

## Core Workflow Skills

| Skill Category | Level 1: LEARN | Level 2: ASSIST | Level 3: OPERATE |
|---|---|---|---|
| **RFQ Intake** (`pmlord-rfq-intake`) | Explain each field as it is extracted. Show source (email line, drawing note). Ask before saving. Teach what makes a good RFQ. | Pre-fill all fields from email/drawing. Show confidence scores. Save HIGH-confidence entries automatically, pause on MEDIUM/LOW. | Auto-create RFQ from email. Auto-qualify if capability match exists. Send acknowledgment. PM sees daily summary. |
| **RFQ Qualify** (`pmlord-rfq-qualify`) | Walk through each qualification criterion. Explain capability matching. Show pass/fail per criterion. Ask PM to confirm qualification decision. | Run all criteria automatically. Present pass/fail summary with notes on borderline items. Recommend qualify/disqualify with reasoning. | Auto-qualify based on historical capability data. Only alert if no capability match or borderline criteria. |
| **RFQ Quote** (`pmlord-rfq-quote`) | Explain cost buildup line by line. Show how margin is calculated. Explain payment terms selection. Ask PM to approve final price. | Build complete quote draft. Show margin analysis and comparison to similar quotes. Flag if margin is outside target range. One-click approve. | Auto-generate quotes for reorders and standard parts. Alert on new part types, unusual quantities, or margin deviations. |
| **Customer Comms** (`pmlord-customer-comms`) | Show full draft. Explain tone choices and content decisions. Teach email best practices for manufacturing PM. Ask before any send. | Draft with confidence score. One-click send for HIGH confidence. Edit interface for MEDIUM. Never auto-send LOW confidence. | Auto-send routine messages (tracking updates, acknowledgments, payment confirmations). Queue complex messages (negotiations, complaints, escalations) for PM review. |
| **China Package** (`pmlord-china-package`) | Walk through each specification field. Explain what the manufacturing partner needs and why. Show the complete package before sending. Teach packaging standards. | Build complete package. Highlight any gaps or ambiguities. Show side-by-side comparison with previous successful packages. One-click send. | Auto-package routine reorders using historical specs. Flag new specifications, material changes, or tolerance changes. Auto-send to preferred partner for known part families. |
| **China Track** (`pmlord-china-track`) | Explain each tracking milestone. Teach the manufacturing timeline. Show what each status means. Ask before sending status updates to customer. | Show consolidated tracking dashboard. Auto-generate customer updates but hold for review. Flag late shipments and approaching deadlines. | Auto-track and auto-update customers on routine milestones. Alert only on delays, exceptions, or approaching delivery dates. |

## Quality and Compliance Skills

| Skill Category | Level 1: LEARN | Level 2: ASSIST | Level 3: OPERATE |
|---|---|---|---|
| **Quality Gate** (`pmlord-quality-gate`) | Explain each inspection criterion. Show acceptance limits. Teach what constitutes pass/fail/borderline. Ask PM to confirm each gate decision. | Pre-fill inspection results from data. Show pass/fail with confidence. Batch clear passes. Pause on borderline and fail. Flag statistical trends. | Auto-pass clear cases (all dimensions within 80% of tolerance). Alert on borderline (within 90-100% of tolerance). Always alert on fail. **Safety cap: Level 2 for final inspection gate.** |
| **Inspect** (`pmlord-inspect`) | Walk through inspection plan step by step. Explain each measurement and its significance. Show how to read inspection reports. Teach AQL concepts. | Generate inspection report with results pre-filled. Highlight out-of-spec measurements. Show trend analysis vs previous lots. Recommend accept/reject with reasoning. | Auto-generate inspection reports. Auto-accept lots that pass all criteria cleanly. Alert on any out-of-spec measurement. **Safety cap: Level 2 for final lot acceptance.** |
| **Export Compliance** (`pmlord-export-compliance`) | **Always verbose regardless of trust level.** Explain ECCN classification step by step. Show how jurisdiction is determined. Walk through license requirements. Explain denied party screening. | Pre-screen and show results. Present classification with reasoning. Show denied party screening results. PM must review and approve. **Safety cap: maximum Level 2.** | Pre-screen automatically. Flag any hits or concerns. Auto-clear only obviously clean cases (domestic, no ECCN). **Safety cap: maximum Level 2. Never auto-approve classification or license determination.** |
| **Import Compliance** (`pmlord-import-compliance`) | Explain HTS classification. Teach duty rate lookup. Walk through country of origin determination. Explain preferential trade programs. | Pre-classify with confidence scores. Show duty rate estimates. Flag items that may qualify for preferential programs. PM reviews before filing. | Auto-classify routine items with historical matches. Alert on new HTS codes, duty rate changes, or classification uncertainty. **Safety cap: maximum Level 2 for formal entries.** |
| **NCR** (`pmlord-ncr`) | Explain nonconformance documentation. Walk through root cause analysis. Teach corrective action planning. Show how NCRs affect partner scorecard. | Draft NCR with pre-filled details. Suggest root cause category. Draft corrective action request. PM reviews before issuing. | Auto-generate NCRs for clear quality failures. Auto-notify partner. Alert PM on repeat NCRs, systemic issues, or high-value impacts. |

## Tracking and Management Skills

| Skill Category | Level 1: LEARN | Level 2: ASSIST | Level 3: OPERATE |
|---|---|---|---|
| **Order Track** (`pmlord-order-track`) | Show each order status with explanation. Teach the order lifecycle stages. Explain what each status means for delivery timeline. | Dashboard view with status indicators. Flag approaching deadlines and delays. Summarize actions needed. | Silent tracking. Auto-update status from carrier/partner feeds. Alert only on delays, exceptions, or delivery confirmation. |
| **Logistics** (`pmlord-logistics`) | Explain shipping options and trade-offs. Walk through freight quote comparison. Teach Incoterms and their implications. | Pre-select shipping method based on order value, urgency, and history. Show comparison table. Recommend with reasoning. | Auto-book routine shipments with preferred carriers. Alert on rate spikes, capacity issues, or unusual routing. |
| **Partner Scorecard** (`pmlord-partner-scorecard`) | Explain each scorecard metric. Teach what drives partner performance. Show how scores are calculated. | Generate scorecard with trend analysis. Highlight improving/declining metrics. Flag partners approaching action thresholds. | Auto-generate scorecards on schedule. Alert only on threshold breaches (on-time < 85%, quality < 95%). |
| **Dashboard** (`pmlord-dashboard`) | Interactive walkthrough of each dashboard section. Explain what each metric means. Teach how to interpret trends. | Standard dashboard display. Highlight items needing attention. Show daily/weekly summary. | Terse dashboard. Numbers and exceptions only. Auto-send digest to PM at configured time. |

## Reporting and Communication Skills

| Skill Category | Level 1: LEARN | Level 2: ASSIST | Level 3: OPERATE |
|---|---|---|---|
| **Report** (`pmlord-report`) | Explain each report section and why it matters. Walk through data sources. Show how metrics are calculated. Ask PM what to include/exclude. | Generate complete report. Show summary and key findings. PM reviews before distribution. | Auto-generate on schedule. Auto-distribute to configured recipients. Alert PM only if report contains exceptions or notable findings. |
| **Escalate** (`pmlord-escalate`) | Explain the escalation matrix. Teach when to escalate. Walk through the escalation process. Ask PM to confirm before escalating. | Draft escalation with context and recommended action. Show escalation matrix for reference. PM confirms before sending. | Auto-escalate routine items per matrix rules. Alert PM on escalations. Never auto-escalate to final level (Donovan Weber) without PM confirmation. |
| **Customer Gate** (`pmlord-customer-gate`) | Explain customer approval gates. Walk through what the customer needs to review. Teach how to prepare gate packages. | Build gate review package. Pre-fill all sections. Show readiness checklist. PM reviews before sending to customer. | Auto-build gate packages when criteria are met. Auto-send to customer for routine gates. Alert PM on critical gates or first-time customers. |
| **CRM Connector** (`pmlord-crm-connector`) | Explain CRM sync and what data flows where. Teach how PMLORD integrates with the CRM. | Sync automatically with summary of changes. Flag conflicts between PMLORD and CRM data. | Silent sync. Alert only on conflicts or sync failures. |

## Financial Skills

| Skill Category | Level 1: LEARN | Level 2: ASSIST | Level 3: OPERATE |
|---|---|---|---|
| **Profit** (`pmlord-profit`) | Explain margin calculations line by line. Teach cost components. Show how landed cost is built up. | Generate profit analysis with comparison to targets. Flag orders below margin threshold. | Auto-generate on order completion. Alert on margin deviations. |
| **Change Order** (`pmlord-change-order`) | Explain change order impact. Walk through cost/schedule implications. Teach change management process. | Draft change order with impact analysis. Show cost delta and schedule impact. PM reviews before issuing. **Financial approvals above threshold: max Level 2.** | Auto-process minor changes (quantity adjustments within 10%, non-critical spec clarifications). Alert on material changes, cost impacts above threshold, or schedule impacts. **Financial approvals above threshold: max Level 2.** |

## Notes

1. **Safety caps** are marked in bold and cannot be overridden by any trust setting
2. Skills not listed here should follow the general behavioral patterns for their trust level
3. When a skill spans multiple categories (e.g., china-package involves both specs AND compliance), apply the most restrictive trust level across all applicable categories
4. The matrix is a guide, not rigid rules -- use judgment when edge cases arise
