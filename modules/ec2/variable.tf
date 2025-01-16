variable "project_name" {
  description = "The name of the project, used as a prefix for resource names"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where Redshift will be deployed"
  type        = string
}

variable "public_subnet_ids" {
  description = "The IDs of the subnets where Redshift will be deployed"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "The IDs of the subnets where Redshift will be deployed"
  type        = list(string)
}

variable "basic_ec2_ami" {
  description = "The AMI to use for the EC2 instances"
  type        = string
  default     = "ami-0dc44556af6f78a7b"
}

variable "airflow_ec2_ami" {
  description = "The AMI to use for the EC2 instances"
  type        = string
  default     = "ami-0761f7ad2f8e0ea37"
}

variable "s3_bucket_name" {
  type        = string
  description = "The name of the S3 bucket"
  default = "lifeistravel-airflow-dags"
  
}

variable "aws_access_key_id" {
  description = "AWS Access Key ID"
  type        = string
}

variable "aws_secret_access_key" {
  description = "AWS Secret Access Key"
  type        = string
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "airflow_meta_rds_endpoint" {
  description = "The connection endpoint for the airflow meta db instance"
  type        = string
}

variable "airflow_broker_endpoint" {
  description = "The connection endpoint for the airflow meta db instance"
  type        = string
}
