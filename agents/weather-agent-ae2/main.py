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
from google.adk.cli.fast_api import get_fast_api_app
from fastapi import FastAPI
from weather_agent.agent import root_agent
from pydantic import BaseModel


AGENT_DIR = os.path.dirname(os.path.abspath(__file__))
ALLOWED_ORIGINS = ["*"]


# Call the function to get the FastAPI app instance
app: FastAPI = get_fast_api_app(
    agents_dir=os.path.dirname(AGENT_DIR),
    allow_origins=ALLOWED_ORIGINS,
    web=True,
)


class ReasoningEngineRequest(BaseModel):
    class_method: str
    input: dict = {}

# Helper to handle method invocation, including async
async def _invoke_agent_method(agent_obj, method_name: str, payload: dict):
    if not hasattr(agent_obj, method_name):
        raise ValueError(f"Agent does not have method: {method_name}")
    method = getattr(agent_obj, method_name)
    if callable(method):
        # Check if the method is an async function
        import inspect
        if inspect.iscoroutinefunction(method):
            return await method(**payload)
        else:
            return method(**payload)
    else:
        raise ValueError(f"'{method_name}' is not a callable method on the agent.")

# Endpoint for synchronous calls
@app.post("/api/reasoning_engine")
async def reasoning_engine_query(request: ReasoningEngineRequest):
    logging.info(f"Received sync query for method: {request.class_method}")
    try:
        output = await _invoke_agent_method(root_agent, request.class_method, request.input)
        return JSONResponse(content={"output": encoders.jsonable_encoder(output)})
    except Exception as e:
        logging.error(f"Error in sync query for {request.class_method}: {e}", exc_info=True)
        return JSONResponse(content={"error": str(e)}, status_code=status.HTTP_500_INTERNAL_SERVER_ERROR)

# Endpoint for streaming calls
@app.post("/api/stream_reasoning_engine")
async def reasoning_engine_stream_query(request: ReasoningEngineRequest):
    logging.info(f"Received stream query for method: {request.class_method}")
    async def generate_chunks():
        try:
            # Invoke the streaming method on the agent
            async for chunk in await _invoke_agent_method(root_agent, request.class_method, request.input):
                yield encoders.jsonable_encoder(chunk) + "\n"
        except Exception as e:
            logging.error(f"Error in stream query for {request.class_method}: {e}", exc_info=True)
            yield encoders.jsonable_encoder({"error": str(e)}) + "\n"

    return StreamingResponse(generate_chunks(), media_type="application/json")

@app.get("/health")
async def health_check():
    return "OK"


if __name__ == "__main__":
   uvicorn.run(app, host="0.0.0.0", port=int(os.getenv("PORT", "8080")))