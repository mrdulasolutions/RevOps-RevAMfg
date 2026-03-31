---
name: reva-turbo-handoff
preamble-tier: 2
version: 1.0.0
description: |
  Multi-PM collaboration and portfolio transfer for Rev A Manufacturing. Vacation
  handoffs, permanent transfers, shared ownership, approval chains, and workload
  balancing. One command transfers an entire portfolio with full context.
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
mkdir -p ~/.reva-turbo/analytics
echo '{"skill":"reva-turbo-handoff","ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"}' >> ~/.reva-turbo/analytics/skill-usage.jsonl 2>/dev/null || true
```

## Purpose

Enable seamless PM-to-PM collaboration and portfolio transfer at Rev A Manufacturing. When a PM goes on vacation, one command transfers their entire portfolio to a backup PM with full context. Supports shared ownership, approval routing, and workload balancing alerts.

## PM Roster

Current Rev A Manufacturing PM team:

| PM | Role | Specialization |
|----|------|---------------|
| Donovan Weber | Owner/CEO | Final approvals, strategic accounts |
| Ray | Senior PM | High-value accounts, complex orders |
| Harley | Senior PM | Production orders, partner management |

If PM roster changes, update this table.

## Flow

### Step 0: Handoff Mode Selection

> What type of handoff do you need?
>
> A) **Vacation handoff** -- transfer entire portfolio temporarily (auto-reverts on return)
> B) **Permanent transfer** -- move specific orders/customers to a different PM
> C) **Shared ownership** -- add a secondary PM to specific orders
> D) **Approval request** -- route a document for sign-off
> E) **Workload check** -- view current PM workload balance
>
> Select A-E: ___

Route to the appropriate sub-flow below.

---

### Mode A: Vacation Handoff

#### Step A1: Vacation Details

> **Vacation Handoff Setup**
>
> 1. Your name (PM going on vacation): ___
> 2. Vacation start date: ___
> 3. Vacation end date (return date): ___
> 4. Backup PM (or enter "suggest" for system recommendation): ___
> 5. Emergency contact method while away: ___
> 6. Any items that should NOT be transferred (you will handle remotely): ___

#### Step A2: Portfolio Discovery

Scan all active items for the departing PM:

```bash
mkdir -p ~/.reva-turbo/state
grep '"pm":"{{DEPARTING_PM}}"' ~/.reva-turbo/state/workflow-state.jsonl 2>/dev/null | grep -v '"status":"complete"' | grep -v '"status":"cancelled"' || echo "No active items found in state file"
```

Build the complete portfolio inventory. Reference `references/handoff-checklist.md` for what must be included.

**Portfolio summary for {{DEPARTING_PM}}:**

| Category | Count | Details |
|----------|-------|---------|
| Active orders | {{ACTIVE_ORDER_COUNT}} | {{ACTIVE_ORDER_SUMMARY}} |
| Open RFQs | {{OPEN_RFQ_COUNT}} | {{OPEN_RFQ_SUMMARY}} |
| Pending customer responses | {{PENDING_COMMS_COUNT}} | {{PENDING_COMMS_SUMMARY}} |
| Open quality issues (NCRs) | {{OPEN_NCR_COUNT}} | {{OPEN_NCR_SUMMARY}} |
| Pending escalations | {{PENDING_ESC_COUNT}} | {{PENDING_ESC_SUMMARY}} |
| Upcoming deadlines (within vacation window) | {{DEADLINE_COUNT}} | {{DEADLINE_SUMMARY}} |

#### Step A3: Backup PM Selection

If PM entered "suggest", evaluate workload for available PMs. Reference `references/workload-model.md`.

| PM | Current Weighted Load | Available Capacity | Recommendation |
|----|----------------------|-------------------|---------------|
| {{PM_1}} | {{PM_1_LOAD}} units | {{PM_1_CAPACITY}} units | {{PM_1_REC}} |
| {{PM_2}} | {{PM_2_LOAD}} units | {{PM_2_CAPACITY}} units | {{PM_2_REC}} |

> **Recommended backup:** {{RECOMMENDED_BACKUP}}
> Reason: {{BACKUP_REASON}}
>
> Accept this recommendation? (Y/N)

If PM selected a specific backup, verify their capacity:

> {{BACKUP_PM}} currently has {{BACKUP_LOAD}} weighted units (max recommended: 15).
> Adding your portfolio ({{DEPARTING_LOAD}} units) would bring them to {{COMBINED_LOAD}} units.
>
> {{CAPACITY_WARNING}}

#### Step A4: Generate Handoff Briefing

Generate a comprehensive handoff briefing using `templates/Handoff Briefing.md`. Include every active item with full context.

For each active order:

> **Order {{ORDER_ID}} -- {{CUSTOMER_COMPANY}}**
> - Part: {{PART_DESCRIPTION}}
> - Stage: {{CURRENT_STAGE}}
> - Status: {{CURRENT_STATUS}}
> - Next milestone: {{NEXT_MILESTONE}} (due: {{MILESTONE_DATE}})
> - Key context: {{ORDER_CONTEXT}}
> - Risks/issues: {{ORDER_RISKS}}
> - Action needed: {{ACTION_NEEDED}}
> - Customer sensitivity notes: {{SENSITIVITY_NOTES}}

For each open RFQ:

> **RFQ {{RFQ_ID}} -- {{CUSTOMER_COMPANY}}**
> - Description: {{RFQ_DESCRIPTION}}
> - Stage: {{RFQ_STAGE}}
> - Deadline: {{RFQ_DEADLINE}}
> - Quote status: {{QUOTE_STATUS}}
> - Key context: {{RFQ_CONTEXT}}
> - Action needed: {{RFQ_ACTION}}

For each open quality issue:

> **NCR {{NCR_ID}} -- {{ORDER_ID}}**
> - Issue: {{NCR_DESCRIPTION}}
> - Status: {{NCR_STATUS}}
> - Disposition: {{NCR_DISPOSITION}}
> - Customer notified: {{CUSTOMER_NOTIFIED}}
> - Action needed: {{NCR_ACTION}}

**HUMAN-IN-THE-LOOP CHECKPOINT:**

> ## Handoff Briefing Review
>
> I have compiled a handoff briefing with:
> - {{ACTIVE_ORDER_COUNT}} active orders
> - {{OPEN_RFQ_COUNT}} open RFQs
> - {{OPEN_NCR_COUNT}} open quality issues
> - {{DEADLINE_COUNT}} deadlines during your absence
>
> A) Review the full briefing before transferring
> B) Approve and transfer now
> C) Add notes or corrections to specific items
> D) Cancel handoff

#### Step A5: Execute Transfer

Transfer ownership in state files:

```bash
echo '{"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","type":"vacation_handoff","from":"{{DEPARTING_PM}}","to":"{{BACKUP_PM}}","start":"{{VACATION_START}}","end":"{{VACATION_END}}","items_transferred":{{ITEM_COUNT}},"auto_revert":"{{VACATION_END}}"}' >> ~/.reva-turbo/state/handoff-log.jsonl 2>/dev/null || true
```

Create a revert trigger:

```bash
echo '{"revert_date":"{{VACATION_END}}","from":"{{BACKUP_PM}}","to":"{{DEPARTING_PM}}","handoff_id":"{{HANDOFF_ID}}","status":"pending"}' >> ~/.reva-turbo/state/handoff-reverts.jsonl 2>/dev/null || true
```

Update pulse alert routing:

```bash
echo '{"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","type":"alert_redirect","original_pm":"{{DEPARTING_PM}}","redirect_to":"{{BACKUP_PM}}","until":"{{VACATION_END}}"}' >> ~/.reva-turbo/state/alert-routing.jsonl 2>/dev/null || true
```

> Handoff complete.
> - {{ITEM_COUNT}} items transferred from {{DEPARTING_PM}} to {{BACKUP_PM}}
> - Pulse alerts redirected to {{BACKUP_PM}} until {{VACATION_END}}
> - Auto-revert scheduled for {{VACATION_END}}
> - Handoff briefing saved to `~/.reva-turbo/handoffs/{{HANDOFF_ID}}/`
>
> {{BACKUP_PM}}: your handoff briefing is ready. Run `/reva-turbo-handoff` and select "review incoming handoff" to see it.

#### Step A6: Auto-Revert (on return date)

When the return date arrives (checked by `reva-turbo-cron` or `reva-turbo-pulse`):

1. Revert all ownership to the returning PM
2. Generate a Return Briefing using `templates/Return Briefing.md`
3. Log the revert

> Welcome back, {{DEPARTING_PM}}. Here is your return briefing.
>
> During your absence ({{VACATION_START}} to {{VACATION_END}}):
> - {{BACKUP_PM}} managed {{ITEM_COUNT}} items
> - {{MILESTONES_COMPLETED}} milestones were completed
> - {{NEW_ITEMS}} new items were added
> - {{ISSUES_RESOLVED}} issues were resolved
> - {{ITEMS_NEEDING_ATTENTION}} items need your attention
>
> See the full return briefing for details.

---

### Mode B: Permanent Transfer

#### Step B1: Transfer Scope

> **Permanent Transfer**
>
> 1. Transferring PM: ___
> 2. Receiving PM: ___
> 3. What to transfer:
>    A) Specific orders (enter order IDs): ___
>    B) Specific customers (all orders for these customers): ___
>    C) All orders matching criteria (e.g., process type, partner): ___
> 4. Reason for transfer: ___

#### Step B2: Transfer Package

For each item being transferred, generate a transfer context package:

- Complete order history and current status
- Customer relationship notes and preferences
- Partner context and current manufacturing status
- All open issues and pending actions
- Communication history summary
- Special handling instructions

**HUMAN-IN-THE-LOOP CHECKPOINT:**

> ## Transfer Package Review
>
> Transferring {{TRANSFER_COUNT}} items from {{FROM_PM}} to {{TO_PM}}:
>
> {{#TRANSFER_ITEMS}}
> - {{ITEM_TYPE}}: {{ITEM_ID}} ({{CUSTOMER_COMPANY}}) -- {{CURRENT_STATUS}}
> {{/TRANSFER_ITEMS}}
>
> A) Review full transfer package
> B) Proceed with transfer (receiving PM will be asked to confirm)
> C) Modify transfer scope
> D) Cancel

#### Step B3: Receiving PM Confirmation

> {{TO_PM}}: You are receiving {{TRANSFER_COUNT}} items from {{FROM_PM}}.
>
> Reason: {{TRANSFER_REASON}}
>
> A) Accept all transfers
> B) Review items before accepting
> C) Reject transfer (will notify {{FROM_PM}})

#### Step B4: Execute Permanent Transfer

```bash
echo '{"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","type":"permanent_transfer","from":"{{FROM_PM}}","to":"{{TO_PM}}","items":{{TRANSFER_ITEMS_JSON}},"reason":"{{TRANSFER_REASON}}"}' >> ~/.reva-turbo/state/handoff-log.jsonl 2>/dev/null || true
```

Update all state files, CRM records, and alert routing for the transferred items. No auto-revert.

---

### Mode C: Shared Ownership

#### Step C1: Shared Ownership Setup

> **Shared Ownership Setup**
>
> 1. Order/RFQ to share: ___
> 2. Primary PM (decision authority): ___
> 3. Secondary PM (visibility and/or specific actions): ___
> 4. Secondary PM role:
>    A) Visibility only (receives alerts, can view status)
>    B) Specific actions (specify which): ___
>    C) Full co-ownership (both can take all actions)
> 5. Duration: indefinite / until [date]: ___

#### Step C2: Configure Shared Ownership

```bash
echo '{"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","type":"shared_ownership","item_id":"{{ITEM_ID}}","primary_pm":"{{PRIMARY_PM}}","secondary_pm":"{{SECONDARY_PM}}","secondary_role":"{{SECONDARY_ROLE}}","duration":"{{DURATION}}"}' >> ~/.reva-turbo/state/handoff-log.jsonl 2>/dev/null || true
```

Alert routing update: both PMs receive alerts for this item. Primary PM is the default action taker.

> Shared ownership configured:
> - Item: {{ITEM_ID}} ({{CUSTOMER_COMPANY}})
> - Primary: {{PRIMARY_PM}} (full authority)
> - Secondary: {{SECONDARY_PM}} ({{SECONDARY_ROLE_DESC}})
> - Duration: {{DURATION}}

---

### Mode D: Approval Request

#### Step D1: Approval Details

Reference `references/approval-matrix.md` for routing logic.

> **Approval Request**
>
> 1. What needs approval:
>    A) Quote send
>    B) NCR disposition
>    C) Price exception (below minimum margin)
>    D) Partner change mid-order
>    E) Change order cost increase
>    F) Other: ___
> 2. Order/RFQ ID: ___
> 3. Value/amount: $___
> 4. Your recommendation: ___

#### Step D2: Route to Approver

Determine the approver based on the approval matrix:

| Action | Threshold | Approver |
|--------|-----------|----------|
| Quote send | >$50K | Senior PM (Ray/Harley) |
| Quote send | >$100K | Donovan Weber |
| New customer first order | >$25K | Senior PM |
| NCR disposition: use-as-is | Any | Senior PM |
| NCR disposition: RTV | >$10K | Donovan Weber |
| Price exception (below min margin) | Any | Donovan Weber |
| Partner change mid-order | Any | Senior PM |
| Change order cost increase | >$5K | Senior PM |
| Change order cost increase | >$20K | Donovan Weber |

> **Approval routed to: {{APPROVER}}**
>
> Reason: {{APPROVAL_REASON}}
>
> Context package attached with:
> - Order/RFQ summary
> - Financial details
> - PM recommendation
> - Risk assessment

#### Step D3: Approver Decision

> {{APPROVER}}: Approval request from {{REQUESTING_PM}}
>
> **{{APPROVAL_TYPE}}** for {{ITEM_ID}} ({{CUSTOMER_COMPANY}})
> **Value:** ${{APPROVAL_VALUE}}
>
> {{CONTEXT_SUMMARY}}
>
> **PM Recommendation:** {{PM_RECOMMENDATION}}
>
> A) Approve
> B) Approve with conditions: ___
> C) Reject -- reason: ___
> D) Request more information: ___

#### Step D4: Log Approval Decision

```bash
echo '{"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","type":"approval","item_id":"{{ITEM_ID}}","action":"{{APPROVAL_TYPE}}","value":"{{APPROVAL_VALUE}}","requested_by":"{{REQUESTING_PM}}","approver":"{{APPROVER}}","decision":"{{DECISION}}","conditions":"{{CONDITIONS}}","reason":"{{REASON}}"}' >> ~/.reva-turbo/state/approval-log.jsonl 2>/dev/null || true
```

Notify the requesting PM:

> **Approval {{DECISION}}** by {{APPROVER}}
> Item: {{ITEM_ID}}
> {{CONDITIONS_OR_REASON}}
> You may proceed. (or: See rejection reason above.)

---

### Mode E: Workload Check

#### Step E1: Calculate Workload

Reference `references/workload-model.md` for weighting rules.

Scan all active items per PM:

```bash
grep -c '"pm":"{{PM_NAME}}"' ~/.reva-turbo/state/workflow-state.jsonl 2>/dev/null || echo "0"
```

Calculate weighted workload for each PM:

| PM | Simple Orders | Complex Orders | New Cust Orders | NCR Orders | Open RFQs | Total Weighted |
|----|--------------|---------------|-----------------|-----------|-----------|---------------|
| {{PM_1}} | {{PM1_SIMPLE}} (x1.0) | {{PM1_COMPLEX}} (x2.0) | {{PM1_NEW}} (x1.5) | {{PM1_NCR}} (x1.5) | {{PM1_RFQ}} (x0.5) | **{{PM1_TOTAL}}** |
| {{PM_2}} | {{PM2_SIMPLE}} (x1.0) | {{PM2_COMPLEX}} (x2.0) | {{PM2_NEW}} (x1.5) | {{PM2_NCR}} (x1.5) | {{PM2_RFQ}} (x0.5) | **{{PM2_TOTAL}}** |
| {{PM_3}} | {{PM3_SIMPLE}} (x1.0) | {{PM3_COMPLEX}} (x2.0) | {{PM3_NEW}} (x1.5) | {{PM3_NCR}} (x1.5) | {{PM3_RFQ}} (x0.5) | **{{PM3_TOTAL}}** |

#### Step E2: Imbalance Detection

Check for imbalances:

- If any PM exceeds 20 weighted units: **OVERLOAD ALERT**
- If imbalance ratio >2x between any two PMs: **IMBALANCE ALERT**

> **Workload Assessment:**
>
> {{WORKLOAD_SUMMARY}}
>
> {{IMBALANCE_ALERT_OR_OK}}

If imbalance detected:

> **Recommended redistribution:**
>
> Move the following from {{OVERLOADED_PM}} to {{UNDERLOADED_PM}}:
> {{#REDISTRIBUTION_ITEMS}}
> - {{ITEM_ID}} ({{CUSTOMER_COMPANY}}) -- {{REASON}}
> {{/REDISTRIBUTION_ITEMS}}
>
> This would bring {{OVERLOADED_PM}} to {{NEW_LOAD_1}} units and {{UNDERLOADED_PM}} to {{NEW_LOAD_2}} units.
>
> A) Execute redistribution (permanent transfer)
> B) Review items before redistributing
> C) Dismiss -- workloads are acceptable

---

## Audit Trail

Every ownership change is logged with:

```json
{
  "ts": "ISO 8601 timestamp",
  "type": "vacation_handoff | permanent_transfer | shared_ownership | approval | revert",
  "from": "source PM",
  "to": "destination PM",
  "items": ["item IDs"],
  "reason": "why the change was made",
  "scope": "full portfolio | specific orders | specific customers",
  "auto_revert": "date or null",
  "handoff_id": "unique ID"
}
```

All handoff logs stored at `~/.reva-turbo/state/handoff-log.jsonl`.
All approval logs stored at `~/.reva-turbo/state/approval-log.jsonl`.

## Template References

- `prompts/handoff-system.md` -- Handoff briefing generation rules and approval chain logic
- `prompts/handoff-user-template.md` -- Handoff request variables
- `references/handoff-checklist.md` -- What must be included in every handoff
- `references/approval-matrix.md` -- Who approves what and at what threshold
- `references/workload-model.md` -- How to measure and balance PM workload
- `templates/Handoff Briefing.md` -- Comprehensive handoff briefing template
- `templates/Return Briefing.md` -- What happened while PM was away
