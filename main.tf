locals {
  name = "${var.project}-${var.env}-${var.identifier}"

  common_tags = merge({
    Project     = var.project
    Environment = var.env
    ManagedBy   = "Terraform"
  }, var.tags)
}

# -------------------------------
# Subnet Group
# -------------------------------
resource "aws_db_subnet_group" "this" {
  name       = "${local.name}-sng"
  subnet_ids = var.subnet_ids

  tags = merge(local.common_tags, {
    Name = "${local.name}-sng"
  })
}

# -------------------------------
# Parameter Group
# -------------------------------
resource "aws_db_parameter_group" "this" {
  name   = "${local.name}-pg"
  family = "${var.engine}${split(".", var.engine_version)[0]}"

  dynamic "parameter" {
    for_each = var.db_parameters
    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }

  tags = local.common_tags
}

# -------------------------------
# RDS Instance
# -------------------------------
resource "aws_db_instance" "this" {
  identifier = local.name

  engine         = var.engine
  engine_version = var.engine_version
  instance_class = var.instance_class

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = "gp3"

  db_name  = var.db_name
  username = var.db_username

  manage_master_user_password = true

  db_subnet_group_name   = aws_db_subnet_group.this.name
  parameter_group_name   = aws_db_parameter_group.this.name
  vpc_security_group_ids = var.vpc_security_group_ids

  multi_az = var.multi_az

  publicly_accessible = false
  storage_encrypted   = true
  kms_key_id          = var.kms_key_id

  backup_retention_period = var.backup_retention_period
  backup_window           = var.backup_window
  maintenance_window      = var.maintenance_window

  deletion_protection = var.deletion_protection

  skip_final_snapshot       = false
  final_snapshot_identifier = "${local.name}-final-snapshot"

  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_kms_key_id       = var.performance_insights_enabled ? aws_kms_key.rds_kms_performance[0].arn : null
  performance_insights_retention_period = var.performance_insights_enabled ? var.performance_insights_retention_period : null

  monitoring_interval = var.monitoring_interval
  monitoring_role_arn = var.monitoring_interval > 0 ? aws_iam_role.rds_monitoring[0].arn : null

  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports

  auto_minor_version_upgrade = true

  iam_database_authentication_enabled = contains(["postgres", "mysql"], var.engine) ? var.iam_database_authentication_enabled : null

  tags = merge(local.common_tags, {
    Name = local.name
  })

  lifecycle {
    prevent_destroy = true
  }
}

# -------------------------------
# Role para RDS Performance Insights
# -------------------------------
resource "aws_iam_role" "rds_monitoring" {
  count = var.monitoring_interval > 0 ? 1 : 0

  name = "${local.name}-rds-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "monitoring.rds.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  count = var.monitoring_interval > 0 ? 1 : 0

  role       = aws_iam_role.rds_monitoring[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

resource "aws_kms_key" "rds_kms_performance" {
  count = var.performance_insights_enabled ? 1 : 0

  description             = "KMS para Performance Insights"
  deletion_window_in_days = 7

  enable_key_rotation = true

  tags = {
    Name = "${local.name}-rds-kms"
  }
}