from airflow import DAG
from airflow.operators.bash import BashOperator
from datetime import datetime

default_args = {"start_date": datetime(2024, 3, 18)}

with DAG("basic_bash_dag", schedule_interval="@daily", default_args=default_args, catchup=False) as dag:
    task = BashOperator(
        task_id="print_date",
        bash_command="date"
    )
