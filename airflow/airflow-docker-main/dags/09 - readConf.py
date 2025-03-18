from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime

def read_trigger_config(**kwargs):
    config = kwargs.get("dag_run").conf if kwargs.get("dag_run") else {}
    
    param1 = config.get("param1", "default_value1")
    param2 = config.get("param2", "default_value2")

    print(f"Received Config - param1: {param1}, param2: {param2}")

default_args = {"start_date": datetime(2024, 3, 18)}

with DAG("read_trigger_config_dag", schedule_interval=None, default_args=default_args, catchup=False) as dag:
    read_config_task = PythonOperator(
        task_id="read_trigger_config_task",
        python_callable=read_trigger_config,
        provide_context=True
    )
