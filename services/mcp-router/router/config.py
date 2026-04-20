"""Runtime configuration, loaded from environment."""

from __future__ import annotations

from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    port: int = 8080
    log_level: str = "INFO"

    # Upstreams
    nakatomi_internal_url: str = Field(default="http://localhost:8000")
    automem_internal_url: str = Field(default="http://localhost:8001")

    # Auth
    auth_mode: str = Field(default="passthrough")  # passthrough | service
    automem_api_token: str = Field(default="changeme")

    # Namespaces
    crm_tool_prefix: str = "crm"
    mem_tool_prefix: str = "mem"

    # Timeouts
    upstream_timeout: float = 30.0
    upstream_connect_timeout: float = 5.0


settings = Settings()
