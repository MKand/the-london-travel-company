import inspect
import json
import logging
import os
import uvicorn
import vertexai
from currency_exchange_agent.agent import root_agent
from fastapi import FastAPI, encoders, responses
from pydantic import BaseModel
from vertexai import agent_engines

app = FastAPI()

class QueryRequest(BaseModel):
    input: dict | None = None
    class_method: str | None = None

vertexai.init(
    project="reasoning-engine-test-1",
    location="europe-west3",
)

# Workaround while in autopush. Can remove when in prod.
def _session_service_builder():
  from google.adk.sessions.in_memory_session_service import InMemorySessionService

  return InMemorySessionService()

adk_app = agent_engines.AdkApp(
    agent=root_agent,
    session_service_builder=_session_service_builder, # Workaround for autopush.
)

def _encode_chunk_to_json(chunk):
  """Encodes a chunk to a JSON string with a newline."""
  try:
    json_chunk = encoders.jsonable_encoder(chunk)
    return json.dumps(json_chunk) + "\n"
  except Exception:
    logging.exception("Failed to encode chunk")
    return None

async def json_generator(output):
  async for chunk in output:
    encoded_chunk = _encode_chunk_to_json(chunk)
    if encoded_chunk is None:
      break
    yield encoded_chunk

async def _invoke_callable_or_raise(invocation_callable, invocation_payload):
  if inspect.iscoroutinefunction(invocation_callable):
    return await invocation_callable(**invocation_payload)
  else:
    return invocation_callable(**invocation_payload)

@app.post("/api/reasoning_engine")
async def query(request: QueryRequest) -> responses.JSONResponse:
    method = getattr(adk_app, request.class_method)
    output = await _invoke_callable_or_raise(method, request.input or {})

    try:
      json_serialized_content = encoders.jsonable_encoder({"output": output})
    except ValueError as encoding_error:
      logging.exception(
          "FastAPI could not JSON-encode the response from invocation method"
          " %s. Error: %s. Invocation method's original response: %r",
          request.class_method, encoding_error, output,
      )
      raise encoding_error
    return responses.JSONResponse(content=json_serialized_content)

@app.post("/api/stream_reasoning_engine")
async def stream_query(request: QueryRequest) -> responses.StreamingResponse:
    method = getattr(adk_app, request.class_method)
    output = await _invoke_callable_or_raise(method, request.input or {})
    return responses.StreamingResponse(
        content=json_generator(output),
        media_type="application/json",
    )

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=int(os.environ.get("PORT", 8080)))