# Use an official Python runtime as the base image. Slim version is smaller.
FROM python:3.10-slim
# Set environment variable to output Python logs directly to container logs
ENV PYTHONUNBUFFERED=1
# Set the working directory inside the container
WORKDIR /app
# Copy the requirements file first. This allows Docker to cache this step.
COPY requirements.txt .
# Install the Python dependencies defined in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt
# Copy the rest of the application's code from the host to the container
COPY . .
# Inform Docker that the container listens on port 8000 at runtime.
EXPOSE 8000
# Define the command to run the application. Use 0..
CMD ["python", "app.py", "--host=0.0.0.0"]