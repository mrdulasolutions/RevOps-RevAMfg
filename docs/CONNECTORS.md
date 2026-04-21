# Connectors — primary CRM + shadow-writes

REVA-TURBO ships with Nakatomi (CRM) and AutoMem (semantic memory)
bundled under the router's `crm_*` and `mem_*` tool prefixes. That's
the zero-config default — every PM on a fresh signup already has them
working.

Teams that already use a different CRM in Claude Desktop — HubSpot,
Salesforce, Attio, Pipedrive — can make that their **primary system of
record** without losing the shared Rev A timeline. The pattern is:

- **Primary writes go to the external connector** (e.g. HubSpot). That
  record is the source of truth.
- **Every write is also mirrored** to Nakatomi + AutoMem so the Rev A
  team sees the activity on the shared timeline and can search
  semantic memory without depending on the external CRM's uptime.
- **Reads prefer the primary** and fall back to the Nakatomi mirror if
  the primary is unreachable (with a clear "data may be stale" notice).

One setting controls this at the workspace level. Individual PMs don't
choose independently — the team needs to agree on one system of truth.

## The `/integrate` command

```
/integrate                    # show current config + which connectors Desktop has installed
/integrate nakatomi           # revert to bundled default (no shadow-writes)
/integrate hubspot            # HubSpot becomes primary; Nakatomi + AutoMem mirror
/integrate salesforce         # Salesforce becomes primary; …
/integrate attio              # Attio becomes primary; …
/integrate pipedrive          # Pipedrive becomes primary; …
```

Under the hood this calls `mcp__reva__reva_set_primary_crm` which
writes `workspace.data.primary_crm` and an audit trail in
`workspace.data.primary_crm_history` (last 10 flips, with actor email
and timestamps). Only the admin token can PATCH `/workspace`, so the
router escalates on the caller's behalf after verifying their
identity.

## Supported connectors

The registry lives in `workspace.data.connector_registry`, seeded by
`services/nakatomi-backend/seed/reva.py`. Each entry has:

| Field             | Purpose                                                        |
|-------------------|----------------------------------------------------------------|
| `slug`            | Identifier used with `/integrate <slug>` and in shadow-write source tags |
| `display`         | Human-readable name shown in `/integrate` output               |
| `mcp_tool_prefix` | How skills detect whether Desktop has the connector installed  |
| `bundled`         | `true` only for Nakatomi — the router exposes it natively      |
| `primary_compatible` | `true` if the connector can hold the system of record (today all are) |

Defaults shipped at seed time:

| Slug         | Display              | Prefix       | Install path                                |
|--------------|----------------------|--------------|---------------------------------------------|
| `nakatomi`   | Nakatomi (bundled)   | `crm_`       | automatic via the router                    |
| `hubspot`    | HubSpot              | `hubspot_`   | Desktop → Settings → Connectors → HubSpot   |
| `salesforce` | Salesforce           | `sf_`        | Desktop → Settings → Connectors → Salesforce |
| `attio`      | Attio                | `attio_`     | Desktop → Settings → Connectors → Attio     |
| `pipedrive`  | Pipedrive            | `pipedrive_` | Desktop → Settings → Connectors → Pipedrive |

Adding a new connector to the registry is a one-line seed change —
append an entry to `REVA_CONNECTOR_REGISTRY` in
`services/nakatomi-backend/seed/reva.py`, re-run `./railway/deploy.sh
seed`, and the `/integrate` picker picks it up automatically.

## The shadow-write contract

Any skill that writes a customer, contact, deal, note, activity,
task, or pipeline change MUST implement this four-step sequence:

### 1. Primary write

Resolve the primary CRM for the workspace:

```
cfg = read ~/.reva-turbo/state/workspace-config.json
primary = cfg.primary_crm  # e.g. "hubspot"
```

If `primary == "nakatomi"`, go straight to the bundled tools — no
mirroring needed, Nakatomi IS the primary.

Otherwise, call the external connector's MCP tools. Example for
HubSpot (`mcp_tool_prefix: hubspot_`):

```
mcp__hubspot__hubspot_create_contact {
  email: "jane@acme.com",
  firstname: "Jane",
  lastname: "Doe"
}
→ returns hubspot_id: "1234567"
```

### 2. Shadow-write to Nakatomi

Re-issue the same logical write through the router's `crm_*` tools,
tagging the source and external ID so future reads can reconcile:

```
mcp__reva__crm_create_contact {
  email: "jane@acme.com",
  first_name: "Jane",
  last_name: "Doe",
  properties: {
    source: "hubspot",
    source_id: "1234567"
  }
}
→ returns nakatomi_id: "c_abc123"
```

The `source`/`source_id` pair is the reconciliation key. If HubSpot's
contact is later mutated (primary write), the next shadow-write should
look up the Nakatomi record by `(source, source_id)` and update it
rather than creating a duplicate.

### 3. Memory write

Always store semantic memory against the Nakatomi ID — AutoMem's graph
stays consistent regardless of which external CRM is primary:

```
mcp__reva__reva_remember_about_entity {
  entity_type: "contact",
  entity_id: "c_abc123",          # Nakatomi ID from step 2
  content: "Jane is the buyer for the Q3 RFQ — prefers email, hates calls.",
  tags: ["reva/rfq", "source:hubspot"]
}
```

This way, memories are searchable by the Rev A team even if HubSpot
goes down, and they're linked to both systems via the `source` tag.

### 4. Return the primary's record to the PM

When presenting back to the PM, use data from the **primary** write
(step 1), not the Nakatomi shadow. "Look up Acme Corp" should show
the HubSpot Acme Corp, not a stale mirror. The Nakatomi record is
infrastructure — the PM shouldn't see it unless HubSpot is unreachable.

## Read path

Reads prefer the primary connector:

```
if primary == "nakatomi":
    mcp__reva__crm_search_contacts {...}
elif primary == "hubspot" and hubspot tools available:
    mcp__hubspot__hubspot_search_contacts {...}
elif primary == "hubspot" and hubspot tools MISSING:
    # warn PM, fall back
    mcp__reva__crm_search_contacts {...}
    tell PM: "HubSpot is unreachable — showing the Rev A mirror from
             Nakatomi. Data may be up to 5 min behind the primary."
```

Skills detect connector availability by checking whether any tool in
the current surface starts with the registry's `mcp_tool_prefix`.

## Failure modes

- **Primary write succeeds, shadow-write fails.** The record is in
  HubSpot but not in Nakatomi. Log the failure to
  `~/.reva-turbo/state/shadow-write-failures.jsonl` and surface it in
  `/connected`. A later skill invocation or `/refresh` can replay
  pending shadow-writes. Never fail the PM's ask just because the
  mirror is slow.
- **Primary write fails.** Hard-fail — tell the PM, don't shadow-write
  anything (that would create a Nakatomi record that has no HubSpot
  counterpart, breaking the reconciliation contract).
- **Memory write fails.** Log and continue — memory is best-effort,
  not authoritative.

## Why workspace-level and not per-user

Two PMs disagreeing on primary CRM would create a split-brain: Jane
writes to HubSpot, Tom writes to Nakatomi, shadow-writes collide on
the reconciliation key. The workspace-level setting forces the team to
agree on one system of truth — `/integrate` changes it for everyone.
The `primary_crm_history` audit log in `workspace.data` tells you who
flipped it and when.

## Not (yet) supported

- **Read-only observer connectors** — the `primary_compatible: false`
  flag is reserved for future "see-only" integrations (e.g. Gmail for
  email ingestion — shouldn't be the primary, but skills can read from
  it). Today every registered connector is primary-compatible.
- **Cross-connector reconciliation.** If you flip from HubSpot →
  Salesforce mid-workflow, existing Nakatomi shadows still reference
  `source: hubspot`. They don't auto-migrate. Reconciliation is a
  future feature — for now, run a one-off backfill.
- **Per-entity-type primary overrides** (e.g. "contacts from HubSpot,
  deals from Nakatomi"). Today primary is workspace-wide for all
  entity types. Multi-primary routing could be added to the registry
  entry as an `entity_types: ["contact", "company"]` allowlist.
