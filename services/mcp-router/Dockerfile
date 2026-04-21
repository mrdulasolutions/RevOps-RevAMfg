FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

WORKDIR /app

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY router ./router

EXPOSE 8080

# Railway supplies $PORT; default to 8080 for local.
# --proxy-headers + --forwarded-allow-ips='*' make uvicorn trust Railway's
# X-Forwarded-Proto so any redirect (e.g. Starlette's Mount trailing-slash
# redirect on /mcp → /mcp/) stays HTTPS instead of downgrading to HTTP and
# stripping the Authorization header.
CMD ["sh", "-c", "uvicorn router.main:app --host 0.0.0.0 --port ${PORT:-8080} --proxy-headers --forwarded-allow-ips='*'"]
