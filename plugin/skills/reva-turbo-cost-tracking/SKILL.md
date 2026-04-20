---
name: reva-turbo-cost-tracking
preamble-tier: 2
version: 1.0.0
description: |
  Single source of truth for order cost tracking. Maintains a running ledger of
  estimated vs actual costs per order across all cost categories. Every skill that
  touches cost data feeds into this skill. Tracks landed cost, margin, and variance.
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
mkdir -p ~/.reva-turbo/analytics ~/.reva-turbo/state
echo '{"skill":"reva-turbo-cost-tracking","ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"}' >> ~/.reva-turbo/analytics/skill-usage.jsonl 2>/dev/null || true
```

## Purpose

Single source of truth for order cost tracking at Rev A Manufacturing. Maintains a running ledger of estimated versus actual costs per order across all cost categories. Every skill that touches cost data (reva-turbo-rfq-quote, reva-turbo-change-order, reva-turbo-import-compliance, reva-turbo-logistics, reva-turbo-repackage, reva-turbo-profit) feeds cost events into this skill's ledger. PMs and the profit skill query this skill for cost roll-up and margin analysis.

## Cost Categories

| Category | Description | Set By |
|----------|-------------|--------|
| `partner_quote` | Manufacturing partner cost (parts + assembly) | reva-turbo-rfq-quote |
| `tooling` | Tooling, mold, fixture costs | reva-turbo-rfq-quote, reva-turbo-change-order |
| `materials` | Raw material surcharges (if billed separately) | reva-turbo-rfq-quote |
| `shipping_intl` | International freight (China to port / Rev A / customer) | reva-turbo-logistics |
| `duties_tariffs` | Import duties, Section 301 tariffs, customs fees | reva-turbo-import-compliance |
| `shipping_domestic` | Domestic freight (Rev A to customer, if I&F flow) | reva-turbo-logistics |
| `inspection` | Third-party inspection fees, Rev A inspection labor | reva-turbo-inspect |
| `repackage` | Repackaging, relabeling, CoC preparation costs | reva-turbo-repackage |
| `overhead` | Rev A overhead allocation (fixed percentage from config) | reva-turbo-rfq-quote |
| `other` | Any miscellaneous cost not in the above categories | Any skill |

## Flow

### Step 1 — Identify Order and Action

```bash
_ORDER_ID="{{ORDER_ID}}"
_ACTION="{{ACTION}}"  # record-estimate | record-actual | variance | landed-cost | margin
```

Ask PM if not provided:

> Cost tracking action for order {{ORDER_ID}}:
>
> A) Record estimated costs (from quote)
> B) Record actual costs (from invoices)
> C) Show estimated vs actual variance
> D) Calculate total landed cost
> E) Calculate Rev A margin

### Step 2 — Record Estimate (`record-estimate`)

Record initial estimated costs from rfq-quote output:

```bash
_TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)
_ORDER="{{ORDER_ID}}"
_CATEGORY="{{CATEGORY}}"
_AMOUNT="{{AMOUNT}}"
_PM="{{PM_NAME}}"
_SOURCE_SKILL="{{SOURCE_SKILL}}"

echo '{"ts":"'"$_TS"'","order_id":"'"$_ORDER"'","event":"estimate","category":"'"$_CATEGORY"'","amount":'"$_AMOUNT"',"currency":"USD","source_skill":"'"$_SOURCE_SKILL"'","pm":"'"$_PM"'"}' >> ~/.reva-turbo/state/cost-ledger.jsonl
```

Accept multiple categories in a single call. Log one entry per category.

### Step 3 — Record Actual (`record-actual`)

Record actual cost when invoices or receipts arrive:

```bash
_TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)
echo '{"ts":"'"$_TS"'","order_id":"'"$_ORDER"'","event":"actual","category":"'"$_CATEGORY"'","amount":'"$_AMOUNT"',"currency":"USD","invoice_ref":"'"$_INVOICE_REF"'","source_skill":"'"$_SOURCE_SKILL"'","pm":"'"$_PM"'"}' >> ~/.reva-turbo/state/cost-ledger.jsonl
```

**HITL checkpoint:** If the actual cost for any single category exceeds the estimate by more than 10%:

> **Cost Variance Alert — {{ORDER_ID}}**
>
> Category: {{CATEGORY}}
> Estimated: ${{ESTIMATE}}
> Actual: ${{ACTUAL}}
> Variance: {{VARIANCE_PCT}}% over estimate
>
> This exceeds the 10% variance threshold.
>
> A) Acknowledge and log — no change order needed
> B) Initiate change order — this affects customer pricing
> C) Escalate — need Senior PM review

### Step 4 — Variance Report (`variance`)

Query the ledger and calculate estimated vs actual per category:

```bash
grep '"order_id":"'"$_ORDER_ID"'"' ~/.reva-turbo/state/cost-ledger.jsonl 2>/dev/null
```

Present variance table:

> **Cost Variance — {{ORDER_ID}} — {{PART_DESCRIPTION}}**
>
> | Category | Estimated | Actual | Variance $ | Variance % |
> |----------|-----------|--------|-----------|-----------|
> | partner_quote | ${{EST}} | ${{ACT}} | ${{VAR}} | {{PCT}}% |
> | tooling | ${{EST}} | ${{ACT}} | ${{VAR}} | {{PCT}}% |
> | shipping_intl | ${{EST}} | ${{ACT}} | ${{VAR}} | {{PCT}}% |
> | duties_tariffs | ${{EST}} | ${{ACT}} | ${{VAR}} | {{PCT}}% |
> | ... | ... | ... | ... | ... |
> | **TOTAL** | **${{TOTAL_EST}}** | **${{TOTAL_ACT}}** | **${{TOTAL_VAR}}** | **{{TOTAL_PCT}}%** |
>
> Categories with actuals not yet recorded: {{PENDING_LIST}}

### Step 5 — Landed Cost (`landed-cost`)

Calculate total landed cost including all duties and freight:

```
Landed Cost = partner_quote + tooling + materials + shipping_intl + duties_tariffs + shipping_domestic + inspection + repackage + overhead + other
```

```bash
grep '"order_id":"'"$_ORDER_ID"'"' ~/.reva-turbo/state/cost-ledger.jsonl 2>/dev/null | \
  python3 -c "
import json, sys
records = [json.loads(l) for l in sys.stdin if l.strip()]
totals = {}
for r in records:
    key = r['event']  # estimate or actual
    totals[key] = totals.get(key, 0) + r['amount']
print('Estimated landed cost:', totals.get('estimate', 0))
print('Actual landed cost:', totals.get('actual', 'Not yet complete'))
" 2>/dev/null || echo "Calculate manually from ledger entries above."
```

### Step 6 — Margin (`margin`)

Calculate Rev A margin:

```
Margin % = (Customer Price - Total Landed Cost) / Customer Price × 100
```

```bash
_CUSTOMER_PRICE="{{CUSTOMER_PRICE}}"
_LANDED_COST="{{TOTAL_LANDED_COST}}"
python3 -c "
cp = float('$_CUSTOMER_PRICE')
lc = float('$_LANDED_COST')
margin = (cp - lc) / cp * 100
print(f'Customer price: \${cp:,.2f}')
print(f'Total landed cost: \${lc:,.2f}')
print(f'Gross profit: \${cp-lc:,.2f}')
print(f'Margin: {margin:.1f}%')
" 2>/dev/null || echo "Customer price: \$_CUSTOMER_PRICE | Landed cost: \$_LANDED_COST | Calculate margin manually."
```

If margin is below the minimum threshold (from config or CLIENT.md defaults):

> **Margin Alert — {{ORDER_ID}}**
>
> Calculated margin: {{MARGIN}}%
> Minimum threshold: {{MIN_MARGIN}}%
>
> This order is below the minimum margin threshold.
>
> A) Proceed — I accept lower margin on this order
> B) Review costs — find reduction opportunities
> C) Reprice — generate a revised quote

## State File — Canonical Cost Source

**`~/.reva-turbo/state/cost-ledger.jsonl`** is the **canonical source of truth** for all order cost data in the REVA-TURBO system. This is the definitive cost record. See `skills/revmyengine/references/data-carryover.md` for the full cost data flow and governance rules.

One entry per cost event:
```json
{
  "ts": "ISO8601",
  "po": "PO_NUMBER",
  "type": "estimate|actual|duty|variance|correction",
  "category": "material|manufacturing|tooling|shipping|duty|freight|overhead|other",
  "amount_usd": 1250.00,
  "currency_orig": "CNY",
  "amount_orig": 8750.00,
  "exchange_rate": 7.00,
  "source_skill": "reva-turbo-rfq-quote",
  "note": ""
}
```

**Note:** The `po` field is the canonical PO identifier (maps to `order_id` in legacy records). The `type` field distinguishes estimates from actuals, duties, and corrections. All amounts are in USD (`amount_usd`); store original currency and exchange rate for audit trail.

## Rules

1. **Append-only ledger.** Cost events are never modified or deleted. Corrections are new entries with `"event": "correction"` and a reference to the entry being corrected.
2. **One entry per cost event.** Each cost category gets its own ledger entry when the cost is recorded or revised.
3. **HITL on >10% variance.** Any actual cost that exceeds the estimate by more than 10% on a single category requires PM acknowledgment before proceeding.
4. **Currency is USD.** All amounts are stored in USD. Convert at time of recording if invoice is in CNY or other currency.
5. **Source skill is logged.** Every entry records which REVA-TURBO skill created it — for traceability.

## Lifecycle

**Fed by:** reva-turbo-rfq-quote (estimates), reva-turbo-change-order (revised estimates), reva-turbo-import-compliance (duties), reva-turbo-logistics (freight actuals), reva-turbo-repackage (repackage actuals), reva-turbo-inspect (inspection costs)

**Feeds:** reva-turbo-profit (final margin analysis), reva-turbo-report (cost roll-up in weekly report)

## Report Naming

```
REVA-TURBO-CostReport-{YYYY-MM-DD}-{ORDER_ID}.md
```
