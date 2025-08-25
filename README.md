# Airflow Song & Weather Flow 🎶🌦️

## 🇪🇸 Descripción (Español)

Este proyecto implementa un **pipeline de datos completo**, desde la ingesta hasta el entrenamiento de modelos de Machine Learning, todo orquestado con **Apache Airflow** y desplegado en **AWS con Terraform**.  

Además, un entorno de **Jupyter Notebook dockerizado** permite consumir datos desde **Amazon Redshift**, entrenar modelos y registrarlos en **MLflow**.

---

## 🚀 Componentes principales

1. **Infraestructura (Terraform)**
   - Crea en AWS:
     - Buckets de **S3** para data lake.
     - **Glue jobs** para unión y migración a Redshift.
     - **Redshift Cluster** para data warehouse.
     - Roles y políticas de **IAM**.
     - **Secrets Manager** para credenciales seguras.

2. **Orquestación de ETLs (Airflow)**
   - Pipelines que:
     - **Extraen** datos de clima usando la API de [OpenWeatherMap](https://openweathermap.org/) (**requiere API key**) a través de [`facu-weather-flow`](https://pypi.org/project/facu-weather-flow/).  
     - **Extraen** datos de Spotify (**requiere Client ID, Client Secret y ID de la playlist a extraer**) a través de [`track-flow`](https://pypi.org/project/track-flow/).  
     - **Transforman** los datos a formato **Parquet**.
     - **Cargan** en **S3** y **Redshift**.

3. **Entrenamiento de Modelos (Jupyter + MLflow)**
   - Jupyter Notebook se conecta a **Redshift**.
   - Se entrenan modelos de Machine Learning.
   - Los modelos se registran en **MLflow Tracking Server** (dockerizado).

---

## 🛠️ Tecnologías

- Apache Airflow, Terraform, AWS (S3, Redshift, Glue, Secrets Manager)  
- MLflow, Jupyter Notebook  
- Docker & docker-compose  
- Spark jobs y Python jobs  
- Librerías personalizadas: [`facu-weather-flow`](https://pypi.org/project/facu-weather-flow/), [`track-flow`](https://pypi.org/project/track-flow/)

## 📂 Estructura

```bash
├── ansible/              # Playbooks y roles de Ansible
├── dags/                 # DAGs y configuración de Airflow
├── infra/                # Infraestructura como código (Terraform)
├── mlflow/               # Configuración de MLflow para experiment tracking
├── docker-compose.yml    # Orquestación local con Docker Compose
├── flow.excalidraw       # Diagrama del flujo del proyecto
├── generate_env.py       # Script para generar archivos .env automáticamente
├── install.sh            # Instalador de dependencias básicas (Docker, Compose, Make)
├── requirements.txt      # Dependencias de Python
└── README.md             # Documentación principal
```

# 1. Instalar dependencias básicas (Docker, Docker Compose y Make)
```bash
./install.sh
```
# 2. Configurar variables de entorno

 ### Copiar el archivo de ejemplo a .env
```bash
cp infra/.example.env infra/.env
```

 ## Editar infra/.example.env y poner al menos tus credenciales de AWS, las credenciles de  Openweathermap , credenciales spotify, junto con el chart para extraer info de spotify: 
```bash
# AWS_ACCESS_KEY_ID=your_access_key
# AWS_SECRET_ACCESS_KEY=your_secret_key
# AWS_DEFAULT_REGION=us-east-1

OPENWEATHERMAP_API_KEY=
CITY_DATA=Tucuman,AR


#spotify api

CLIENT_ID_SPOTIFY=
CLIENT_SECRET_SPOTIFY=
TRACK_LIST=2U3UUpx6ocHXgvcXmq0YBw

```


# 3. Levantar la infraestructura con Terraform (vía Docker + Make)
```bash
# Inicializar Terraform
make infra

# Revisar el plan de ejecución
make plan

# Aplicar cambios (crear la infraestructura en AWS)
make apply
```

# 4. Levantar Airflow y MLflow (Docker local)

```bash
# Levantar Airflow
docker-compose up -d airflow

# Acceder a Airflow: http://localhost:8080

# Levantar MLflow
docker-compose up -d mlflow

# Acceder a MLflow: http://localhost:5000
```

# 5. Ejecutar DAGs y entrenar modelos

1. Airflow detectará los DAGs dentro de dags/.

2. Ejecutar los DAGs desde UI o CLI.

3. Los datos se cargarán en S3 y Redshift.

4. Abrir Jupyter Notebook y entrenar modelos conectándose a Redshift.

5. Registrar modelos en MLflow.


6. Notas finales

Proyecto pensado para pruebas locales y despliegue en AWS.

Recomendado Python 3.12.

Mantener librerías actualizadas:

