variable "project_name" {
  description = "The name of the project, used as a prefix for resource names"
  type        = string
  default     = "lifeistravel" 
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
  description = "value"
  type = string
}

variable "metadata_db_id" {
  description = "The id of the metadata database"
  type        = string
  
}

variable "metadata_db_pw" {
  description = "The password of the metadata database"
  type        = string
  
}