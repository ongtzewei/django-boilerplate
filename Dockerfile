# Stage 1: Builder
FROM python:3.13-slim AS builder

# Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

WORKDIR /django/boilerplate-app

# Copy dependency files
COPY pyproject.toml uv.lock ./

# Install dependencies
# --frozen: Sync with lockfile
# --no-dev: Exclude dev dependencies
# --no-install-project: Install only dependencies, not the project itself yet
RUN uv sync --frozen --no-dev --no-install-project

# Stage 2: Final
FROM python:3.13-slim

WORKDIR /django/boilerplate-app

ENV PYTHONUNBUFFERED=1
ENV PATH="/django/boilerplate-app/.venv/bin:$PATH"

# Copy virtualenv from builder
COPY --from=builder /django/boilerplate-app/.venv /django/boilerplate-app/.venv

# Copy application code
COPY . .

# Ensure entrypoint is executable
RUN chmod +x docker-entrypoint.sh

EXPOSE 8080

ENTRYPOINT ["./docker-entrypoint.sh"]
