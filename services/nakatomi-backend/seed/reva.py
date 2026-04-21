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

    def run(self) -> None:
        print(f"Seeding Rev A schema against {self.base_url}")
        self.upsert_pipeline()
        print("Custom fields:")
        self.upsert_custom_fields()
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
