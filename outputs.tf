output "db_endpoint" {
  description = "Endpoint de conexión"
  value       = aws_db_instance.this.endpoint
}

output "db_port" {
  description = "Puerto de conexión"
  value       = aws_db_instance.this.port
}

output "db_name" {
  description = "Nombre de la DB"
  value       = aws_db_instance.this.db_name
}

output "db_instance_arn" {
  description = "ARN de la instancia"
  value       = aws_db_instance.this.arn
}

output "db_secret_arn" {
  description = "ARN del secreto en Secrets Manager"
  value       = aws_db_instance.this.master_user_secret[0].secret_arn
}