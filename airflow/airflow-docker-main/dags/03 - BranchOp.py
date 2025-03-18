from airflow import DAG
from airflow.operators.python import BranchPythonOperator
from airflow.operators.bash import BashOperator
from datetime import datetime

def choose_branch():
    return "task_1" if datetime.now().second % 2 == 0 else "task_2"

default_args = {"start_date": datetime(2024, 3, 18)}

with DAG("branching_dag", schedule_interval="@daily", default_args=default_args, catchup=False) as dag:
    branch_task = BranchPythonOperator(
        task_id="branching",
        python_callable=choose_branch
    )

    task_1 = BashOperator(task_id="task_1", bash_command="echo 'Task 1 executed'")
    task_2 = BashOperator(task_id="task_2", bash_command="echo 'Task 2 executed'")

    branch_task >> [task_1, task_2]
