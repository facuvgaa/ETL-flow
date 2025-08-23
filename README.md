# Airflow Song & Weather Flow 🎶🌦️

## 🇪🇸 Descripción (Español)

Este proyecto implementa un **pipeline de datos completo**, desde la ingesta hasta el entrenamiento de modelos de Machine Learning, todo orquestado con **Apache Airflow** y desplegado en **AWS con Terraform**.  

Además, un entorno de **Jupyter Notebook dockerizado** permite consumir datos desde **Amazon Redshift**, entrenar modelos y registrarlos en **MLflow**.

### 🚀 Componentes principales

1. **Infraestructura (Terraform)**
   - Crea en AWS:
     - Buckets de **S3** para data lake.
     - **Redshift Cluster** para data warehouse.
     - **Glue Catalog** para metadatos.
     - Roles y políticas de **IAM**.
     - **Secrets Manager** para credenciales seguras.

2. **Orquestación de ETLs (Airflow)**
   - Pipelines que:
     - **Extraen** datos de clima ([`facu-weather-flow`](https://pypi.org/project/facu-weather-flow/)) y de Spotify ([`facu-music-flow`](https://pypi.org/project/facu-music-flow/)).
     - **Transforman** los datos a formato **Parquet**.
     - **Cargan** en **S3** y **Redshift**.

3. **Entrenamiento de Modelos (Jupyter + MLflow)**
   - Jupyter Notebook se conecta a **Redshift**.
   - Se entrenan modelos de Machine Learning.
   - Los modelos se registran en **MLflow Tracking Server** (dockerizado).

### 🛠️ Tecnologías

- Apache Airflow, Terraform, AWS (S3, Redshift, Glue, Secrets Manager)  
- MLflow, Jupyter Notebook  
- Docker & docker-compose  
- Librerías personalizadas: `facu-weather-flow`, `facu-music-flow`

### 📂 Estructura

```bash
├── ansible/              # 
├── dags/                 # DAGs y configuración de Airflow
├── notebooks/            # Notebooks para entrenar modelos
├── docker-compose.yml    # Orquestación local
├── .env                  # Variables de entorno
└── README.md
