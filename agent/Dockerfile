# =========================================================================
# Use an official Python runtime as a parent image
# FROM python:3.10-slim
#
# # Set the working directory in the container
# WORKDIR /app
#
# # Copy the requirements file into the container at /app
# COPY requirements.txt .
#
# # Install any needed packages specified in requirements.txt
# RUN pip install --no-cache-dir --upgrade pip -r requirements.txt
#
# # Copy the rest of the application's code into the container at /app
# COPY . .
#
# # Get the port number from the environment variable
# ENV PORT 8080
#
# # Command to run the application using Gunicorn with Uvicorn workers
# CMD ["gunicorn", "-w", "2", "-k", "uvicorn.workers.UvicornWorker", "main:app", "--bind", f"0.0.0.0:{os.environ.get('PORT', 8080)}"]