"""Rev A Manufacturing seed — pipelines, custom-field manifests, tags.

Run once after ``alembic upgrade head`` on a fresh Nakatomi database:

    python reva.py --api-url http://localhost:8000 --token nk_...

Idempotent: re-running is a no-op for existing pipelines/fields (matched by
slug / (entity_type, name)).

Schema notes — Nakatomi's API:
  * POST /pipelines takes ``{name, slug, stages: [StageIn, ...]}`` — stages
    are created inline, there is no /pipelines/{id}/stages route.
  * StageIn = ``{name, slug, position, probability, is_won, is_lost}``.
  * POST /custom-fields takes CustomFieldIn = ``{entity_type, name, label,
    field_type, description}``. Allowed field_type values:
    string|text|number|bool|date|url|email|select. No ``object`` / ``array``
    — we encode structured payloads as ``text`` (client parses JSON).
"""

from __future__ import annotations

import argparse
import os
import re
import sys
from typing import Any

import httpx

REVA_PIPELINE_SLUG = "manufacturing-rfq"
REVA_PIPELINE_NAME = "Manufacturing RFQ"

# (name, probability, is_won, is_lost) — position is derived from order.
REVA_STAGES: list[dict[str, Any]] = [
    {"name": "RFQ Received",     "probability": 0.05},
    {"name": "Qualified",        "probability": 0.20},
    {"name": "Quoted",           "probability": 0.35},
    {"name": "Accepted",         "probability": 0.55},
    {"name": "In Manufacturing", "probability": 0.70},
    {"name": "Inspection (G2)",  "probability": 0.80},
    {"name": "Repackage",        "probability": 0.85},
    {"name": "Shipped",          "probability": 0.90},
    {"name": "Delivered",        "probability": 0.93},
    {"name": "Invoiced",         "probability": 0.96},
    {"name": "Paid",             "probability": 1.00, "is_won": True},
    {"name": "Closed Lost",      "probability": 0.00, "is_lost": True},
]

# (entity_type, name, label, field_type, description).
# Nakatomi's field_type set is scalar-only; object/array payloads ride as
# ``text`` (JSON-encoded).
REVA_CUSTOM_FIELDS: list[dict[str, Any]] = [
    {"entity_type": "company", "name": "partner_scorecard", "label": "Partner Scorecard",
     "field_type": "text",
     "description": "JSON: {on_time_pct, defect_rate, lead_time_days, last_audit_date}"},
    {"entity_type": "company", "name": "compliance", "label": "Compliance",
     "field_type": "text",
     "description": "JSON: {itar, ear, iso9001, as9100, certs:[str]}"},
    {"entity_type": "company", "name": "region", "label": "Region",
     "field_type": "string",
     "description": "china | us | mexico | eu | other"},
    {"entity_type": "contact", "name": "role", "label": "Role",
     "field_type": "string",
     "description": "buyer | engineering | quality | shipping | finance"},
    {"entity_type": "deal", "name": "quality_gates", "label": "Quality Gates",
     "field_type": "text",
     "description": "JSON: {g1_material, g2_fai, g3_production, g4_shipping}"},
    {"entity_type": "deal", "name": "ncrs", "label": "NCRs",
     "field_type": "text",
     "description": "JSON array: [{id,stage,issue,severity,owner,status,...}]"},
    {"entity_type": "deal", "name": "part_numbers", "label": "Part Numbers",
     "field_type": "text",
     "description": "Comma-separated or JSON array of part numbers"},
    {"entity_type": "deal", "name": "china_source", "label": "China Source",
     "field_type": "text",
     "description": "JSON: {supplier_id, buyer_agent, po_number, port_of_origin}"},
]

REVA_TAG_VOCABULARY = [
    "reva/rfq", "reva/quality", "reva/compliance", "reva/china-source",
    "reva/partner-scorecard", "reva/ncr", "reva/shipping", "reva/itar",
]

# ---------------------------------------------------------------------------
# Company profile — lives in ``workspace.data.company_profile``. The router
# exposes this via ``reva_get_company_profile`` so every PM's plugin pulls
# the same source-of-truth on first run and never has to re-enter the
# company name, leadership, partners, or escalation matrix locally.
#
# `memory_taxonomy`, `role_skill_map`, `escalation_matrix`, and `partners`
# sit next to `company_profile` (under `workspace.data`) because the router's
# `reva_get_workspace_config` tool surfaces them together.
# ---------------------------------------------------------------------------

REVA_COMPANY_PROFILE: dict[str, Any] = {
    "legal_name": "Rev A Manufacturing",
    "short_name": "Rev A Mfg",
    "website": "https://www.revamfg.com",
    "industry": "Contract manufacturing",
    "business_model": (
        "Receive RFQ → Qualify → Quote → Send specs to China partners → "
        "Receive goods → Inspect/Repackage → Ship to customer"
    ),
    "capabilities": [
        "Production machining (CNC milling, turning, multi-axis)",
        "Injection tooling & molding",
        "Prototyping / 3D printing / short-run",
        "Sheet metal (laser, bending, welding)",
        "Finishing (anodize, plate, powder coat, paint)",
        "Assembly, sub-assembly, kitting, packaging",
    ],
    "leadership": [
        {"name": "Donovan Weber", "role": "President & Co-founder",
         "escalation_default": True},
    ],
    "pm_team": [
        {"name": "Ray Yeh",      "role": "Senior Project Manager"},
        {"name": "Harley Scott", "role": "Senior Project Manager"},
    ],
    "business_development": [
        {"name": "Matt Nebo",    "role": "Director of Business Development", "region": "West Coast"},
        {"name": "Barry Coyle",  "role": "Director of Business Development", "region": "Midwest"},
        {"name": "Bryce Martel", "role": "Director of Business Development", "region": "East Coast"},
        {"name": "Ryan Knight",  "role": "Business Development"},
    ],
    "report_prefix": "REVA-TURBO",
    "report_naming": "REVA-TURBO-{Type}-{YYYY-MM-DD}-{ShortName}.docx",
}

REVA_ESCALATION_MATRIX: list[dict[str, str]] = [
    {"issue": "Quality issue",         "first": "Senior PM (Ray Yeh / Harley Scott)", "second": "Donovan Weber"},
    {"issue": "Delivery delay (>2wk)", "first": "Senior PM",                          "second": "Donovan Weber"},
    {"issue": "Customer complaint",    "first": "Senior PM",                          "second": "Donovan Weber"},
    {"issue": "New capability request","first": "BD Director (regional)",             "second": "Donovan Weber"},
    {"issue": "Payment / credit",      "first": "Senior PM",                          "second": "Donovan Weber"},
    {"issue": "Legal / contractual",   "first": "Donovan Weber (direct)",             "second": ""},
]

# Role → which skill subset to surface on the PM's dashboard on first run.
# Roles not listed fall back to ``pm`` (the full workflow).
REVA_ROLE_SKILL_MAP: dict[str, list[str]] = {
    "pm": [
        "reva-turbo-rfq-intake", "reva-turbo-rfq-qualify", "reva-turbo-rfq-quote",
        "reva-turbo-china-package", "reva-turbo-china-track",
        "reva-turbo-inspect", "reva-turbo-quality-gate", "reva-turbo-ncr",
        "reva-turbo-logistics", "reva-turbo-customer-comms",
        "reva-turbo-dashboard", "reva-turbo-order-track", "reva-turbo-escalate",
    ],
    "sales": [
        "reva-turbo-rfq-intake", "reva-turbo-rfq-qualify", "reva-turbo-rfq-quote",
        "reva-turbo-customer-profile", "reva-turbo-customer-comms",
        "reva-turbo-customer-gate", "reva-turbo-dashboard", "reva-turbo-intel",
    ],
    "compliance": [
        "reva-turbo-export-compliance", "reva-turbo-import-compliance",
        "reva-turbo-isf-filing", "reva-turbo-audit-trail",
        "reva-turbo-rules", "reva-turbo-dashboard",
    ],
    "clevel": [
        "reva-turbo-dashboard", "reva-turbo-pulse", "reva-turbo-intel",
        "reva-turbo-profit", "reva-turbo-report", "reva-turbo-escalate",
    ],
    "eng": [
        "reva-turbo-rfq-qualify", "reva-turbo-china-package",
        "reva-turbo-inspect", "reva-turbo-quality-gate", "reva-turbo-ncr",
        "reva-turbo-change-order", "reva-turbo-partner-master",
    ],
}

REVA_MEMORY_TAXONOMY: list[dict[str, str]] = [
    {"tag": "reva/rfq",               "purpose": "Incoming RFQs, scope, targets"},
    {"tag": "reva/quality",           "purpose": "Gate outcomes, inspection notes"},
    {"tag": "reva/compliance",        "purpose": "EAR/ITAR/HTS rulings and docs"},
    {"tag": "reva/china-source",      "purpose": "Supplier decisions, buyer-agent notes"},
    {"tag": "reva/partner-scorecard", "purpose": "Partner quality / delivery / rate changes"},
    {"tag": "reva/ncr",               "purpose": "Non-conformance records and RCAs"},
    {"tag": "reva/shipping",          "purpose": "Freight, customs, ISF, delivery notes"},
    {"tag": "reva/itar",              "purpose": "ITAR-specific findings (maximum scrutiny)"},
]

# Connector registry — which external CRMs can be set as the team's
# primary system of record via `reva_set_primary_crm` / `/integrate`.
# Each entry describes how skills can *detect* whether the PM already
# has that connector wired into Claude Desktop (by looking for tools
# whose names start with `mcp_tool_prefix`). Adding an entry here
# unlocks /integrate <slug>; it does NOT install anything — the PM
# still has to add the connector in Desktop → Settings → Connectors.
#
# `bundled: true` means the router ships this connector natively (no
# external Desktop setup needed). `primary_compatible` is a belt-and-
# suspenders flag for future read-only/observer integrations — today
# all entries can be primary.
REVA_CONNECTOR_REGISTRY: list[dict[str, Any]] = [
    {
        "slug": "nakatomi",
        "display": "Nakatomi (bundled)",
        "mcp_tool_prefix": "crm_",
        "bundled": True,
        "primary_compatible": True,
        "notes": "Default. Shipped with the router — every PM has this.",
    },
    {
        "slug": "hubspot",
        "display": "HubSpot",
        "mcp_tool_prefix": "hubspot_",
        "primary_compatible": True,
        "notes": "Install HubSpot connector in Desktop → Settings → Connectors first.",
    },
    {
        "slug": "salesforce",
        "display": "Salesforce",
        "mcp_tool_prefix": "sf_",
        "primary_compatible": True,
        "notes": "Install Salesforce connector in Desktop → Settings → Connectors first.",
    },
    {
        "slug": "attio",
        "display": "Attio",
        "mcp_tool_prefix": "attio_",
        "primary_compatible": True,
        "notes": "Install Attio connector in Desktop → Settings → Connectors first.",
    },
    {
        "slug": "pipedrive",
        "display": "Pipedrive",
        "mcp_tool_prefix": "pipedrive_",
        "primary_compatible": True,
        "notes": "Install Pipedrive connector in Desktop → Settings → Connectors first.",
    },
]

# Which connector is the team's system of record. Reads prefer the
# primary CRM when available; writes go to the primary first, then
# shadow-write to Nakatomi + AutoMem so the shared Rev A timeline
# still sees everything. Per-workspace, not per-user — the team needs
# to agree on one system of truth.
REVA_DEFAULT_PRIMARY_CRM: str = "nakatomi"


def _slug(name: str) -> str:
    return re.sub(r"[^a-z0-9]+", "-", name.lower()).strip("-")


class NakatomiSeeder:
    def __init__(self, base_url: str, token: str):
        self.base_url = base_url.rstrip("/")
        self.token = token
        self.headers = {"Authorization": f"Bearer {token}"}

    def _req(self, method: str, path: str, json: Any = None, params: Any = None) -> Any:
        with httpx.Client(timeout=30) as client:
            r = client.request(
                method, f"{self.base_url}{path}",
                headers=self.headers, json=json, params=params,
            )
            if r.status_code >= 400:
                sys.stderr.write(f"{method} {path} -> {r.status_code}: {r.text}\n")
                r.raise_for_status()
            return r.json() if r.content else None

    def upsert_pipeline(self) -> dict:
        existing = self._req("GET", "/pipelines") or []
        found = next((p for p in existing if p.get("slug") == REVA_PIPELINE_SLUG), None)
        if found:
            print(f"= pipeline exists: {REVA_PIPELINE_NAME} ({found['id']}, {len(found.get('stages', []))} stages)")
            return found

        stages_payload = [
            {
                "name": s["name"],
                "slug": _slug(s["name"]),
                "position": i,
                "probability": s.get("probability", 0),
                "is_won": s.get("is_won", False),
                "is_lost": s.get("is_lost", False),
            }
            for i, s in enumerate(REVA_STAGES)
        ]
        pipeline = self._req(
            "POST", "/pipelines",
            json={
                "name": REVA_PIPELINE_NAME,
                "slug": REVA_PIPELINE_SLUG,
                "is_default": True,
                "stages": stages_payload,
            },
        )
        print(f"+ pipeline created: {REVA_PIPELINE_NAME} ({pipeline['id']}, {len(pipeline.get('stages', []))} stages)")
        return pipeline

    def upsert_custom_fields(self) -> None:
        existing = self._req("GET", "/custom-fields") or []
        key = lambda f: (f.get("entity_type"), f.get("name"))
        have = {key(f) for f in existing}
        for field in REVA_CUSTOM_FIELDS:
            if (field["entity_type"], field["name"]) in have:
                print(f"  = custom_field {field['entity_type']}.{field['name']} (exists)")
                continue
            try:
                self._req("POST", "/custom-fields", json=field)
                print(f"  + custom_field {field['entity_type']}.{field['name']}")
            except httpx.HTTPStatusError as exc:
                if exc.response.status_code in (400, 409):
                    print(f"  = custom_field {field['entity_type']}.{field['name']} (exists)")
                else:
                    raise

    def upsert_workspace_profile(self) -> None:
        """Publish the Rev A company profile + config into ``workspace.data``.

        Non-destructive: preserves any other keys (e.g. ``user_roles`` that
        PMs write via ``reva_set_user_role``).
        """
        ws = self._req("GET", "/workspace") or {}
        data = dict(ws.get("data") or {})
        data["company_profile"] = REVA_COMPANY_PROFILE
        data["escalation_matrix"] = REVA_ESCALATION_MATRIX
        data["role_skill_map"] = REVA_ROLE_SKILL_MAP
        data["memory_taxonomy"] = REVA_MEMORY_TAXONOMY
        data["connector_registry"] = REVA_CONNECTOR_REGISTRY
        # Leave partners alone if already populated — they're PM-editable.
        data.setdefault("partners", [])
        # Only set primary_crm if not already chosen — don't clobber an
        # admin's /integrate decision on re-seed.
        data.setdefault("primary_crm", REVA_DEFAULT_PRIMARY_CRM)
        self._req("PATCH", "/workspace", json={"data": data})
        print(
            f"+ workspace.data published: company_profile, escalation_matrix "
            f"({len(REVA_ESCALATION_MATRIX)}), role_skill_map "
            f"({len(REVA_ROLE_SKILL_MAP)} roles), memory_taxonomy "
            f"({len(REVA_MEMORY_TAXONOMY)} tags), connector_registry "
            f"({len(REVA_CONNECTOR_REGISTRY)} options, primary={data['primary_crm']})"
        )

    def run(self) -> None:
        print(f"Seeding Rev A schema against {self.base_url}")
        self.upsert_pipeline()
        print("Custom fields:")
        self.upsert_custom_fields()
        print("Workspace profile:")
        self.upsert_workspace_profile()
        print("Tag vocabulary (advisory — Nakatomi allows any tag):")
        for t in REVA_TAG_VOCABULARY:
            print(f"  • {t}")
        print("\n✓ seed complete")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--api-url", default=os.environ.get("NAKATOMI_URL"))
    parser.add_argument("--token", default=os.environ.get("NAKATOMI_API_KEY"))
    args = parser.parse_args()
    if not args.api_url or not args.token:
        sys.stderr.write("error: --api-url and --token (or env NAKATOMI_URL / NAKATOMI_API_KEY) required\n")
        return 2
    NakatomiSeeder(args.api_url, args.token).run()
    return 0


if __name__ == "__main__":
    sys.exit(main())
