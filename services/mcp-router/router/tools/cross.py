"""Cross-system tools — CRM × memory in a single call.

These are the reason we run a router (instead of two independent MCPs):
orchestrate Nakatomi + AutoMem together so agents can think in terms of
the Rev A workflow rather than the underlying systems.

A few tools here (``reva_set_user_role``) need to mutate workspace-scoped
state that Nakatomi only lets ``owner``/``admin`` role tokens touch. For
those, we route through the router's admin token (``NAKATOMI_ADMIN_TOKEN``)
after identifying the caller with their own token. Regular PMs therefore
never need admin creds to record their role — the router is the authority.
"""

from __future__ import annotations

import os
from typing import Any

from mcp.server.fastmcp import Context, FastMCP

from ..auth import token_from_ctx
from ..config import settings
from ..upstream import AutoMemClient, NakatomiClient


def _admin_token() -> str:
    tok = os.environ.get("NAKATOMI_ADMIN_TOKEN", "")
    if not tok:
        raise RuntimeError(
            "NAKATOMI_ADMIN_TOKEN is not set on the router — this workspace-"
            "privileged call requires it. Ask your admin to set it."
        )
    return tok


def register(mcp: FastMCP) -> None:
    nakatomi = NakatomiClient()
    automem = AutoMemClient()

    @mcp.tool(name="reva_remember_about_entity")
    async def remember_about_entity(
        ctx: Context,
        entity_type: str,  # contact | company | deal
        entity_id: str,
        content: str,
        memory_type: str = "Context",
        tags: list[str] | None = None,
        importance: float | None = None,
    ) -> dict:
        """Store a memory and link it to a CRM entity.

        Writes the memory in AutoMem, then records a ``MemoryLink`` on the
        Nakatomi entity so the memory surfaces on the entity's timeline.
        """
        token = token_from_ctx(ctx)

        # 1. Get workspace context so we can scope memory tags consistently.
        tag_list = list(tags or [])
        tag_list.extend([f"{entity_type}:{entity_id}", "reva-crm"])

        # 2. Store in AutoMem
        mem_body: dict[str, Any] = {
            "content": content,
            "type": memory_type,
            "tags": tag_list,
            "metadata": {
                "entity_type": entity_type,
                "entity_id": entity_id,
                "source": "reva-mcp-router",
            },
        }
        if importance is not None:
            mem_body["importance"] = importance
        mem_result = await automem.request("POST", "/memory", json=mem_body)
        memory_id = mem_result.get("memory_id") or mem_result.get("id")

        # 3. Link on the CRM side. Nakatomi's `/memory/link` expects
        # `{connector, external_id, crm_entity_type, crm_entity_id, note, data}`
        # — the note surfaces on the entity's timeline, `data` is freeform
        # metadata Nakatomi stores on the link row. We deliberately do NOT
        # require `automem` to be in Nakatomi's registered-connectors list
        # (that registry only gates the CRM→memory sync pipeline, not link
        # storage), so this works even before an upstream adapter lands.
        link_body = {
            "connector": "automem",
            "external_id": str(memory_id or ""),
            "crm_entity_type": entity_type,
            "crm_entity_id": entity_id,
            "note": content[:240],
            "data": {
                "source": "reva-mcp-router",
                "memory_type": memory_type,
                "tags": tag_list,
            },
        }
        link_result = await nakatomi.request(
            "POST", "/memory/link", token=token, json=link_body
        )
        return {
            "memory_id": memory_id,
            "link_id": link_result.get("id") if isinstance(link_result, dict) else None,
            "entity_type": entity_type,
            "entity_id": entity_id,
        }

    @mcp.tool(name="reva_recall_for_entity")
    async def recall_for_entity(
        ctx: Context,
        entity_type: str,
        entity_id: str,
        query: str | None = None,
        limit: int = 10,
    ) -> dict:
        """Recall memories tagged to a specific CRM entity.

        Scopes the AutoMem recall to ``{entity_type}:{entity_id}`` so you
        get only the notes/decisions/context that relate to this deal,
        contact, or company.
        """
        _ = token_from_ctx(ctx)
        params: dict[str, Any] = {
            "limit": max(1, min(limit, 50)),
            "tags": [f"{entity_type}:{entity_id}"],
            "tag_mode": "any",
        }
        if query:
            params["query"] = query
        return await automem.request("GET", "/recall", params=params)

    # ---------------------------------------------------------------
    # Profile / role / who-am-I — server-side so PMs never have to
    # configure company data locally. The plugin calls these on first
    # run and caches to ~/.reva-turbo/state/.
    # ---------------------------------------------------------------

    @mcp.tool(name="reva_whoami")
    async def whoami(ctx: Context) -> dict:
        """Return the caller's identity + Rev A workspace context.

        Used by the plugin's first-run bootstrap to decide what (if any)
        questions to ask. The plugin should NOT prompt for anything that
        this call can answer.
        """
        token = token_from_ctx(ctx)
        # /auth/me returns {id, email, display_name, ...} for the caller
        me = await nakatomi.request("GET", "/auth/me", token=token)
        ws = await nakatomi.request("GET", "/workspace", token=token)
        data = ws.get("data") or {}
        role_map = (data.get("user_roles") or {}) if isinstance(data, dict) else {}
        user_id = (me or {}).get("id")
        user_role = role_map.get(user_id) if user_id else None
        return {
            "user_id": user_id,
            "email": (me or {}).get("email"),
            "display_name": (me or {}).get("display_name"),
            "workspace": {
                "id": ws.get("id"),
                "slug": ws.get("slug"),
                "name": ws.get("name"),
            },
            "pm_role": user_role,  # None → plugin prompts once; then reva_set_user_role
            "needs_role": user_role is None,
            "tool_prefixes": {
                "crm": settings.crm_tool_prefix,
                "memory": settings.mem_tool_prefix,
                "cross": "reva",
            },
            # Primary system of record. Skills read this to decide whether
            # to hit Nakatomi directly (crm_*) or route through an external
            # connector the PM has installed in Desktop (hubspot_*, sf_*…).
            "primary_crm": data.get("primary_crm") or "nakatomi",
        }

    @mcp.tool(name="reva_get_company_profile")
    async def get_company_profile(ctx: Context) -> dict:
        """Return the Rev A Manufacturing company profile.

        Stored server-side in the workspace's ``data.company_profile``
        object so every PM pulls the same source-of-truth and no one has
        to re-enter the company name, leadership, escalation matrix, or
        capabilities at setup time.
        """
        token = token_from_ctx(ctx)
        ws = await nakatomi.request("GET", "/workspace", token=token)
        data = ws.get("data") or {}
        profile = data.get("company_profile")
        if not profile:
            return {
                "configured": False,
                "message": (
                    "company_profile is not yet populated on this workspace. "
                    "Ask your admin to run `./railway/deploy.sh seed` to "
                    "publish the Rev A profile."
                ),
            }
        return {"configured": True, **profile}

    @mcp.tool(name="reva_get_workspace_config")
    async def get_workspace_config(ctx: Context) -> dict:
        """Return the full Rev A workspace config: pipeline stages, custom
        fields, partners roster, memory taxonomy, role→skill map.

        Lets the plugin render the dashboard and route intents without
        maintaining any local YAML.
        """
        token = token_from_ctx(ctx)
        ws = await nakatomi.request("GET", "/workspace", token=token)
        pipelines = await nakatomi.request("GET", "/pipelines", token=token)
        fields = await nakatomi.request("GET", "/custom-fields", token=token)
        data = ws.get("data") or {}
        return {
            "workspace": {"id": ws.get("id"), "slug": ws.get("slug"), "name": ws.get("name")},
            "pipelines": pipelines or [],
            "custom_fields": fields or [],
            "partners": data.get("partners") or [],
            "memory_taxonomy": data.get("memory_taxonomy") or [],
            "escalation_matrix": data.get("escalation_matrix") or [],
            "role_skill_map": data.get("role_skill_map") or {},
            # Connector story — which external CRM (if any) is the team's
            # system of record. Skills use this to decide whether to talk
            # to an external connector first (e.g. HubSpot MCP tools) and
            # shadow-write to Nakatomi, or to stay internal.
            "primary_crm": data.get("primary_crm") or "nakatomi",
            "connector_registry": data.get("connector_registry") or [],
        }

    @mcp.tool(name="reva_set_user_role")
    async def set_user_role(ctx: Context, role: str) -> dict:
        """Record the caller's PM role (pm | sales | compliance | clevel | eng).

        Writes into ``workspace.data.user_roles[user_id]``. Used by the
        plugin to decide which skill subset to surface on the dashboard.
        Non-destructive: preserves all other keys in workspace.data.
        """
        role = (role or "").strip().lower()
        allowed = {"pm", "sales", "compliance", "clevel", "eng"}
        if role not in allowed:
            raise RuntimeError(
                f"role must be one of {sorted(allowed)}; got '{role}'"
            )
        # Read identity with caller's token (each user sees only themselves),
        # then write via admin token because PATCH /workspace is owner/admin-only.
        token = token_from_ctx(ctx)
        me = await nakatomi.request("GET", "/auth/me", token=token)
        user_id = (me or {}).get("id")
        if not user_id:
            raise RuntimeError("could not resolve caller user_id")
        admin = _admin_token()
        ws = await nakatomi.request("GET", "/workspace", token=admin)
        data = dict(ws.get("data") or {})
        roles = dict(data.get("user_roles") or {})
        roles[user_id] = role
        data["user_roles"] = roles
        await nakatomi.request(
            "PATCH", "/workspace", token=admin, json={"data": data}
        )
        return {"user_id": user_id, "role": role, "ok": True}

    @mcp.tool(name="reva_set_primary_crm")
    async def set_primary_crm(ctx: Context, connector: str) -> dict:
        """Set the workspace's primary CRM (system of record).

        Writes ``workspace.data.primary_crm``. ``connector`` must be the
        ``slug`` of an entry in ``workspace.data.connector_registry`` (e.g.
        ``nakatomi``, ``hubspot``, ``salesforce``, ``attio``, ``pipedrive``).

        This is a **team-level** setting: whoever runs it changes the
        system of record for the whole Rev A workspace. Skills read this
        on every write to decide where the authoritative record goes;
        the bundled Nakatomi + AutoMem always mirror the write so the
        shared Rev A timeline stays complete.

        Requires admin-token escalation (PATCH /workspace is owner-only
        in Nakatomi). The caller's own token is still checked via
        ``/auth/me`` so we can log *who* flipped it.
        """
        slug = (connector or "").strip().lower()
        if not slug:
            raise RuntimeError("connector is required")

        # Identify caller (for logging) and sanity-check workspace membership.
        token = token_from_ctx(ctx)
        me = await nakatomi.request("GET", "/auth/me", token=token)
        actor_id = (me or {}).get("id")
        if not actor_id:
            raise RuntimeError("could not resolve caller user_id")

        admin = _admin_token()
        ws = await nakatomi.request("GET", "/workspace", token=admin)
        data = dict(ws.get("data") or {})

        registry = data.get("connector_registry") or []
        valid_slugs = {entry.get("slug") for entry in registry if entry.get("slug")}
        if slug not in valid_slugs:
            raise RuntimeError(
                f"connector '{slug}' is not in the workspace registry. "
                f"Valid options: {sorted(valid_slugs) or ['<empty — run deploy.sh seed>']}. "
                "Ask your admin to extend `REVA_CONNECTOR_REGISTRY` if you "
                "need a connector that isn't listed."
            )
        entry = next(e for e in registry if e.get("slug") == slug)
        if not entry.get("primary_compatible", True):
            raise RuntimeError(
                f"connector '{slug}' is registered but not primary-compatible "
                "(it's observe-only). Pick a different connector."
            )

        previous = data.get("primary_crm") or "nakatomi"
        data["primary_crm"] = slug
        # Audit trail. Lightweight — we don't want a full log table here,
        # but the last N flips are useful for "who changed the CRM?" debug.
        history = list(data.get("primary_crm_history") or [])
        history.append({
            "from": previous,
            "to": slug,
            "actor_user_id": actor_id,
            "actor_email": (me or {}).get("email"),
        })
        data["primary_crm_history"] = history[-10:]  # keep last 10 flips
        await nakatomi.request(
            "PATCH", "/workspace", token=admin, json={"data": data}
        )
        return {
            "primary_crm": slug,
            "previous": previous,
            "display": entry.get("display", slug),
            "mcp_tool_prefix": entry.get("mcp_tool_prefix"),
            "bundled": bool(entry.get("bundled")),
            "notes": entry.get("notes", ""),
            "ok": True,
        }
