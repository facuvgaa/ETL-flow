import os
import json


env_folder = "environment"
os.makedirs(env_folder, exist_ok=True)


with open("terraform_outputs.json") as f:
    outputs = json.load(f)

# -----------------------
# 1️⃣ .airflow.env
# -----------------------
airflow_env = f"""#aws-credentials
AWS_ACCESS_KEY_ID={outputs.get('aws_access_key_id', {}).get('value', '')}
AWS_SECRET_ACCESS_KEY={outputs.get('aws_secret_access_key', {}).get('value', '')}
AWS_DEFAULT_REGION=us-east-1

#jobs-spark
GLUE_JOB_NAME={outputs.get('glue_job_name', {}).get('value', '')}
GLUE_COPY_JOB_NAME={outputs.get('glue_copy_job_name', {}).get('value', '')}
            
#weather-credentials
OPENWEATHERMAP_API_KEY={outputs.get('openweathermap_api_key', {}).get('value', '')}
CITY_DATA=San Miguel de Tucumán #example

#bucket-aws
AWS_WEATHER_BUCKET_NAME={outputs.get('weather_bucket_name', {}).get('value', '')}
AWS_BUCKET_SONG_NAME=songs-spotify

#outputs-etl
ETL_OUTPUT_DIR=output
WEATHER_OUTPUT_DIR=output_weather

#spotify-credentials
CLIENT_ID_SPOTIFY={outputs.get('spotify_client_id', {}).get('value', '')}
CLIENT_SECRET_SPOTIFY={outputs.get('spotify_client_secret', {}).get('value', '')}
TRACK_LIST=2U3UUpx6ocHXgvcXmq0YBw #example
"""

with open(os.path.join(env_folder, ".airflow.env"), "w") as f:
    f.write(airflow_env)

# -----------------------
# 2️⃣ .jupyter.env
# -----------------------
jupyter_env = f"""JUPYTER_TOKEN="{outputs.get('jupyter_token', {}).get('value', 'Abc123')}"
JUPYTER_PASSWORD="{outputs.get('jupyter_password', {}).get('value', 'Abc123')}"
JUPYTER_ENABLE_LAB="yes"
NOTEBOOK_ARGS="--ServerApp.ip=0.0.0.0 --ServerApp.port=8888 --ServerApp.allow_origin='*'"
"""

with open(os.path.join(env_folder, ".jupyter.env"), "w") as f:
    f.write(jupyter_env)

# -----------------------
# 3️⃣ .minio.env
# -----------------------
minio_env = f"""MINIO_ROOT_USER={outputs.get('minio_root_user', {}).get('value', 'MINIO_ROOT_USER')}
MINIO_ROOT_PASSWORD={outputs.get('minio_root_password', {}).get('value', 'MINIO_ROOT_PASSWORD')}
"""

with open(os.path.join(env_folder, ".minio.env"), "w") as f:
    f.write(minio_env)

# -----------------------
# 4️⃣ .mlflow.env
# -----------------------
mlflow_env = f"""MLFLOW_BACKEND_STORE_URI=postgresql+psycopg2://{outputs.get('postgres_user', {}).get('value', 'admin')}:{outputs.get('postgres_password', {}).get('value', 'admin123')}@{outputs.get('postgres_host', {}).get('value', 'postgres')}:5432/{outputs.get('postgres_db', {}).get('value', 'mlflow_db')}
MLFLOW_TRACKING_URI=postgresql+psycopg2://{outputs.get('postgres_user', {}).get('value', 'admin')}:{outputs.get('postgres_password', {}).get('value', 'admin123')}@{outputs.get('postgres_host', {}).get('value', 'postgres')}:5432/{outputs.get('postgres_db', {}).get('value', 'mlflow_db')}
MLFLOW_DEFAULT_ARTIFACT_ROOT=/mlflow/mlruns
MLFLOW_HOST=0.0.0.0
MLFLOW_PORT=5000
"""

with open(os.path.join(env_folder, ".mlflow.env"), "w") as f:
    f.write(mlflow_env)

# -----------------------
# 5️⃣ .postgrest.env
# -----------------------
postgrest_env = f"""POSTGRES_USER={outputs.get('postgres_user', {}).get('value', 'admin')}
POSTGRES_PASSWORD={outputs.get('postgres_password', {}).get('value', 'admin123')}
POSTGRES_DB={outputs.get('postgres_db', {}).get('value', 'mlflow_db')}
POSTGRES_HOST={outputs.get('postgres_host', {}).get('value', 'postgres')}
POSTGRES_PORT=5432
"""

with open(os.path.join(env_folder, ".postgrest.env"), "w") as f:
    f.write(postgrest_env)

print(f"Se generaron los 5 archivos .env dentro de la carpeta '{env_folder}' ✅")
