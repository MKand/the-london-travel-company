# Copyright 2025 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import os
import uvicorn
import logging
import google.auth
import google.auth.transport.requests
import grpc
from google.auth.transport.grpc import AuthMetadataPlugin
from opentelemetry import _events as events, _logs as logs, metrics, trace
from opentelemetry.exporter.cloud_logging import CloudLoggingExporter
from opentelemetry.exporter.cloud_monitoring import CloudMonitoringMetricsExporter
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import (
    OTLPSpanExporter,
)
from opentelemetry.instrumentation.google_genai import GoogleGenAiSdkInstrumentor
from opentelemetry.sdk._events import EventLoggerProvider
from opentelemetry.sdk._logs import LoggerProvider
from opentelemetry.sdk._logs.export import BatchLogRecordProcessor
from opentelemetry.sdk.metrics import MeterProvider
from opentelemetry.sdk.metrics.export import PeriodicExportingMetricReader
from opentelemetry.sdk.resources import SERVICE_NAME, Resource
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.instrumentation.google_genai import GoogleGenAiSdkInstrumentor
from google.adk.cli.fast_api import get_fast_api_app
from fastapi import FastAPI
from london_agent.sub_agents.search_agent.tools import setup_sqlite_client

import london_agent # doing to make errors importing the agent appear explicity

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

AGENT_DIR = os.path.dirname(os.path.abspath(__file__))
ALLOWED_ORIGINS = ["http://localhost", "http://localhost:8080", "*"]
SESSION_DB_URL = "sqlite:///./sessions.db"

def str_to_bool(s: str) -> bool:
    """
    Convert a string to a boolean.
    Accepts: yes/no, true/false, t/f, y/n, on/off, 1/0.
    Raises ValueError if invalid.
    """
    truthy = {"y", "yes", "t", "true", "on", "1"}
    falsy  = {"n", "no", "f", "false", "off", "0"}

    s = s.strip().lower()
    if s in truthy:
        return True
    if s in falsy:
        return False
    raise ValueError(f"Invalid boolean string: {s}")


print_health_status = str_to_bool(os.getenv("PRINT_HEALTH_STATUS", "False"))

def check_health_status():
    print_message = os.environ['PRINT_MESSAGE']
    if print_message ==  "True":
        logger.info("health check succeeded")


GCP_SCOPES = [
    "https://www.googleapis.com/auth/trace.append",       # For Cloud Trace
    "https://www.googleapis.com/auth/logging.write",      # For Cloud Logging
    "https://www.googleapis.com/auth/monitoring.write",   # For Cloud Monitoring
    "https://www.googleapis.com/auth/cloud-platform",     # Broad scope for other Google ADK/AI Platform needs
   ]

def setup_opentelemetry() -> None:
    credentials, project_id = google.auth.default(scopes=GCP_SCOPES)
    resource = Resource.create(
        attributes={
            SERVICE_NAME: "lta-sa",
            "gcp.project_id": project_id,
        }
    )
    # Set up OTLP auth
    request = google.auth.transport.requests.Request()
    auth_metadata_plugin = AuthMetadataPlugin(credentials=credentials, request=request)

    channel_creds = grpc.composite_channel_credentials(
        grpc.ssl_channel_credentials(),
        grpc.metadata_call_credentials(auth_metadata_plugin),
    )

    # Set up OpenTelemetry Python SDK
    tracer_provider = TracerProvider(resource=resource)
    tracer_provider.add_span_processor(
        BatchSpanProcessor(
            OTLPSpanExporter(
                credentials=channel_creds,
                endpoint="https://telemetry.googleapis.com:443/v1/traces",
            )
        )
    )
    trace.set_tracer_provider(tracer_provider)

    logger_provider = LoggerProvider(resource=resource)
    logger_provider.add_log_record_processor(
        BatchLogRecordProcessor(CloudLoggingExporter())
    )

    logs.set_logger_provider(logger_provider)

    event_logger_provider = EventLoggerProvider(logger_provider)
    events.set_event_logger_provider(event_logger_provider)

    reader = PeriodicExportingMetricReader(CloudMonitoringMetricsExporter())
    meter_provider = MeterProvider(metric_readers=[reader], resource=resource)
    metrics.set_meter_provider(meter_provider)

    # Load instrumentors
    # TODO: if this is too chatty because of ADK's use of SQL for session management, the
    # connection used in tools.py can be instrumented to cut ADK spans out
    GoogleGenAiSdkInstrumentor().instrument()
    return

setup_opentelemetry()
setup_sqlite_client()

# Call the function to get the FastAPI app instance
app: FastAPI = get_fast_api_app(
    agents_dir=AGENT_DIR,
    allow_origins=ALLOWED_ORIGINS,
    web=True,
)

@app.get("/health")
async def read_root():
    if print_health_status:
        # This will force the app to crash 
        check_health_status()
    return "OK"

@app.post("/change_health_status")
async def post_health_status():
    global print_health_status
    print_health_status = not print_health_status
    return f"Updated print_health_status to {print_health_status}"


if __name__ == "__main__":
   uvicorn.run(app, host="0.0.0.0", port=int(os.environ.get("PORT", 8000)))