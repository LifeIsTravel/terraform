resource "aws_elasticache_subnet_group" "elasticache_subnet_group" {
  name       = "${var.project_name}-elasticache-subnet-group"
  subnet_ids = [var.private_subnet_ids[4],var.private_subnet_ids[5]]

  tags = {
    Name = "${var.project_name}-ELC-Subnet-Group"
  }
}

resource "aws_security_group" "elc_sg" {
  name        = "elc-sg"
  description = "Security group for elasticache instance"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [var.sg_private_instances, var.sg_bastion]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-RDS-Security-Group"
  }
}

resource "aws_elasticache_replication_group" "redis" {
  replication_group_id          = "${var.project_name}-airflow-broker"
  description = "Replication group for ${var.project_name} airflow broker"
  engine                        = "redis"
  engine_version                = "7.1"
  node_type                     = "cache.t3.small"
  port                          = 6379
  automatic_failover_enabled    = false
  multi_az_enabled              = false
  security_group_ids            = [aws_security_group.elc_sg.id]
  subnet_group_name             = aws_elasticache_subnet_group.elasticache_subnet_group.name

  tags = {
    Name = "${var.project_name}-airflow-broker"
  }
}