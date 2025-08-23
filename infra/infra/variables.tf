variable "aws_region"{
    description = "AWS region"
    type = string
}

variable "s3_weather_bucket"{
    description = "wathet bucket" 
    type = string
}

variable "s3_songs_bucket"{
    description = "bucket songs"
    type = string
}

variable "s3_songs_and_weather_bucket"{
    description = "wathet and songs bucket"
    type = string

}

variable "gluejob_bind"{
    description = "job bind songs and wather"
    type = string
}

variable "gluejob_copy"{
    description = "copy information to s3 bind"
    type = string
}

variable "s3_scripts_bucket"{
    description = "scripts for jobs"
    type = string
}

variable "redshift_cluster_name"{
    description = "redshift cluster song and weather"
}

variable "redshift_sg"  {
  description = "Nombre del Security Group para Redshift"
  type        = string
}

variable "iam_role_glue" {
    description = "role glue to s3"
    type = string
}

variable "iam_role_glue_to_redshift" {
    description = "role redshift cluster"
    type =string
}


variable "redshift_username" {
  description = "Usuario maestro de Redshift"
  type        = string
  default     = "admin"
}

variable "redshift_password" {
  description = "Password maestro de Redshift"
  type        = string
  sensitive   = true
}

variable "redshift_database" {
  description = "database redshift"
  type = string

}