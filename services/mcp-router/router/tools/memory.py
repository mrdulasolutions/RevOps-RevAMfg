"""Memory tools — proxy through to AutoMem's REST API.

AutoMem uses a single service token (not per-user keys). The router holds
that token and attaches it to every outbound call, so MCP clients only
need their Nakatomi bearer token.
"""

from __future__ import annotations

from typing import Any

from mcp.server.fastmcp import Context, FastMCP

from ..auth import token_from_ctx
from ..config import settings
from ..upstream import AutoMemClient

# AutoMem taxonomy (kept in sync with automem/config.py)
MEMORY_TYPES = [
    "Decision", "Pattern", "Preference", "Style", "Habit",
    "Insight", "Context", "Document",
]

RELATION_TYPES = [
    "RELATES_TO", "LEADS_TO", "OCCURRED_BEFORE", "PREPARES_FOR",
    "EVOLVED_INTO", "CONTRADICTS", "SUPPORTS", "EXEMPLIFIES",
    "PART_OF", "REFERENCES", "DEPENDS_ON",
]


def register(mcp: FastMCP) -> None:
    client = AutoMemClient()
    p = settings.mem_tool_prefix

    @mcp.tool(name=f"{p}_store")
    async def store_memory(
        ctx: Context,
        content: str,
        type: str | None = None,
        confidence: float | None = None,
        tags: list[str] | None = None,
        importance: float | None = None,
        metadata: dict | None = None,
        timestamp: str | None = None,
        t_valid: str | None = None,
        t_invalid: str | None = None,
    ) -> dict:
        """Store a memory. `type` should be one of the AutoMem taxonomy
        values (Decision, Pattern, Preference, Style, Habit, Insight,
        Context, Document)."""
        _ = token_from_ctx(ctx)  # require auth, even though AutoMem uses service token
        body: dict[str, Any] = {"content": content}
        if type:
            body["type"] = type
        if confidence is not None:
            body["confidence"] = confidence
        if tags is not None:
            body["tags"] = tags
        if importance is not None:
            body["importance"] = importance
        if metadata is not None:
            body["metadata"] = metadata
        if timestamp:
            body["timestamp"] = timestamp
        if t_valid:
            body["t_valid"] = t_valid
        if t_invalid:
            body["t_invalid"] = t_invalid
        return await client.request("POST", "/memory", json=body)

    @mcp.tool(name=f"{p}_recall")
    async def recall_memory(
        ctx: Context,
        query: str | None = None,
        queries: list[str] | None = None,
        limit: int = 5,
        time_query: str | None = None,
        start: str | None = None,
        end: str | None = None,
        sort: str | None = None,
        tags: list[str] | None = None,
        tag_mode: str | None = None,
        tag_match: str | None = None,
        expand_relations: bool | None = None,
        expand_entities: bool | None = None,
        context_types: list[str] | None = None,
    ) -> dict:
        """Hybrid semantic + keyword recall with optional time and tag filters."""
        _ = token_from_ctx(ctx)
        params: dict[str, Any] = {"limit": max(1, min(limit, 50))}
        if query:
            params["query"] = query
        if queries:
            params["queries"] = queries
        if time_query:
            params["time_query"] = time_query
        if start:
            params["start"] = start
        if end:
            params["end"] = end
        if sort:
            params["sort"] = sort
        if tags:
            params["tags"] = tags
        if tag_mode:
            params["tag_mode"] = tag_mode
        if tag_match:
            params["tag_match"] = tag_match
        if expand_relations is not None:
            params["expand_relations"] = str(expand_relations).lower()
        if expand_entities is not None:
            params["expand_entities"] = str(expand_entities).lower()
        if context_types:
            params["context_types"] = context_types
        return await client.request("GET", "/recall", params=params)

    @mcp.tool(name=f"{p}_associate")
    async def associate_memories(
        ctx: Context,
        memory1_id: str,
        memory2_id: str,
        type: str,
        strength: float,
    ) -> dict:
        """Create a typed relationship between two memories."""
        _ = token_from_ctx(ctx)
        body = {
            "memory1_id": memory1_id,
            "memory2_id": memory2_id,
            "type": type,
            "strength": max(0.0, min(1.0, strength)),
        }
        return await client.request("POST", "/associate", json=body)

    @mcp.tool(name=f"{p}_update")
    async def update_memory(
        ctx: Context,
        memory_id: str,
        content: str | None = None,
        type: str | None = None,
        confidence: float | None = None,
        tags: list[str] | None = None,
        importance: float | None = None,
        metadata: dict | None = None,
    ) -> dict:
        _ = token_from_ctx(ctx)
        updates: dict[str, Any] = {}
        if content is not None:
            updates["content"] = content
        if type is not None:
            updates["type"] = type
        if confidence is not None:
            updates["confidence"] = confidence
        if tags is not None:
            updates["tags"] = tags
        if importance is not None:
            updates["importance"] = importance
        if metadata is not None:
            updates["metadata"] = metadata
        return await client.request("PATCH", f"/memory/{memory_id}", json=updates)

    @mcp.tool(name=f"{p}_delete")
    async def delete_memory(ctx: Context, memory_id: str) -> dict:
        _ = token_from_ctx(ctx)
        return await client.request("DELETE", f"/memory/{memory_id}")

    @mcp.tool(name=f"{p}_health")
    async def health(ctx: Context) -> dict:
        """Check backend health (FalkorDB + Qdrant + embeddings)."""
        _ = token_from_ctx(ctx)
        return await client.request("GET", "/health")
