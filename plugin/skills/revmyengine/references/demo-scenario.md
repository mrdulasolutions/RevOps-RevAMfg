# `/demo` sample scenario — NexGen Aerospace bracket RFQ

The canonical demo dataset. Used by `/demo dry` and `/demo live`. Every
record created in `live` mode carries `source: "reva-demo"` and a
`reva-demo` tag so `/demo clean` can remove them in one sweep without
touching real data.

## Cast of characters (all fictional)

### Customer
- **Company:** NexGen Aerospace Systems, Inc.
- **Slug:** `nexgen-aerospace-demo`
- **Website:** `https://nexgen-aerospace.example`  *(reserved TLD — never resolves)*
- **Billing address:** 1400 Innovation Way, Suite 300, Irvine, CA 92618
- **Credit terms (target):** Net 30
- **Industry:** Commercial aerospace subsystems
- **Classification:** Commercial (no ITAR / EAR99 on this part)

### Primary contact
- **Name:** Sarah Chen
- **Title:** Senior Sourcing Manager
- **Email:** `sarah.chen@nexgen-aerospace.example`
- **Phone:** +1 (949) 555-0142
- **Role in deal:** decision maker

### Supporting contacts
- **Mark Rodriguez**, Mechanical Engineer — `mark.rodriguez@nexgen-aerospace.example` *(technical)*
- **Priya Patel**, AP Specialist — `priya.patel@nexgen-aerospace.example` *(billing)*

### China partner (for partner-select stage)
- **Name:** Shenzhen Precision CNC Co., Ltd.
- **Slug:** `shenzhen-precision-demo`
- **Capability:** CNC milling / turning up to Ra 0.8, ±0.02mm
- **Scorecard (fictional rolling 12-month):** 94% on-time, 98.2% first-pass yield, 4.6/5 comms
- **MOQ:** 100 units
- **Typical lead time:** 5 weeks door-to-door (3w production + 2w freight)

## The RFQ

- **ID:** `RFQ-DEMO-0001`
- **Subject line (as received):** *"RFQ — Mounting bracket, P/N NX-BRK-4471, qty 500"*
- **Received:** Monday 09:12 via `rfq@revamfg.com`
- **Part number:** NX-BRK-4471 (customer's PN)
- **Description:** CNC-machined mounting bracket, 6061-T6 aluminum, clear Type II anodize
- **Quantity:** 500 units (firm order) + 1,000 unit/yr forecast
- **Target unit price:** $18 – $25
- **Target lead time:** 8 weeks from PO
- **Tolerances:** ±0.02mm on critical features, Ra 0.8 on mating surfaces
- **Drawing:** `NX-BRK-4471_rev_C.pdf` (referenced; not attached in demo)
- **Compliance:** Commercial — no ITAR, no export-controlled tech data
- **Quality reqs:** CoC + dimensional report (AQL 1.0) per lot; first-article inspection

## Expected quote (what the engine will produce in dry mode)

| Component | Per-unit |
|---|---|
| Material (6061-T6 billet, ~0.9 lb) | $2.80 |
| CNC time (22 min @ China partner rate) | $6.20 |
| Tooling amortization (over 500 units) | $1.40 |
| Anodize + mask | $1.90 |
| Inspection + CoC | $0.60 |
| Freight allocation (air consol) | $0.85 |
| Packaging | $0.35 |
| **Partner landed cost** | **$14.10** |
| Rev A margin @ 37% | $8.30 |
| **Customer unit price** | **$22.40** |

- **Line total:** $11,200 (500 × $22.40)
- **Quoted lead time:** 7 weeks (1w Rev A prep + 3w China production + 2w freight + 1w inspect/ship)
- **Quote validity:** 30 days
- **Expected win probability:** 68% (mid-budget, tight-but-achievable lead time, prior vendor issues on 2 quotes)

## 14-stage narration track

Each stage below has: the skill that fires, the one-line outcome, and
the record(s) created in `live` mode. PMs reading the output should
understand what the engine *is doing*, not just what it's saying.

| # | Stage | Skill | Outcome | Live-mode record |
|---|---|---|---|---|
| 1 | RFQ Intake | `reva-turbo-rfq-intake` | Parse email → structured RFQ object | `rfq` object created, tagged `reva-demo` |
| 2 | RFQ Qualify | `reva-turbo-rfq-qualify` | New customer + capability match + complexity 3/5 → **PROCEED** | `rfq` updated: `qualification="proceed"` |
| 3 | Customer Onboarding | `reva-turbo-customer-profile` | New account NexGen Aerospace + primary contact Sarah | `account` + `contact` created |
| 4 | Quote Generation | `reva-turbo-rfq-quote` | Build line item, margin calc, lead time → $22.40/unit | `quote` draft created |
| 5 | Quote Submission | `reva-turbo-customer-comms` | Compose cover email + quote PDF | `communication` record drafted (not sent in demo) |
| 6 | Order Acceptance | — | Simulate PO receipt → mark quote accepted | `order` created, `quote.status="accepted"` |
| 7 | Manufacturing Package | `reva-turbo-china-package` | Bundle drawings + translation notes + IP marks | `manufacturing_package` asset created |
| 8 | Partner Select | `reva-turbo-partner-select` | Score 3 candidates → Shenzhen Precision wins | `partner_award` record |
| 9 | Manufacturing Tracking | `reva-turbo-china-track` | 10-milestone schedule, stubs for progress pings | `production_job` with milestones |
| 10 | Shipping (CN→US) | `reva-turbo-logistics` | Book freight, generate shipping docs | `shipment` record |
| 11 | Incoming Inspection | `reva-turbo-inspect` | Sample AQL 1.0, dimensional + anodize check | `inspection` record (outcome: **ACCEPT**) |
| 12 | Quality Gate | `reva-turbo-quality-gate` | Final verification + CoC assembly | `qa_gate` record |
| 13 | Outbound Ship | `reva-turbo-order-track` | Domestic ground to Irvine, tracking pushed to Sarah | `outbound_shipment` record |
| 14 | Order Close | `reva-turbo-audit-trail` | T+3 satisfaction check stub, final audit summary | `order.status="closed"` + audit entry |

## Demo tagging conventions (live mode)

Every write MUST include these fields — no exceptions — so `/demo
clean` can reliably remove everything:

```json
{
  "source": "reva-demo",
  "tags": ["reva-demo", "reva-demo-0001"],
  "metadata": {
    "demo_run_id": "<ISO-8601 start timestamp>",
    "demo_operator": "<PM email or display_name>"
  }
}
```

Records in AutoMem get an associated memory with tag `reva-demo` for
symmetric cleanup.

## Cleanup (`/demo clean`)

1. Call `crm_search` with `{"filters": {"tag": "reva-demo"}}` across
   accounts / contacts / rfqs / quotes / orders / shipments / etc.
2. For each returned record, call the matching `crm_*_delete` tool.
3. `mem_recall` with `{"tags": ["reva-demo"]}` → `mem_delete` each.
4. Report: "Removed N records (M accounts, O contacts, P RFQs, …)"

If any delete errors, stop and report — don't leave the workspace
half-cleaned. The PM can re-run `/demo clean` to retry; delete calls
are idempotent on already-gone records.

## Non-negotiables

- **No real customer lookalikes.** All company names / domains use the
  `.example` TLD (RFC 6761 reserved — never resolves) so nothing can
  leak into a real CRM.
- **Never send the drafted email.** Stage 5 drafts a communication but
  the `send` call is always skipped, even in `live` mode.
- **Default to dry.** If the PM types plain `/demo`, ask once:
  *"Dry run (narrate only — no CRM writes) or Live (creates tagged
  demo records so you can see them in the dashboard)?"* — then obey.
