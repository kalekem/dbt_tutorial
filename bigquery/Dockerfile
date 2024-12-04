# Use a lightweight Python image with dbt installed
FROM python:3.9-slim

# Set the working directory in the container
WORKDIR /app

# Copy project files
COPY . .

#upgrade pip
RUN pip install --upgrade pip --root-user-action=ignore

#install packages
RUN pip install -r requirements.txt --root-user-action=ignore

#install dependencies
RUN dbt deps 

# Set environment variables for dbt
ENV DBT_PROFILES_DIR=/app

# Specify the entrypoint script
ENTRYPOINT ["dbt"]
