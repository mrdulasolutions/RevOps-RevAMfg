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
CMD ["sh", "-c", "uvicorn router.main:app --host 0.0.0.0 --port ${PORT:-8080}"]
