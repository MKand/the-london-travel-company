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

FROM python:3.13-slim
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

WORKDIR /app

RUN apt-get update && apt-get install -y libpq-dev gcc

# Copy dependency files
COPY pyproject.toml uv.lock ./

# Install dependencies to the system Python (--system) 
# to avoid creating a virtual environment inside the container.
# Note: If this fails with 401, ensure Docker has access to the private registry 
# defined in uv.lock, or regenerate uv.lock using public PyPI.
RUN uv sync --frozen --no-cache

RUN adduser --disabled-password --gecos "" myuser && \
    chown -R myuser:myuser /app

COPY . /app

USER myuser

# Since we use --system, packages are in the system path.
ENV PATH="/home/myuser/.local/bin:$PATH"

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]

