FROM python:3.11-slim

WORKDIR /app

# Install necessary system dependencies for PostgreSQL and SQLite extensions if needed
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
EXPOSE 8001

# Run the FastAPI service on container startup
CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8001"]
