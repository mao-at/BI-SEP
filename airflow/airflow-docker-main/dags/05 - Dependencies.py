from airflow import DAG
from airflow.operators.dummy import DummyOperator
from datetime import datetime

default_args = {"start_date": datetime(2024, 3, 18)}

with DAG("dependencies_dag", schedule_interval="@daily", default_args=default_args, catchup=False) as dag:
    start = DummyOperator(task_id="start")
    task_1 = DummyOperator(task_id="task_1")
    task_2 = DummyOperator(task_id="task_2")
    end = DummyOperator(task_id="end")

    start >> [task_1, task_2] >> end
