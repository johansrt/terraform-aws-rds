variable "project" {
  description = "Nombre del proyecto"
  type        = string
}

variable "env" {
  description = "Entorno (dev, stage, prod)"
  type        = string
}

variable "identifier" {
  description = "Nombre único de la instancia"
  type        = string
}

variable "engine" {
  description = "Motor de base de datos"
  type        = string
  default     = "postgres"
}

variable "engine_version" {
  description = "Versión del motor"
  type        = string
  validation {
    condition     = can(regex("^\\d+\\.\\d+", var.engine_version))
    error_message = "Engine version inválido"
  }
}

variable "instance_class" {
  description = "Tipo de instancia"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Almacenamiento inicial (GB)"
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Autoscaling máximo de almacenamiento"
  type        = number
  default     = 100
}

variable "db_name" {
  description = "Nombre de la base de datos"
  type        = string
}

variable "db_username" {
  description = "Usuario administrador"
  type        = string
}

variable "subnet_ids" {
  description = "Subnets privadas"
  type        = list(string)
}

variable "vpc_security_group_ids" {
  description = "Security Groups"
  type        = list(string)
}

variable "multi_az" {
  description = "Alta disponibilidad"
  type        = bool
  default     = false
}

variable "deletion_protection" {
  description = "Protección contra borrado"
  type        = bool
  default     = true
}

variable "backup_retention_period" {
  description = "Días de backup"
  type        = number
  default     = 7
}

variable "maintenance_window" {
  description = "Ventana de mantenimiento"
  type        = string
  default     = "Mon:00:00-Mon:03:00"
}

variable "backup_window" {
  description = "Ventana de backups"
  type        = string
  default     = "03:00-06:00"
}

variable "performance_insights_enabled" {
  description = "Habilitar Performance Insights"
  type        = bool
  default     = true
}

variable "performance_insights_retention_period" {
  description = "Días de retención para Performance Insights"
  type        = number
  default     = 7
}

variable "monitoring_interval" {
  description = "Intervalo de monitoreo (segundos)"
  type        = number
  default     = 60
}

variable "enabled_cloudwatch_logs_exports" {
  description = "Logs a exportar"
  type        = list(string)
  default     = ["postgresql"]
}

variable "db_parameters" {
  description = "Parámetros del motor"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "kms_key_id" {
  description = "KMS Key para cifrado"
  type        = string
  default     = null
}

variable "iam_database_authentication_enabled" {
  description = "Habilitar autenticación IAM para RDS"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags adicionales"
  type        = map(string)
  default     = {}
}