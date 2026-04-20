"""Rev A Manufacturing seed — pipelines, custom-field manifests, tags.

Run once after ``alembic upgrade head`` on a fresh Nakatomi database:

    python -m seed.reva --api-url https://<nakatomi>.railway.internal:8000 \\
                       --admin-email you@reva.com --admin-password ...

Idempotent: re-running updates existing pipelines/fields by name.
"""

from __future__ import annotations

import argparse
import os
import sys
from typing import Any

import httpx

REVA_PIPELINE_NAME = "Manufacturing RFQ"
REVA_STAGES = [
    {"name": "RFQ Received",      "probability": 0.05, "order": 1},
    {"name": "Qualified",         "probability": 0.20, "order": 2},
    {"name": "Quoted",            "probability": 0.35, "order": 3},
    {"name": "Accepted",          "probability": 0.55, "order": 4},
    {"name": "In Manufacturing",  "probability": 0.70, "order": 5},
    {"name": "Inspection (G2)",   "probability": 0.80, "order": 6},
    {"name": "Repackage",         "probability": 0.85, "order": 7},
    {"name": "Shipped",           "probability": 0.90, "order": 8},
    {"name": "Delivered",         "probability": 0.93, "order": 9},
    {"name": "Invoiced",          "probability": 0.96, "order": 10},
    {"name": "Paid",              "probability": 1.00, "order": 11, "is_won": True},
    {"name": "Closed Lost",       "probability": 0.00, "order": 12, "is_lost": True},
]

REVA_CUSTOM_FIELDS: dict[str, list[dict[str, Any]]] = {
    "company": [
        {"key": "partner_scorecard", "type": "object",
         "description": "{on_time_pct, defect_rate, lead_time_days, last_audit_date}"},
        {"key": "compliance", "type": "object",
         "description": "{itar: bool, ear: bool, iso9001: bool, as9100: bool, certs: [str]}"},
        {"key": "region", "type": "string",
         "description": "china | us | mexico | eu | other"},
    ],
    "contact": [
        {"key": "role", "type": "string",
         "description": "buyer | engineering | quality | shipping | finance"},
    ],
    "deal": [
        {"key": "quality_gates", "type": "object",
         "description": "{g1_material, g2_fai, g3_production, g4_shipping} each {status, inspector, date}"},
        {"key": "ncrs", "type": "array",
         "description": "[{id, stage, issue, severity, owner, status, opened_at, resolved_at}]"},
        {"key": "part_numbers", "type": "array",
         "description": "Part numbers in this RFQ/order"},
        {"key": "china_source", "type": "object",
         "description": "{supplier_id, buyer_agent, po_number, port_of_origin}"},
    ],
}

REVA_TAG_VOCABULARY = [
    "reva/rfq", "reva/quality", "reva/compliance", "reva/china-source",
    "reva/partner-scorecard", "reva/ncr", "reva/shipping", "reva/itar",
]


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
        found = next((p for p in existing if p["name"] == REVA_PIPELINE_NAME), None)
        if found:
            print(f"✓ pipeline exists: {REVA_PIPELINE_NAME} ({found['id']})")
            pipeline = found
        else:
            pipeline = self._req("POST", "/pipelines", json={"name": REVA_PIPELINE_NAME})
            print(f"+ pipeline created: {REVA_PIPELINE_NAME} ({pipeline['id']})")

        existing_stages = {s["name"]: s for s in pipeline.get("stages", [])}
        for stage in REVA_STAGES:
            if stage["name"] in existing_stages:
                continue
            self._req("POST", f"/pipelines/{pipeline['id']}/stages", json=stage)
            print(f"  + stage: {stage['name']}")
        return pipeline

    def upsert_custom_fields(self) -> None:
        for entity_type, fields in REVA_CUSTOM_FIELDS.items():
            for field in fields:
                body = {"entity_type": entity_type, **field}
                try:
                    self._req("POST", "/schema/custom-fields", json=body)
                    print(f"  + custom_field {entity_type}.{field['key']}")
                except httpx.HTTPStatusError as exc:
                    if exc.response.status_code == 409:  # already exists
                        print(f"  = custom_field {entity_type}.{field['key']} (exists)")
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
