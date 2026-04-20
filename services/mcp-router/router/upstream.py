"""Thin HTTP clients for the two internal backends.

Both are reached over Railway's private network in production. Errors are
surfaced as ``UpstreamError`` so tool wrappers can return clean MCP errors.
"""

from __future__ import annotations

from typing import Any

import httpx

from .config import settings


class UpstreamError(RuntimeError):
    """Non-2xx response (or transport error) from an internal backend."""

    def __init__(self, service: str, status: int, message: str, body: Any = None):
        super().__init__(f"{service} upstream {status}: {message}")
        self.service = service
        self.status = status
        self.message = message
        self.body = body


def _timeout() -> httpx.Timeout:
    return httpx.Timeout(
        settings.upstream_timeout,
        connect=settings.upstream_connect_timeout,
    )


class NakatomiClient:
    """Calls Nakatomi's REST API. Uses the caller's bearer token (passthrough)
    or a service token (service mode).
    """

    def __init__(self, base_url: str | None = None):
        self.base_url = (base_url or settings.nakatomi_internal_url).rstrip("/")

    async def request(
        self,
        method: str,
        path: str,
        *,
        token: str,
        json: Any = None,
        params: dict | None = None,
    ) -> Any:
        url = f"{self.base_url}{path}"
        headers = {"Authorization": f"Bearer {token}"}
        async with httpx.AsyncClient(timeout=_timeout()) as client:
            try:
                resp = await client.request(method, url, headers=headers, json=json, params=params)
            except httpx.HTTPError as exc:
                raise UpstreamError("nakatomi", 0, str(exc)) from exc
        if resp.status_code >= 400:
            try:
                body = resp.json()
            except Exception:  # noqa: BLE001
                body = resp.text
            raise UpstreamError("nakatomi", resp.status_code, resp.reason_phrase, body)
        if resp.status_code == 204 or not resp.content:
            return None
        return resp.json()


class AutoMemClient:
    """Calls AutoMem's REST API. AutoMem doesn't have per-user keys — it uses a
    single service token set via env. We forward that token on every call.
    """

    def __init__(self, base_url: str | None = None, api_token: str | None = None):
        self.base_url = (base_url or settings.automem_internal_url).rstrip("/")
        self.api_token = api_token or settings.automem_api_token

    async def request(
        self,
        method: str,
        path: str,
        *,
        json: Any = None,
        params: dict | None = None,
    ) -> Any:
        url = f"{self.base_url}{path}"
        headers = {
            "Authorization": f"Bearer {self.api_token}",
            "X-API-Key": self.api_token,  # AutoMem accepts either
        }
        async with httpx.AsyncClient(timeout=_timeout()) as client:
            try:
                resp = await client.request(method, url, headers=headers, json=json, params=params)
            except httpx.HTTPError as exc:
                raise UpstreamError("automem", 0, str(exc)) from exc
        if resp.status_code >= 400:
            try:
                body = resp.json()
            except Exception:  # noqa: BLE001
                body = resp.text
            raise UpstreamError("automem", resp.status_code, resp.reason_phrase, body)
        if resp.status_code == 204 or not resp.content:
            return None
        return resp.json()
