import os

import uvicorn
from fastapi import FastAPI
from google.adk.cli.fast_api import get_fast_api_app
import logging
import google.auth
import google.auth.transport.requests
import grpc
from google.auth.transport.grpc import AuthMetadataPlugin
from opentelemetry import _events as events
from opentelemetry import _logs as logs
from opentelemetry import metrics, trace
from opentelemetry.exporter.cloud_logging import CloudLoggingExporter
from opentelemetry.exporter.cloud_monitoring import CloudMonitoringMetricsExporter
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import (
    OTLPSpanExporter,
)
from opentelemetry.instrumentation.sqlite3 import SQLite3Instrumentor
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


logging.basicConfig(level=logging.INFO)

AGENT_DIR = os.path.dirname(os.path.abspath(__file__))
ALLOWED_ORIGINS = ["http://localhost", "http://localhost:8080", "*"]
SESSION_DB_URL = "sqlite:///./sessions.db"

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


def setup_opentelemetry() -> None:
    credentials, project_id = google.auth.default()
    resource = Resource.create(
        attributes={
            SERVICE_NAME: "adk-sql-agent",
            # The project to send spans to
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
    SQLite3Instrumentor().instrument()
    GoogleGenAiSdkInstrumentor().instrument()

if __name__ == "__main__":
    OTEL_PYTHON_LOGGING_AUTO_INSTRUMENTATION_ENABLED=true
    OTEL_INSTRUMENTATION_GENAI_CAPTURE_MESSAGE_CONTENT=true
    setup_opentelemetry()
    uvicorn.run(app, host="0.0.0.0", port=int(os.environ.get("PORT", 8000)))