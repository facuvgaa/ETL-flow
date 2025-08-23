import sys
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from pyspark.sql.functions import to_date, col, date_format

# Parámetros que recibe el job
args = getResolvedOptions(sys.argv, ['JOB_NAME', 'S3_OUTPUT', 'S3_TRACKS', 'S3_WEATHER'])

sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

# Carga datasets parquet desde los buckets indicados
df_weather = spark.read.parquet(args['S3_WEATHER'])
df_tracks = spark.read.parquet(args['S3_TRACKS'])

# Debug prints iniciales
print("Weather count:", df_weather.count())
print("Tracks count:", df_tracks.count())

print("Distinct dates Weather:")
df_weather.select("date").distinct().show(10, False)

print("Distinct dates Tracks:")
df_tracks.select("date").distinct().show(10, False)

# Normalización de la columna date
df_weather = df_weather.withColumn("date", to_date(col("date"), "yyyy-MM-dd"))
df_tracks = df_tracks.withColumn("date", to_date(col("date"), "dd/MM/yy"))

# Opcional: volver a string en mismo formato para join por string (no obligatorio si las dos son DateType)
df_weather = df_weather.withColumn("date", date_format(col("date"), "yyyy-MM-dd"))
df_tracks = df_tracks.withColumn("date", date_format(col("date"), "yyyy-MM-dd"))

# Verificar fechas comunes después de normalizar
common_dates = df_weather.select("date").intersect(df_tracks.select("date"))
print("Common dates count:", common_dates.count())
common_dates.show(10, False)

# Join inner por date
df_joined = df_weather.join(df_tracks, "date", "inner")

print("Filas join:")
print(df_joined.count())

df_joined.show(20, False)

# Guardar resultado parquet en S3_OUTPUT
df_joined.write.mode("overwrite").parquet(args['S3_OUTPUT'])

job.commit()
