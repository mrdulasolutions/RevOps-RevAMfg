"""CRM tools — proxy through to Nakatomi's REST API.

Tool names are prefixed (e.g. ``crm_search_contacts``) to avoid colliding
with the memory namespace. Each tool forwards the caller's bearer token to
Nakatomi, which enforces workspace isolation via its API-key model.
"""

from __future__ import annotations

from typing import Any

from mcp.server.fastmcp import Context, FastMCP

from ..auth import token_from_ctx
from ..config import settings
from ..upstream import NakatomiClient


def register(mcp: FastMCP) -> None:
    client = NakatomiClient()
    p = settings.crm_tool_prefix

    # ---- Contacts ------------------------------------------------------

    @mcp.tool(name=f"{p}_search_contacts")
    async def search_contacts(
        ctx: Context,
        query: str | None = None,
        email: str | None = None,
        company_id: str | None = None,
        tag: str | None = None,
        limit: int = 25,
    ) -> list[dict]:
        """Search contacts by name/email substring, exact email, company, or tag."""
        params: dict[str, Any] = {"limit": min(limit, 200)}
        if query:
            params["q"] = query
        if email:
            params["email"] = email
        if company_id:
            params["company_id"] = company_id
        if tag:
            params["tag"] = tag
        return await client.request("GET", "/contacts", token=token_from_ctx(ctx), params=params)

    @mcp.tool(name=f"{p}_get_contact")
    async def get_contact(ctx: Context, contact_id: str) -> dict:
        """Fetch one contact by id."""
        return await client.request(
            "GET", f"/contacts/{contact_id}", token=token_from_ctx(ctx)
        )

    @mcp.tool(name=f"{p}_create_contact")
    async def create_contact(
        ctx: Context,
        first_name: str | None = None,
        last_name: str | None = None,
        email: str | None = None,
        phone: str | None = None,
        title: str | None = None,
        company_id: str | None = None,
        tags: list[str] | None = None,
        external_id: str | None = None,
        data: dict | None = None,
    ) -> dict:
        """Create a new contact."""
        body = {
            "first_name": first_name,
            "last_name": last_name,
            "email": email,
            "phone": phone,
            "title": title,
            "company_id": company_id,
            "tags": tags or [],
            "external_id": external_id,
            "data": data or {},
        }
        return await client.request("POST", "/contacts", token=token_from_ctx(ctx), json=body)

    @mcp.tool(name=f"{p}_update_contact")
    async def update_contact(ctx: Context, contact_id: str, updates: dict) -> dict:
        """Patch a contact. ``updates`` may contain any contact field."""
        return await client.request(
            "PATCH", f"/contacts/{contact_id}", token=token_from_ctx(ctx), json=updates
        )

    # ---- Companies -----------------------------------------------------

    @mcp.tool(name=f"{p}_search_companies")
    async def search_companies(
        ctx: Context,
        query: str | None = None,
        domain: str | None = None,
        tag: str | None = None,
        limit: int = 25,
    ) -> list[dict]:
        params: dict[str, Any] = {"limit": min(limit, 200)}
        if query:
            params["q"] = query
        if domain:
            params["domain"] = domain
        if tag:
            params["tag"] = tag
        return await client.request("GET", "/companies", token=token_from_ctx(ctx), params=params)

    @mcp.tool(name=f"{p}_create_company")
    async def create_company(
        ctx: Context,
        name: str,
        domain: str | None = None,
        website: str | None = None,
        industry: str | None = None,
        employee_count: int | None = None,
        annual_revenue: float | None = None,
        description: str | None = None,
        tags: list[str] | None = None,
        external_id: str | None = None,
        data: dict | None = None,
    ) -> dict:
        body = {
            "name": name,
            "domain": domain,
            "website": website,
            "industry": industry,
            "employee_count": employee_count,
            "annual_revenue": annual_revenue,
            "description": description,
            "tags": tags or [],
            "external_id": external_id,
            "data": data or {},
        }
        return await client.request("POST", "/companies", token=token_from_ctx(ctx), json=body)

    # ---- Pipelines / Deals --------------------------------------------

    @mcp.tool(name=f"{p}_list_pipelines")
    async def list_pipelines(ctx: Context) -> list[dict]:
        """List pipelines and their stages for the workspace."""
        return await client.request("GET", "/pipelines", token=token_from_ctx(ctx))

    @mcp.tool(name=f"{p}_create_deal")
    async def create_deal(
        ctx: Context,
        name: str,
        pipeline_id: str,
        stage_id: str,
        amount: float | None = None,
        currency: str | None = None,
        company_id: str | None = None,
        primary_contact_id: str | None = None,
        expected_close_date: str | None = None,
        tags: list[str] | None = None,
        data: dict | None = None,
    ) -> dict:
        body = {
            "name": name,
            "pipeline_id": pipeline_id,
            "stage_id": stage_id,
            "amount": amount,
            "currency": currency,
            "company_id": company_id,
            "primary_contact_id": primary_contact_id,
            "expected_close_date": expected_close_date,
            "tags": tags or [],
            "data": data or {},
        }
        return await client.request("POST", "/deals", token=token_from_ctx(ctx), json=body)

    @mcp.tool(name=f"{p}_move_deal_stage")
    async def move_deal_stage(
        ctx: Context,
        deal_id: str,
        stage_id: str,
        note: str | None = None,
    ) -> dict:
        """Move a deal to a new stage. Optional ``note`` is recorded on the timeline."""
        body = {"stage_id": stage_id, "note": note}
        return await client.request(
            "POST", f"/deals/{deal_id}/move", token=token_from_ctx(ctx), json=body
        )

    # ---- Activities / Notes / Tasks -----------------------------------

    @mcp.tool(name=f"{p}_log_activity")
    async def log_activity(
        ctx: Context,
        entity_type: str,
        entity_id: str,
        activity_type: str,
        subject: str | None = None,
        body: str | None = None,
        occurred_at: str | None = None,
    ) -> dict:
        """Log an activity (call, email, meeting, etc.) against any entity."""
        payload = {
            "entity_type": entity_type,
            "entity_id": entity_id,
            "activity_type": activity_type,
            "subject": subject,
            "body": body,
            "occurred_at": occurred_at,
        }
        return await client.request(
            "POST", "/activities", token=token_from_ctx(ctx), json=payload
        )

    @mcp.tool(name=f"{p}_add_note")
    async def add_note(
        ctx: Context,
        entity_type: str,
        entity_id: str,
        body: str,
        pinned: bool = False,
    ) -> dict:
        payload = {
            "entity_type": entity_type,
            "entity_id": entity_id,
            "body": body,
            "pinned": pinned,
        }
        return await client.request("POST", "/notes", token=token_from_ctx(ctx), json=payload)

    @mcp.tool(name=f"{p}_create_task")
    async def create_task(
        ctx: Context,
        title: str,
        entity_type: str | None = None,
        entity_id: str | None = None,
        due_date: str | None = None,
        assignee_user_id: str | None = None,
        priority: str | None = None,
    ) -> dict:
        payload = {
            "title": title,
            "entity_type": entity_type,
            "entity_id": entity_id,
            "due_date": due_date,
            "assignee_user_id": assignee_user_id,
            "priority": priority,
        }
        return await client.request("POST", "/tasks", token=token_from_ctx(ctx), json=payload)

    @mcp.tool(name=f"{p}_list_tasks")
    async def list_tasks(
        ctx: Context,
        status: str | None = None,
        assignee_user_id: str | None = None,
        due_before: str | None = None,
        limit: int = 50,
    ) -> list[dict]:
        params: dict[str, Any] = {"limit": min(limit, 200)}
        if status:
            params["status"] = status
        if assignee_user_id:
            params["assignee_user_id"] = assignee_user_id
        if due_before:
            params["due_before"] = due_before
        return await client.request("GET", "/tasks", token=token_from_ctx(ctx), params=params)

    # ---- Graph --------------------------------------------------------

    @mcp.tool(name=f"{p}_relate")
    async def relate(
        ctx: Context,
        from_type: str,
        from_id: str,
        to_type: str,
        to_id: str,
        kind: str,
        data: dict | None = None,
    ) -> dict:
        """Create a typed relationship edge between two CRM entities."""
        payload = {
            "from_type": from_type,
            "from_id": from_id,
            "to_type": to_type,
            "to_id": to_id,
            "kind": kind,
            "data": data or {},
        }
        return await client.request(
            "POST", "/relationships", token=token_from_ctx(ctx), json=payload
        )

    @mcp.tool(name=f"{p}_timeline")
    async def timeline(
        ctx: Context,
        entity_type: str,
        entity_id: str,
        limit: int = 100,
    ) -> list[dict]:
        """Timeline events for an entity, newest first."""
        params = {"entity_type": entity_type, "entity_id": entity_id, "limit": min(limit, 500)}
        return await client.request("GET", "/timeline", token=token_from_ctx(ctx), params=params)

    @mcp.tool(name=f"{p}_describe_schema")
    async def describe_schema(ctx: Context) -> dict:
        """Self-describing schema manifest for this workspace."""
        return await client.request("GET", "/schema", token=token_from_ctx(ctx))
