from airflow import DAG
from airflow.providers.google.cloud.operators.bigquery import BigQueryInsertJobOperator
from airflow.providers.google.cloud.operators.bigquery import BigQueryExecuteQueryOperator
from airflow.operators.python import PythonOperator
from airflow.operators.empty import EmptyOperator
from datetime import datetime
import pandas as pd
from faker import Faker
import random
from google.cloud import storage
import io

# Configuration
PROJECT_ID ="<your-project-id>"
BUCKET_NAME = "<your-bucket-name>"
GCS_PATH = "<your-gcs-path>"
BIGQUERY_DATASET = "<your-bigquery-dataset>"
BIGQUERY_TABLE = "<your-bigquery-table>"
TRANSFORMED_TABLE = "<your-transformed-table>"

# schema definition
schema_fields = [
                    {"name": "order_id", "type": "INTEGER", "mode": "REQUIRED"},
                    {"name": "customer_name", "type": "STRING", "mode": "NULLABLE"},
                    {"name": "order_amount", "type": "FLOAT", "mode": "NULLABLE"},
                    {"name": "order_date", "type": "DATE", "mode": "NULLABLE"},
                    {"name": "product", "type": "STRING", "mode": "NULLABLE"},
                ]


# Function to generate sales data and upload to GCS
def generate_and_upload_sales_data(bucket_name, gcs_path, num_orders=500):
    fake = Faker()
    data = {
        "order_id": [i for i in range(1, num_orders + 1)],
        "customer_name": [fake.name() for _ in range(num_orders)],
        "order_amount": [round(random.uniform(10.0, 1000.0), 2) for _ in range(num_orders)],
        "order_date": [fake.date_between(start_date='-30d', end_date='today') for _ in range(num_orders)],
        "product": [fake.word() for _ in range(num_orders)],
    }
    
    df = pd.DataFrame(data)

    # Convert to CSV
    csv_buffer = io.StringIO()
    df.to_csv(csv_buffer, index=False)
    csv_data = csv_buffer.getvalue()

    # Upload to GCS
    client = storage.Client()
    bucket = client.bucket(bucket_name)
    blob = bucket.blob(gcs_path)
    blob.upload_from_string(csv_data, content_type='text/csv')
    print(f"Data uploaded to gs://{bucket_name}/{gcs_path}")

# Default arguments
default_args = {
    "start_date": datetime(2024, 11, 18),
    "catchup": False,
}

# DAG definition
with DAG(
    "sales_orders_to_bigquery_with_transformation",
    default_args=default_args,
    schedule_interval=None,  # Trigger manually or as needed
) as dag:
    
    start_task = EmptyOperator(task_id="start")
    end_task = EmptyOperator(task_id="end")

    # Task 2: Generate sales data and upload to GCS
    generate_sales_data = PythonOperator(
        task_id="generate_sales_data",
        python_callable=generate_and_upload_sales_data,
        op_kwargs={
            "bucket_name": BUCKET_NAME,
            "gcs_path": GCS_PATH,
            "num_orders": 500,  # Number of orders to generate
        },
    )

    # Task 3: Load data from GCS to BigQuery
    load_to_bigquery = BigQueryInsertJobOperator(
        task_id="load_to_bigquery",
        configuration={
            "load": {
                "sourceUris": [f"gs://{BUCKET_NAME}/{GCS_PATH}"],
                "destinationTable": {
                    "projectId": PROJECT_ID,
                    "datasetId": BIGQUERY_DATASET,
                    "tableId": BIGQUERY_TABLE,
                },
                "sourceFormat": "CSV",
                "writeDisposition": "WRITE_APPEND",
                "skipLeadingRows": 1,  # Skip CSV header row
                "schema": {
                    "fields": schema_fields,
                },
            }
        },
    )

    # categorize orders by amount
    transform_bq_qry =f"""
                        SELECT 
                            order_id,
                            customer_name,
                            order_amount,
                            CASE
                                WHEN order_amount < 100 THEN 'Small'
                                WHEN order_amount BETWEEN 100 AND 500 THEN 'Medium'
                                ELSE 'Large'
                            END AS order_category,
                            order_date,
                            product,
                            CURRENT_TIMESTAMP() AS load_timestamp
                        FROM `{PROJECT_ID}.{BIGQUERY_DATASET}.{BIGQUERY_TABLE}`
                    """
    
    # Transform BigQuery Data
    transform_bq_data= BigQueryExecuteQueryOperator(
        task_id="transform_bigquery_data",
        sql=transform_bq_qry,
        destination_dataset_table=f"{PROJECT_ID}.{BIGQUERY_DATASET}.{TRANSFORMED_TABLE}",
        write_disposition="WRITE_TRUNCATE",
        use_legacy_sql=False,
    )

    # categorize orders by amount
    transform_bq_qry_2 =f"""
                        SELECT 
                            tbl_1.*,
                            CURRENT_TIMESTAMP() AS load_timestamp
                        FROM `{PROJECT_ID}.{BIGQUERY_DATASET}.{BIGQUERY_TABLE}` tbl_1
                        WHERE 1=1
                        AND tbl_1.order_amount >=500
                    """

    large_order_data= BigQueryExecuteQueryOperator(
        task_id="large_order_data",
        sql=transform_bq_qry_2,
        destination_dataset_table=f"{PROJECT_ID}.{BIGQUERY_DATASET}.large_orders",
        write_disposition="WRITE_TRUNCATE",
        use_legacy_sql=False,
    )

    # Task dependencies
    (
        start_task
        >> generate_sales_data
        >> load_to_bigquery
        >> transform_bq_data
        >> large_order_data
        >> end_task

    )