from airflow import DAG
from airflow.operators.trigger_dagrun import TriggerDagRunOperator
from datetime import datetime

default_args = {"start_date": datetime(2024, 3, 18)}

with DAG("parent_dag", schedule_interval="@daily", default_args=default_args, catchup=False) as dag:
    trigger_child = TriggerDagRunOperator(
        task_id="trigger_child_dag",
        trigger_dag_id="child_dag",
        conf={"message": "Triggered from parent DAG"}
    )
