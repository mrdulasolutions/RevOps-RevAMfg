"""Entry point — mounts the FastMCP streamable-HTTP app under ``/mcp`` and
exposes a ``/health`` probe for Railway.
"""

from __future__ import annotations

import contextlib
import logging

from fastapi import FastAPI
from fastapi.responses import JSONResponse
from mcp.server.fastmcp import FastMCP
from mcp.server.transport_security import TransportSecuritySettings

from .config import settings
from .signup import router as signup_router
from .tools import crm, cross, memory


def build_mcp() -> FastMCP:
    mcp = FastMCP(
        "REVA Router",
        instructions=(
            "Unified MCP for Rev A Manufacturing. Tool namespaces: "
            f"`{settings.crm_tool_prefix}_*` (Nakatomi CRM), "
            f"`{settings.mem_tool_prefix}_*` (AutoMem memory), "
            "`reva_*` (cross-system flows)."
        ),
        streamable_http_path="/",
        transport_security=TransportSecuritySettings(enable_dns_rebinding_protection=False),
    )
    crm.register(mcp)
    memory.register(mcp)
    cross.register(mcp)
    return mcp


def create_app() -> FastAPI:
    logging.basicConfig(level=settings.log_level.upper())
    log = logging.getLogger("reva.router")

    mcp = build_mcp()

    # FastMCP's streamable-HTTP session manager runs inside its own anyio task
    # group; mounting the sub-app alone doesn't start it. Wiring the session
    # manager's lifespan into the parent FastAPI app is what keeps the task
    # group alive for the server's lifetime — without it every /mcp/ request
    # 500s with "Task group is not initialized".
    @contextlib.asynccontextmanager
    async def lifespan(_: FastAPI):
        async with mcp.session_manager.run():
            yield

    app = FastAPI(title="REVA MCP Router", version="0.1.0", lifespan=lifespan)

    # Normalize /mcp → /mcp/ IN-PLACE (no 307 redirect). Starlette's Mount
    # would otherwise redirect any missing-trailing-slash request, and
    # mcp-remote / other MCP clients drop the POST body (and Authorization
    # header, if the redirect downgrades to HTTP) when following a 307.
    # Rewriting the path at the ASGI layer bypasses that entirely — clients
    # can POST to /mcp OR /mcp/ and both work.
    @app.middleware("http")
    async def normalize_mcp_trailing_slash(request, call_next):
        if request.scope["path"] == "/mcp":
            request.scope["path"] = "/mcp/"
            request.scope["raw_path"] = b"/mcp/"
        return await call_next(request)

    app.mount("/mcp", mcp.streamable_http_app())

    # Self-service signup (GET /signup HTML, POST /signup JSON)
    app.include_router(signup_router)

    @app.get("/health")
    async def health() -> JSONResponse:
        return JSONResponse({"ok": True, "service": "reva-mcp-router"})

    @app.get("/")
    async def index() -> JSONResponse:
        return JSONResponse(
            {
                "service": "reva-mcp-router",
                "mcp_endpoint": "/mcp/",
                "signup_page": "/signup",
                "tool_prefixes": {
                    "crm": settings.crm_tool_prefix,
                    "memory": settings.mem_tool_prefix,
                    "cross": "reva",
                },
            }
        )

    log.info(
        "reva mcp router ready nakatomi=%s automem=%s auth_mode=%s",
        settings.nakatomi_internal_url,
        settings.automem_internal_url,
        settings.auth_mode,
    )
    return app


app = create_app()
