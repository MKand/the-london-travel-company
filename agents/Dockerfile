FROM python:3.13-slim
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

# Set environment variables for uv
# 1. Don't create a .venv, install globally
# 2. Prevent uv from complaining about system python
ENV UV_PROJECT_ENVIRONMENT=/usr/local
ENV UV_SYSTEM_PYTHON=1

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq-dev \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Copy only dependency files first for layer caching
COPY pyproject.toml uv.lock ./

# Install dependencies
# --no-install-project skips installing the current package (only dependencies)
RUN uv sync --frozen --no-cache --no-install-project

# Copy the rest of the code
COPY . /app

# Setup user
RUN adduser --disabled-password --gecos "" myuser && \
    chown -R myuser:myuser /app

USER myuser

# Use 'uv run' to ensure the environment is correctly picked up
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]