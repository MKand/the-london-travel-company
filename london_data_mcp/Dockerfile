FROM python:3.11-slim

WORKDIR /app

# Install necessary system dependencies for PostgreSQL and SQLite.
RUN apt-get update && apt-get install -y \
    gcc \
    python3-dev \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code
COPY . .

# Expose the API port
EXPOSE 8002

# Run the MCP service on container startup
CMD ["python", "-m", "london_mcp.mcp_server"]
