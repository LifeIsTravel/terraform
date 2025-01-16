variable "project_name" {
  description = "The name of the project, used as a prefix for resource names"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where Redshift will be deployed"
  type        = string
}

variable "public_subnet_ids" {
  description = "The IDs of the public subnets where Redshift will be deployed"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "The IDs of the subnets where Redshift will be deployed"
  type        = list(string)
}

variable "cidr_blocks" {
  description = "The CIDR block of the VPC"
  type        = list(string)
  default = ["0.0.0.0/0"]
  
}

variable "sg_private_instances"{ 
  description = "ID of the security group for private instances"
  type        = string
}

variable "sg_bastion" {
  description = "ID of the security group for the bastion host"
  type        = string
}

variable "metadata_db_id" {
  description = "The id of the metadata database"
  type        = string
}

variable "metadata_db_pw" {
  description = "The password of the metadata database"
  type        = string
  
}
