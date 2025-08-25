output "redshift_secret_arn" {
  value = aws_secretsmanager_secret.redshift_secret.arn
}

output "redshift_secret_arn" {
  value = aws_secretsmanager_secret.redshift_secret.arn
}

output "aws_access_key_id" {
  value = aws_iam_access_key.my_key.id
}

output "aws_secret_access_key" {
  value = aws_iam_access_key.my_key.secret
}

output "glue_job_name" {
  value = aws_glue_job.my_job.name
}

output "glue_copy_job_name" {
  value = aws_glue_job.my_copy_job.name
}

output "openweathermap_api_key" {
  value = var.openweathermap_api_key
}

output "weather_bucket_name" {
  value = aws_s3_bucket.weather_bucket.id
}

output "spotify_client_id" {
  value = var.spotify_client_id
}

output "spotify_client_secret" {
  value = var.spotify_client_secret
}
