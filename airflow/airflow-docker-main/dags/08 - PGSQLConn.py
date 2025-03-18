from airflow import DAG
from airflow.providers.postgres.operators.postgres import PostgresOperator
from datetime import datetime

default_args = {"start_date": datetime(2024, 3, 18)}

with DAG("postgres_dag", schedule_interval="@daily", default_args=default_args, catchup=False) as dag:
    task = PostgresOperator(
        task_id="create_table",
        postgres_conn_id="my_postgres_conn",
        sql="CREATE TABLE IF NOT EXISTS airflow_test (id SERIAL PRIMARY KEY, name TEXT);"
    )
