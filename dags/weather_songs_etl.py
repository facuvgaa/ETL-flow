import pendulum
from datetime import timedelta
from airflow.decorators import dag, task
from airflow.providers.amazon.aws.operators.glue import GlueJobOperator
from track_flow.main import run_tracks_etl
from facu_weather_flow.main import run_weather_pipeline
import os

@dag(
    dag_id="dag_extractar_guardar_y_subir",
    schedule="@daily",
    start_date=pendulum.datetime(2025, 6, 24, tz="America/Argentina/Tucuman"),
    catchup=False,
    default_args={"retries": 1, "retry_delay": timedelta(minutes=5)},
    tags=["etl"]
)
def dag_extract_save_s3():

    @task()
    def run_tracks_etl_task():
        run_tracks_etl()

    @task()
    def run_weather_etl_task():
        run_weather_pipeline()

    tracks_task = run_tracks_etl_task()
    weather_task = run_weather_etl_task()

    glue_join_task = GlueJobOperator(
        task_id='glue_join_task',
        job_name=os.getenv("GLUE_JOB_NAME"), 
        region_name=os.getenv("AWS_DEFAULT_REGION"),
        wait_for_completion=True,
        verbose=True
    )

    glue_copy_task = GlueJobOperator(
        task_id='glue_copy_task',
        job_name=os.getenv("GLUE_COPY_JOB_NAME"), 
        region_name=os.getenv("AWS_DEFAULT_REGION"),
        wait_for_completion=True,
        verbose=True
    )

    [tracks_task, weather_task] >> glue_join_task >> glue_copy_task

etl_dag = dag_extract_save_s3()
