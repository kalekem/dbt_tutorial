# Use a lightweight Python image with dbt installed
FROM python:3.9-slim

# Set the working directory in the container
WORKDIR /app

# Copy project files
COPY . .

# Install dbt and dependencies
RUN pip install --upgrade pip --root-user-action=ignore 
RUN pip install -r requirements.txt --root-user-action=ignore

# Install dbt dependencies
RUN dbt deps 

# Set environment variables for dbt
ENV DBT_PROFILES_DIR=/app

# Specify the entrypoint script. These are the commands that cloud run job will execute on default
ENTRYPOINT ["dbt", "run", "--select", "orders"]
