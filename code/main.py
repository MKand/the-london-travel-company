import os

import uvicorn
from fastapi import FastAPI
from google.adk.cli.fast_api import get_fast_api_app
from opentelemetry import trace
from opentelemetry.exporter.cloud_trace import CloudTraceSpanExporter
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import (
    SimpleSpanProcessor, BatchSpanProcessor
)
import logging

logging.basicConfig(level=logging.INFO)

AGENT_DIR = os.path.dirname(os.path.abspath(__file__))
ALLOWED_ORIGINS = ["http://localhost", "http://localhost:8080", "*"]

print_health_status = os.getenv("PRINT_HEALTH_STATUS", "False")

# Call the function to get the FastAPI app instance

app: FastAPI = get_fast_api_app(
    agents_dir=AGENT_DIR,
    allow_origins=ALLOWED_ORIGINS,
    web=True,
    trace_to_cloud = True,
)


@app.get("/health")
async def read_root():
    if print_health_status != "False":
        # This will force the app to crash 
        check_health_status()
        
    return "OK"

def check_health_status():
    logging.error("Application crashed during health check.")
    os._exit(0)


if __name__ == "__main__":
    # Use the PORT environment variable provided by Cloud Run, defaulting to 8000
    uvicorn.run(app, host="0.0.0.0", port=int(os.environ.get("PORT", 8000)))