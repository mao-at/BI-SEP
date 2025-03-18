from airflow import DAG
from airflow.sensors.external_task import ExternalTaskSensor
from airflow.operators.dummy import DummyOperator
from datetime import datetime, timedelta

default_args = {"start_date": datetime(2024, 3, 18)}

with DAG("external_sensor_dag", schedule_interval="@daily", default_args=default_args, catchup=False) as dag:
    wait_for_dag = ExternalTaskSensor(
        task_id="wait_for_external_dag",
        external_dag_id="basic_bash_dag",
        external_task_id="print_date",
        timeout=600,
        poke_interval=60,
        mode="poke"
    )

    final_task = DummyOperator(task_id="final_task")

    wait_for_dag >> final_task
