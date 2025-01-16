resource "tls_private_key" "bastion_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "bastion_key" {
  key_name   = "${var.project_name}-bastion-key"
  public_key = tls_private_key.bastion_ssh_key.public_key_openssh
}

resource "aws_ssm_parameter" "bastion_ssh_private_key" {
  name  = "/${var.project_name}/ec2/bastion-key"
  type  = "SecureString"
  value = tls_private_key.bastion_ssh_key.private_key_pem
}

resource "tls_private_key" "private_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "private_key" {
  key_name   = "${var.project_name}-private-key"
  public_key = tls_private_key.private_ssh_key.public_key_openssh
}

resource "aws_ssm_parameter" "private_ssh_private_key" {
  name  = "/${var.project_name}/ec2/private-key"
  type  = "SecureString"
  value = tls_private_key.private_ssh_key.private_key_pem
}

resource "aws_security_group" "bastion" {
  name        = "${var.project_name}-bastion-sg"
  description = "Security group for Bastion host"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "private_instances" {
  name        = "${var.project_name}-private-instances-sg"
  description = "Security group for private instances"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "airflow" {
  name        = "${var.project_name}-airflow-sg"
  description = "Security group for Airflow server"
  vpc_id      = var.vpc_id
  
  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }
}

resource "aws_instance" "bastion" {
  ami                    = "${var.basic_ec2_ami}"
  instance_type          = "t3.micro"
  subnet_id              = var.public_subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.bastion.id]
  key_name               = aws_key_pair.bastion_key.key_name
  associate_public_ip_address = true

  tags = {
    Name = "${var.project_name}-Bastion-Host"
  }

  user_data = templatefile("${path.module}/tpl/bastion_host.tpl", {
    ssh_setting = templatefile("${path.module}/tpl/ssh_setting.tpl", {
      ssh_public_key = tls_private_key.bastion_ssh_key.public_key_openssh}),
    ssh_private_key = tls_private_key.bastion_ssh_key.private_key_pem
    })
}

resource "aws_eip" "ec2_eip" {
  domain   = "vpc"
  instance = aws_instance.bastion.id

  tags = {
    Name = "${var.project_name}-Bastion-EIP"
  }
}

resource "aws_iam_role" "ec2_role" {
  name = "${var.project_name}_airflow_ec2_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "ec2_s3_access" {
  name = "ec2_s3_access"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Effect   = "Allow"
        Resource = [
          "arn:aws:s3:::${var.s3_bucket_name}",
          "arn:aws:s3:::${var.s3_bucket_name}/*",
        ]
      }
    ]
  })
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}_airflow_ec2_profile"
  role = aws_iam_role.ec2_role.name
}

resource "aws_iam_role_policy_attachment" "ssm_managed_instance_core" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.ec2_role.name
}

resource "aws_instance" "airflow_scheduler" {
  ami                    = "${var.airflow_ec2_ami}"
  instance_type          = "t3.medium"
  subnet_id              = var.private_subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.private_instances.id, aws_security_group.airflow.id]
  key_name               = aws_key_pair.private_key.key_name
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  tags = {
    Name = "${var.project_name}-Airflow-Scheduler-Instance"
  }
  
  user_data = templatefile("${path.module}/tpl/airflow_scheduler.tpl", {
    ssh_setting = templatefile("${path.module}/tpl/ssh_setting.tpl", {
      ssh_public_key = tls_private_key.private_ssh_key.public_key_openssh}),
    aws_access_key_id = var.aws_access_key_id,
    aws_secret_access_key = var.aws_secret_access_key,
    aws_region = var.aws_region,
    broker_url = var.airflow_broker_endpoint,
    meta_db_url = var.airflow_meta_rds_endpoint
    })
}


resource "aws_instance" "airflow_webserver" {
  ami                    = "${var.airflow_ec2_ami}"
  instance_type          = "t3.medium"
  subnet_id              = var.private_subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.private_instances.id, aws_security_group.airflow.id]
  key_name               = aws_key_pair.private_key.key_name
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  tags = {
    Name = "${var.project_name}-Airflow-WebServer-Instance"
  }
  
  user_data = templatefile("${path.module}/tpl/airflow_webserver.tpl", {
    ssh_setting = templatefile("${path.module}/tpl/ssh_setting.tpl", {
      ssh_public_key = tls_private_key.private_ssh_key.public_key_openssh}),
    aws_access_key_id = var.aws_access_key_id,
    aws_secret_access_key = var.aws_secret_access_key,
    aws_region = var.aws_region,
    broker_url = var.airflow_broker_endpoint,
    meta_db_url = var.airflow_meta_rds_endpoint})
}

resource "aws_instance" "airflow_worker" {
  ami                    = "${var.airflow_ec2_ami}"
  instance_type          = "t3.medium"
  subnet_id              = var.private_subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.private_instances.id, aws_security_group.airflow.id]
  key_name               = aws_key_pair.private_key.key_name
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  tags = {
    Name = "${var.project_name}-Airflow-Worker-Instance"
  }
  
  user_data = templatefile("${path.module}/tpl/airflow_worker.tpl", {
    ssh_setting = templatefile("${path.module}/tpl/ssh_setting.tpl", {
      ssh_public_key = tls_private_key.private_ssh_key.public_key_openssh}),
    aws_access_key_id = var.aws_access_key_id,
    aws_secret_access_key = var.aws_secret_access_key,
    aws_region = var.aws_region,
    broker_url = var.airflow_broker_endpoint,
    meta_db_url = var.airflow_meta_rds_endpoint})
}


resource "aws_security_group" "alb" {
  name        = "${var.project_name}-alb-sg"
  description = "Security group for ALB"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }
    
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "airflow" {
  name               = "${var.project_name}-airflow-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.public_subnet_ids
}

resource "aws_lb_target_group" "airflow" {
  name     = "${var.project_name}-airflow-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  health_check {
    path = "/health"
    port = "8080"
    protocol = "HTTP"
    timeout = 5
    interval = 30
    healthy_threshold = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "airflow" {
  load_balancer_arn = aws_lb.airflow.arn
  port              = "80"  
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.airflow.arn
  }
  tags = {
    Name = "${var.project_name}-airflow-listener"
  }
}

resource "aws_lb_target_group_attachment" "airflow" {
  target_group_arn = aws_lb_target_group.airflow.arn
  target_id        = aws_instance.airflow_webserver.id
  port             = 8080
}