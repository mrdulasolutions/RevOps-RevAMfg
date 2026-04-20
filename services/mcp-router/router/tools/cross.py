"""Cross-system tools — CRM × memory in a single call.

These are the reason we run a router (instead of two independent MCPs):
orchestrate Nakatomi + AutoMem together so agents can think in terms of
the Rev A workflow rather than the underlying systems.
"""

from __future__ import annotations

from typing import Any

from mcp.server.fastmcp import Context, FastMCP

from ..auth import token_from_ctx
from ..config import settings
from ..upstream import AutoMemClient, NakatomiClient


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

        # 3. Link on the CRM side
        link_body = {
            "entity_type": entity_type,
            "entity_id": entity_id,
            "memory_id": memory_id,
            "connector": "automem",
            "summary": content[:240],
        }
        link_result = await nakatomi.request(
            "POST", "/memory-links", token=token, json=link_body
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
