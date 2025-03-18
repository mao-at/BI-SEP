from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime

def push_xcom(**kwargs):
    kwargs["ti"].xcom_push(key="message", value="Hello from task 1!")

def pull_xcom(**kwargs):
    message = kwargs["ti"].xcom_pull(task_ids="push_task", key="message")
    print(f"Received message: {message}")

default_args = {"start_date": datetime(2024, 3, 18)}

with DAG("xcom_example_dag", schedule_interval="@daily", default_args=default_args, catchup=False) as dag:
    push_task = PythonOperator(task_id="push_task", python_callable=push_xcom)
    pull_task = PythonOperator(task_id="pull_task", python_callable=pull_xcom)

    push_task >> pull_task
