from airflow import DAG
from airflow.operators.bash import BashOperator
from datetime import datetime

default_args = {"start_date": datetime(2024, 3, 18)}

with DAG("dynamic_tasks_dag", schedule_interval="@daily", default_args=default_args, catchup=False) as dag:
    for i in range(5):
        BashOperator(
            task_id=f"task_{i}",
            bash_command=f"echo Task {i} executed"
        )
