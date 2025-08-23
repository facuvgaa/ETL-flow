output "redshift_secret_arn" {
  value = aws_secretsmanager_secret.redshift_secret.arn
}