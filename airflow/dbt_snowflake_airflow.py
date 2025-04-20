from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.empty import EmptyOperator
from airflow.utils.task_group import TaskGroup
from datetime import datetime

PROJECT_DIR = '<project_location>'
PROFILES_DIR = '~/.dbt'

# Default args for the DAG
default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'retries': 1,
}

# Define the DAG
with DAG(
    'dbt_snowflake_pipeline',
    default_args=default_args,
    description='A simple pipeline to run dbt commands on Snowflake',
    schedule_interval='@daily',  # Trigger manually or set your schedule
    start_date=datetime(2024, 11, 15),
    catchup=False,
) as dag:
    
    # dag to signify start of execution
    start = EmptyOperator(task_id='start_dag')

    # TaskGroup to  group and run together all dbt related tasks
    with TaskGroup(group_id='dbt_tasks') as dbt_tasks:
        # Task to run dbt debug
        dbt_debug = BashOperator(
            task_id='dbt_debug',
            bash_command=f'dbt debug --profiles-dir {PROFILES_DIR} --project-dir {PROJECT_DIR}',
        )

        # Task to run dbt run
        dbt_run = BashOperator(
            task_id='dbt_run',
            bash_command=f'dbt run --profiles-dir {PROFILES_DIR} --project-dir {PROJECT_DIR} --select airflow',
        )
        # Task to run dbt test
        dbt_test = BashOperator(
            task_id='dbt_test',
            bash_command=f'dbt test --profiles-dir {PROFILES_DIR} --project-dir {PROJECT_DIR} --select airflow',
        )

        dbt_debug >> dbt_run >> dbt_test

    # end dag
    end = EmptyOperator(task_id='end_dag')

    # Define task dependencies
    start >> dbt_tasks >> end
