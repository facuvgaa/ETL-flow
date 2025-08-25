resource "aws_s3_bucket" "spotify"{
    bucket = var.s3_weather_bucket

    tags = {
        name = "weather-bucket"
        Environment= "dev"
        
    }
}

resource "aws_s3_bucket" "weather"{
    bucket = var.s3_songs_bucket

    tags = {
        name = "songs-bucket"
        Environment = "dev"
    }   
}

resource "aws_s3_bucket" "joined"{
    bucket = var.s3_songs_and_weather_bucket

    tags={

        name = "songs-weather-joined"
        Environment = "dev"
    }
}

locals {
  scripts = fileset("${path.module}/../scripts", "*.py")
}
resource "aws_s3_bucket" "scripts_for_job" {
  bucket = var.s3_scripts_bucket
  tags = {
    name = "scripts-for-jobs"
    Environment = "dev"
  }
}

resource "aws_s3_object" "scripts_for_job" {
  for_each = { for file in local.scripts : file => file }

  bucket = aws_s3_bucket.scripts_for_job.bucket
  key    = "scripts/${each.value}"                    # ruta dentro del bucket
  source = "${path.module}/../scripts/${each.value}"  # ruta local
  etag   = filemd5("${path.module}/../scripts/${each.value}")
}


#-----------fin-bucket------------------------#

#----------iam-roles-------------------------#

resource "aws_iam_role" "glue_role" {
  name = var.iam_role_glue

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "glue.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# 🔹 Adjuntar políticas administradas por AWS
resource "aws_iam_role_policy_attachment" "redshift_access" {
  role       = aws_iam_role.glue_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRedshiftFullAccess"
}

resource "aws_iam_role_policy_attachment" "s3_full_access" {
  role       = aws_iam_role.glue_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "s3_readonly" {
  role       = aws_iam_role.glue_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "glue_service" {
  role       = aws_iam_role.glue_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_iam_role_policy_attachment" "cloudwatch_logs" {
  role       = aws_iam_role.glue_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_policy" "secrets_manager_custom" {
  name        = "GlueSecretsManagerAccess"
  description = "Permite a Glue leer secretos necesarios"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "secrets_manager_custom_attach" {
  role       = aws_iam_role.glue_role.name
  policy_arn = aws_iam_policy.secrets_manager_custom.arn
}

# 1️⃣ Crear el rol de Glue
resource "aws_iam_role" "glue_redshift_job_role" {
  name = var.iam_role_glue_to_redshift

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "glue.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "redshift_full_access" {
  role       = aws_iam_role.glue_redshift_job_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRedshiftFullAccess"
}

resource "aws_iam_role_policy_attachment" "s3_full_access_glue" {
  role       = aws_iam_role.glue_redshift_job_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "glue_console_access" {
  role       = aws_iam_role.glue_redshift_job_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSGlueConsoleFullAccess"
}

resource "aws_iam_role_policy_attachment" "glue_service_role" {
  role       = aws_iam_role.glue_redshift_job_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_iam_role_policy_attachment" "kms_power_user" {
  role       = aws_iam_role.glue_redshift_job_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSKeyManagementServicePowerUser"
}

resource "aws_iam_role_policy_attachment" "secretsmanager_rw" {
  role       = aws_iam_role.glue_redshift_job_role.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

#----------------FIN ROLES IAM----------------#

#----------------inicio-redshift-vpc-sg---------#

## ----------------------------------------
# 1️⃣ VPC existente (usar default)
# ----------------------------------------
data "aws_vpc" "main" {
  default = true
}

# ----------------------------------------
# 2️⃣ Subnet para Redshift y Glue
# ----------------------------------------
resource "aws_subnet" "redshift_subnet" {
  vpc_id                  = data.aws_vpc.main.id
  cidr_block              = "172.31.100.0/24"
  availability_zone       = "us-east-1c"
  map_public_ip_on_launch = true

  tags = {
    Name = "redshift-subnet"
  }
}

# ----------------------------------------
# 3️⃣ Security Group de Redshift
# ----------------------------------------
resource "aws_security_group" "redshift_sg" {
  name        = "redshift-sg"
  description = "Acceso a Redshift"
  vpc_id      = data.aws_vpc.main.id

  tags = {
    Name = "Redshift subnet group"
  }
}
# (Tus reglas SG quedan iguales)

# ----------------------------------------
# 4️⃣ Cluster de Redshift
# ----------------------------------------
resource "aws_redshift_subnet_group" "redshift_sg" {
  name       = "redshift-subnet-group"
  subnet_ids = [aws_subnet.redshift_subnet.id]

  tags = {
    Name = "Redshift subnet group"
  }
}

resource "aws_redshift_cluster" "redshift" {
  cluster_identifier      = var.redshift_cluster_name
  database_name           = var.redshift_database
  master_username         = var.redshift_username
  master_password         = var.redshift_password
  node_type               = "ra3.large"
  cluster_type            = "single-node"
  publicly_accessible     = true
  vpc_security_group_ids  = [aws_security_group.redshift_sg.id]
  cluster_subnet_group_name = aws_redshift_subnet_group.redshift_sg.name
  skip_final_snapshot = true
  tags = {
    Name = "redshift-cluster-prueba"
  }

  depends_on = [aws_redshift_subnet_group.redshift_sg]
}

# ----------------------------------------
# 5️⃣ Glue Connection FIX
# ----------------------------------------
resource "aws_glue_connection" "glue_vpc_connection" {
  name            = "glue-vpc-connection"
  connection_type = "NETWORK"

  physical_connection_requirements {
    availability_zone      = aws_subnet.redshift_subnet.availability_zone
    security_group_id_list = [aws_security_group.redshift_sg.id]
    subnet_id              = aws_subnet.redshift_subnet.id
  }
}

resource "aws_secretsmanager_secret" "redshift_secret" {
  name        = "redshift-secret-pruena-etl-v2"
  description = "Redshift cluster credentials"
}

resource "aws_secretsmanager_secret_version" "redshift_secret_version" {
  secret_id     = aws_secretsmanager_secret.redshift_secret.id
  secret_string = jsonencode({
    username = var.redshift_username
    password = var.redshift_password
  })
}

#----------------fin-redshift-vpc-sg------------#
#----------------inicio-glue-spark-glue-python--#
resource "aws_glue_job" "spark_job"{
    name = var.gluejob_bind
    role_arn = aws_iam_role.glue_role.arn

    command{
        name = "glueetl"
        python_version = "3"
        script_location = "s3://${var.s3_scripts_bucket}/scripts/spark_job.py"
    }
    default_arguments = {
        "--job-lenguaje" = "python"
        "--enable-metrics" = "true"
        "--JOB_NAME"   = var.gluejob_bind
        "--S3_OUTPUT"  = "s3://${var.s3_songs_and_weather_bucket}/parquets/"
        "--S3_TRACKS"  = "s3://${var.s3_songs_bucket}/parquets/track_dtos.parquet"
        "--S3_WEATHER" = "s3://${var.s3_weather_bucket}/parquets/weather_dtos.parquet"
    }
    glue_version = "4.0"
    worker_type = "G.1X"
    number_of_workers = 2
    max_retries = 1
    timeout = 10

    tags = {
        Name = "Spark-etl-job"
        Environment = "dev"
    }                        
}

resource "aws_glue_job" "s3_to_redshift_job" {
  name     = "mi-glue-job"
  role_arn = aws_iam_role.glue_redshift_job_role.arn
  command {
    name            = "glueetl"
    script_location = "s3://${var.s3_scripts_bucket}/scripts/s3_to_redshift.py"
    python_version  = "3.9"
  }
  default_arguments = {
    "--iam_role_arn"        = aws_secretsmanager_secret.redshift_secret.arn
    "--redshift_database"   = var.redshift_database
    "--redshift_host"       = var.redshift_database
    "--redshift_password"   = var.redshift_password
    "--redshift_port"       = aws_redshift_cluster.redshift.endpoint
    "--redshift_user"       = var.redshift_username
    "--s3_bucke"            = var.s3_songs_and_weather_bucket
  } 
  connections = [aws_glue_connection.glue_vpc_connection.name]
  max_retries = 1
}
resource "null_resource" "generate_env_files" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command     = "python3 ../generate_env.py"
    working_dir = "${path.module}"  # path.module apunta a infra/ o infra/infra/ según tu caso
  }
}
