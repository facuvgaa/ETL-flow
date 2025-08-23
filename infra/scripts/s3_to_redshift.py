import sys
from awsglue.utils import getResolvedOptions
import boto3
import redshift_connector

args = getResolvedOptions(sys.argv, [
    'redshift_host',
    'redshift_database',
    'redshift_user',
    'redshift_password',
    'redshift_port',
    's3_bucket',
    'iam_role_arn',
])

redshift_host = args['redshift_host']
redshift_database = args['redshift_database']
redshift_user = args['redshift_user']
redshift_password = args['redshift_password']
redshift_port = int(args['redshift_port'])
s3_bucket = args['s3_bucket']
iam_role_arn = args['iam_role_arn']

# SQL definido aquí mismo sin pasar como parámetro
create_table_sql = """
CREATE TABLE IF NOT EXISTS public.weather_tracks (
    date VARCHAR,
    ciudad VARCHAR,
    pais VARCHAR,
    temperatura BIGINT,
    velocidad_viento DOUBLE PRECISION,
    sensacion_termica DOUBLE PRECISION,
    humedad BIGINT,
    timestamp BIGINT,
    name VARCHAR,
    artist VARCHAR,
    album VARCHAR,
    id VARCHAR,
    duration_ms BIGINT
);
"""

# Listar archivos parquet en la carpeta 'parquets/'
s3 = boto3.client('s3')
prefix = 'parquets/'

response = s3.list_objects_v2(Bucket=s3_bucket, Prefix=prefix)

parquet_file = None
if 'Contents' in response:
    for obj in response['Contents']:
        key = obj['Key']
        if key.endswith('.parquet') and 'part-' in key:
            parquet_file = key
            break

if parquet_file is None:
    raise Exception(f"No se encontró archivo parquet en s3://{s3_bucket}/{prefix}")

parquet_s3_path = f"s3://{s3_bucket}/{parquet_file}"



copy_sql = f"""
COPY public.weather_tracks
FROM '{parquet_s3_path}'
IAM_ROLE '{iam_role_arn}'
FORMAT AS PARQUET;
"""


print("Conectando a Redshift...")
conn = redshift_connector.connect(
    host=redshift_host,
    database=redshift_database,
    user=redshift_user,
    password=redshift_password,
    port=redshift_port,
)

cursor = conn.cursor()

print("Ejecutando CREATE TABLE...")
cursor.execute(create_table_sql)
conn.commit()

print(f"Ejecutando COPY desde {parquet_s3_path}...")
cursor.execute(copy_sql)
conn.commit()

cursor.close()
conn.close()
print("Proceso completado correctamente.")
