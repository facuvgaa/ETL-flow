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

## 5. 🚀 Ejecutar DAGs y entrenar modelos

1. 📂 Airflow detectará automáticamente los DAGs dentro de `dags/`.
2. ▶️ Ejecutar los DAGs desde la **UI** o **CLI**.
3. 💾 Los datos se cargarán en **S3** y **Redshift**.
4. 📝 Abrir **Jupyter Notebook** y entrenar modelos conectándose a **Redshift**.
5. 🏷️ Registrar los modelos entrenados en **MLflow**.

---

## 6. 📝 Notas finales

- 🖥️ Proyecto pensado para **pruebas locales** y despliegue en **AWS**.
- 🐍 Recomendado **Python 3.12**.
- 📦 Mantener librerías actualizadas:
- 
# ETL Flow Dashboard

Este proyecto muestra un **pipeline completo** orquestado con **Airflow** y registrado en **MLflow**:

## Airflow
![Airflow](docs/airflow.png)

## MLflow
![MLflow](docs/mlflow.png)


# Airflow Song & Weather Flow 🎶🌦️

## 🇺🇸 Description (English)

This project implements a **full data pipeline**, from ingestion to Machine Learning model training, all orchestrated with **Apache Airflow** and deployed on **AWS with Terraform**.  

Additionally, a **dockerized Jupyter Notebook** environment allows consuming data from **Amazon Redshift**, training models, and registering them in **MLflow**.

---

## 🚀 Main Components

1. **Infrastructure (Terraform)**
   - Creates on AWS:
     - **S3 buckets** for data lake.
     - **Glue jobs** for merging and migrating to Redshift.
     - **Redshift Cluster** as a data warehouse.
     - **IAM roles** and policies.
     - **Secrets Manager** for secure credentials.

2. **ETL Orchestration (Airflow)**
   - Pipelines that:
     - **Extract** weather data using the [OpenWeatherMap API](https://openweathermap.org/) (**requires API key**) via [`facu-weather-flow`](https://pypi.org/project/facu-weather-flow/).  
     - **Extract** Spotify data (**requires Client ID, Client Secret, and playlist ID**) via [`track-flow`](https://pypi.org/project/track-flow/).  
     - **Transform** data into **Parquet** format.
     - **Load** into **S3** and **Redshift**.

3. **Model Training (Jupyter + MLflow)**
   - Jupyter Notebook connects to **Redshift**.
   - Train Machine Learning models.
   - Register trained models in the **MLflow Tracking Server** (dockerized).

---

## 🛠️ Technologies

- Apache Airflow, Terraform, AWS (S3, Redshift, Glue, Secrets Manager)  
- MLflow, Jupyter Notebook  
- Docker & docker-compose  
- Spark jobs and Python jobs  
- Custom libraries: [`facu-weather-flow`](https://pypi.org/project/facu-weather-flow/), [`track-flow`](https://pypi.org/project/track-flow/)

---

## 📂 Project Structure

```bash
├── ansible/              # Ansible playbooks and roles
├── dags/                 # DAGs and Airflow configuration
├── infra/                # Infrastructure as code (Terraform)
├── mlflow/               # MLflow experiment tracking configuration
├── docker-compose.yml    # Local orchestration with Docker Compose
├── flow.excalidraw       # Project flow diagram
├── generate_env.py       # Script to generate .env files automatically
├── install.sh            # Installer for basic dependencies (Docker, Compose, Make)
├── requirements.txt      # Python dependencies
└── README.md             # Main documentation
```
1. Install Basic Dependencies (Docker, Docker Compose, Make)
```bash
./install.sh
```

2. Configure Environment Variables
Copy example file to .env

# Edit infra/.env and add at least your credentials:

```bash
# AWS
AWS_ACCESS_KEY_ID=your_access_key
AWS_SECRET_ACCESS_KEY=your_secret_key
AWS_DEFAULT_REGION=us-east-1

# OpenWeatherMap API
OPENWEATHERMAP_API_KEY=your_api_key
CITY_DATA=Tucuman,AR

# Spotify API
CLIENT_ID_SPOTIFY=your_client_id
CLIENT_SECRET_SPOTIFY=your_client_secret
TRACK_LIST=2U3UUpx6ocHXgvcXmq0YBw

```
# 3. Launch Infrastructure with Terraform (via Docker + Make)

```bash
# Initialize Terraform
make infra

# Review execution plan
make plan

# Apply changes (create infrastructure on AWS)
make apply
```
# 4. Launch Airflow and MLflow (Local Docker)

```bash
# Start Airflow
docker-compose up -d airflow

# Access Airflow: http://localhost:8080

# Start MLflow
docker-compose up -d mlflow

# Access MLflow: http://localhost:5000
```
# 5. 🚀 Run DAGs and Train Models

1. 📂 Airflow will automatically detect DAGs inside dags/.

2. ▶️ Run DAGs from the UI or CLI.

3. 💾 Data will be loaded into S3 and Redshift.

4. 📝 Open Jupyter Notebook and train models connecting to Redshift.

5. 🏷️ Register trained models in MLflow.

# 6. 📝 Final Notes

🖥️ Project is designed for local testing and deployment on AWS.

🐍 Recommended Python 3.12.

📦 Keep libraries up to date:

# ETL Flow Dashboard

This project showcases a **full pipeline** orchestrated with **Airflow** and tracked in **MLflow**:

## Airflow
![Airflow](docs/airflow.png)

## MLflow
![MLflow](docs/mlflow.png)


