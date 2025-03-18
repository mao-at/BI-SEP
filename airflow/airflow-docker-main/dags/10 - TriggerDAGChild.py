from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime

def read_config(**kwargs):
    message = kwargs["dag_run"].conf.get("message", "No message received")
    print(f"Received config: {message}")

default_args = {"start_date": datetime(2024, 3, 18)}

with DAG("child_dag", schedule_interval=None, default_args=default_args, catchup=False) as dag:
    process_config = PythonOperator(
        task_id="process_config",
        python_callable=read_config
    )
