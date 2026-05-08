FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY main.py .
COPY weather_agent/ /app/weather_agent/


CMD ["sh", "-c", "uvicorn main:app --host 0.0.0.0 --port 8080"]