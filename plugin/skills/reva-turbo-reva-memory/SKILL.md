---
name: reva-turbo-reva-memory
preamble-tier: 1
version: 1.0.0
description: |
  Long-term memory for REVA-TURBO. Speaks to the REVA MCP router (same
  endpoint as the CRM skill — one connector for both). Stores decisions,
  patterns, preferences, and institutional knowledge across the whole
  PM team. Prefer this over local notes: everything here is durable,
  searchable, and cross-user.
compatibility: Claude Code, Claude desktop, Claude CoWork
recommendedModel: claude-opus-4-6
allowed-tools:
  - Bash
  - Read
  - AskUserQuestion
---

## When to use this skill

- **Decisions** — "We quote Chinese-source parts at 2.3× landed cost."
  Store as `type: Decision`, tag `reva/pricing`.
- **Patterns** — "Acme always changes tolerance on rev B drawings."
  `type: Pattern`, tag with customer + `reva/drawings`.
- **Preferences** — "Bob from QA wants every NCR cc'd to him."
  `type: Preference`, linked to his contact via `reva_remember_about_entity`.
- **Style** — "Quote emails to aerospace customers start with the part number."
  `type: Style`, tag `reva/quote-tone`.
- **Habits** — "We always inspect SKU-77 at receipt, not post-finish."
  `type: Habit`.
- **Insights** — "NCRs on porosity correlate with Shanghai supplier S-4."
  `type: Insight`.
- **Context** — everything else worth remembering that isn't a first-class
  CRM field. Default to this type if unsure.

## When NOT to use this skill

- ❌ Structured CRM data (companies, contacts, deals, activities, tasks) —
  use `reva-turbo-reva-crm` instead. Memory is for *things we learned*,
  not records.
- ❌ Secrets, API keys, credentials — AutoMem is not an encrypted vault.
- ❌ One-off chit-chat ("ok thanks") — noise pollutes recall.

## Tool namespace (from the router)

All memory tools are prefixed `mem_`:

- `mem_store` — write a memory (content + type + tags + importance)
- `mem_recall` — hybrid semantic/keyword search, with time and tag filters
- `mem_associate` — create a typed edge between two memories
- `mem_update`, `mem_delete`
- `mem_health` — debug only

Cross-system:
- `reva_remember_about_entity` — memory + auto-link to a CRM entity
- `reva_recall_for_entity` — recall scoped to one CRM entity

## Tagging convention for Rev A

Always include at least one `reva/*` tag so recalls can be scoped:

| Tag                      | When to use                                       |
|--------------------------|---------------------------------------------------|
| `reva/rfq`               | Anything about an incoming quote request         |
| `reva/quality`           | FAI results, NCRs, gate outcomes                 |
| `reva/compliance`        | ITAR/EAR rulings, certifications, audits         |
| `reva/china-source`      | Supplier selection, agent notes, port logistics  |
| `reva/partner-scorecard` | Supplier performance trends                      |
| `reva/pricing`           | Quote assumptions, markup rules                  |
| `reva/shipping`          | Carrier prefs, incoterms, damage incidents       |
| `reva/itar`              | Specifically ITAR-controlled context             |

When a memory is about a specific entity, ALWAYS use
`reva_remember_about_entity` instead of bare `mem_store`. That call
auto-adds `{entity_type}:{entity_id}` and `reva-crm` tags AND writes a
`MemoryLink` on the Nakatomi side so the memory surfaces in the entity's
timeline.

## Importance scale

- `0.9+` — company-wide policy, compliance rulings, repeat customer
  preferences. Will be protected from consolidation decay.
- `0.7` — strong patterns, multi-deal insights.
- `0.5` — default. Use this unless you have a reason not to.
- `0.3` — speculative, single-incident observations.
- `<0.3` — probably don't store.

## Recall recipes

**"Catch me up on Acme before the 9am":**
```
reva_recall_for_entity(entity_type="company", entity_id="<acme-id>",
                       query="recent decisions and NCRs", limit=20)
```

**"What did we decide about ITAR parts from Asian suppliers?":**
```
mem_recall(query="ITAR parts asian suppliers",
           tags=["reva/compliance", "reva/china-source"], tag_mode="any",
           context_types=["Decision"], limit=10)
```

**"Everything quality-related this quarter":**
```
mem_recall(query=None, tags=["reva/quality"], time_query="this quarter",
           sort="time_desc", limit=50)
```

## Association patterns

When you store a memory that flows from another one, call `mem_associate`
immediately:

- A Decision that replaces an older one → `EVOLVED_INTO` (strength 0.9)
- An Insight that explains a Pattern → `SUPPORTS` (strength 0.8)
- A Decision contradicted by new data → `CONTRADICTS` (strength 0.9) — do
  NOT delete the old one; the graph needs the trace.

## Anti-patterns

- ❌ Storing the raw text of a document without `type: Document` (use the
  document upload path in AutoMem — not currently exposed via the router;
  fall back to `mem_store` with `type: Context` and a summary).
- ❌ Massive importance values (`importance: 1.0`) as a shortcut to pin
  something — instead, use the `reva/policy` tag so policy memories are
  findable by query.
- ❌ Mixing entity scopes in one memory ("Acme and Beta Corp both…") —
  write two memories and associate them with `RELATES_TO`.
