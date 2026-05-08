# Use a slim Python base image
FROM python:3.11-slim

# Set the working directory inside the container
WORKDIR /app

# Copy the requirements file and install dependencies
# It's good practice to copy requirements.txt first to leverage Docker cache
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of your application code
# Assuming your agent logic is in an 'agent' directory and the server is in 'main.py'
COPY london_agent/ /app/london_agent/

# The container must listen on port 8080 as per Agent Engine runtime contract.
# Uvicorn will bind to this port using the $PORT environment variable, which Agent Engine provides.
ENV PORT 8080

# Command to run the FastAPI application using Uvicorn
# The application object 'app' is defined in main.py
CMD ["sh", "-c", "uvicorn london_agent.main:app --host 0.0.0.0 --port ${PORT}"]
