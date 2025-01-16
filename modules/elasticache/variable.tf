variable "project_name" {
  description = "The name of the project, used as a prefix for resource names"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where Redshift will be deployed"
  type        = string
}

variable "private_subnet_ids" {
  description = "The IDs of the subnets where Redshift will be deployed"
  type        = list(string)
}

variable "sg_private_instances"{ 
  description = "ID of the security group for private instances"
  type        = string
}

variable "sg_bastion" {
  description = "ID of the security group for the bastion host"
  type        = string
}