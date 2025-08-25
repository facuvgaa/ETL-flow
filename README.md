# Airflow Song & Weather Flow 🎶🌦️

## 🇪🇸 Descripción (Español)

Este proyecto implementa un **pipeline de datos completo**, desde la ingesta hasta el entrenamiento de modelos de Machine Learning, todo orquestado con **Apache Airflow** y desplegado en **AWS con Terraform**.  

Además, un entorno de **Jupyter Notebook dockerizado** permite consumir datos desde **Amazon Redshift**, entrenar modelos y registrarlos en **MLflow**.

### 🚀 Componentes principales

1. **Infraestructura (Terraform)**
   - Crea en AWS:
     - Buckets de **S3** para data lake.
     - **Glue jobs** para union y migracion a redshift.
     - **Redshift Cluster** para data warehouse.
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
- spark jobs y python jobs
- Librerías personalizadas: `facu-weather-flow`, `facu-music-flow`

### 📂 Estructura

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
**Editar infra/.example.env y poner al menos tus credenciales de AWS: **
```bash
# AWS_ACCESS_KEY_ID=your_access_key
# AWS_SECRET_ACCESS_KEY=your_secret_key
# AWS_DEFAULT_REGION=us-east-1
```
```bash
# Copiar el archivo de ejemplo a .env
cp infra/.example.env infra/.env
```

# 3. Levantar la infraestructura con Terraform (vía Docker + Make)
```bash
# Inicializar Terraform
make infra

# Revisar el plan de ejecución
make plan

# Aplicar cambios (crear la infraestructura en AWS)
make apply
``

