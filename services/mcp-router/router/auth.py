"""Extract the caller's bearer token from the current MCP request."""

from __future__ import annotations

from mcp.server.fastmcp import Context


def token_from_ctx(ctx: Context) -> str:
    """Pull ``Authorization: Bearer <token>`` off the current request.

    Raises RuntimeError if missing — FastMCP surfaces that as a tool error.
    """
    try:
        req = ctx.request_context.request
        auth = req.headers.get("authorization") if req else None
    except Exception:  # noqa: BLE001
        auth = None
    if not auth or not auth.lower().startswith("bearer "):
        raise RuntimeError(
            "missing bearer token; set Authorization: Bearer <nakatomi-api-key> "
            "in your MCP client config"
        )
    token = auth.split(None, 1)[1].strip()
    if not token:
        raise RuntimeError("empty bearer token")
    return token
