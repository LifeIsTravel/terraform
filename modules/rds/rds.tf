resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "${var.project_name}-rds-subnet-group"
  subnet_ids = [var.private_subnet_ids[2],var.private_subnet_ids[3]]

  tags = {
    Name = "${var.project_name}-RDS-Subnet-Group"
  }
}

resource "aws_security_group" "rds_sg" {
  name        = "rds-sg"
  description = "Security group for RDS instance"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
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

resource "aws_db_instance" "airflow_meta_db" {
  identifier             = "${var.project_name}-airflow-meta-db"
  engine                 = "postgres"
  engine_version         = "13.15"
  instance_class         = "db.t3.small"
  allocated_storage      = 20
  storage_type           = "gp2"
  db_name                = "postgres" # 기본 Postgres 데이터베이스 이름
  username               = var.metadata_db_id
  password               = var.metadata_db_pw
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  publicly_accessible    = false
  skip_final_snapshot    = true

  tags = {
    Name = "${var.project_name}-Airflow-meta-RDS-Instance"
  }

#   # 데이터베이스 생성 스크립트를 실행하기 위한 local-exec provisioner
#   provisioner "local-exec" {
#     when    = "create"
#     interpreter = ["cmd", "/c"]
#     command = <<EOT
#     set PGPASSWORD=${var.metadata_db_pw} && ^
#     psql -h ${self.endpoint} -U ${var.metadata_db_id} -d postgres -c "CREATE DATABASE airflow;"
#     EOT
#     }
}