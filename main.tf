terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.7.0"
    }
  }
}

provider "aws" {
  region  = "ap-northeast-2"
}

data "aws_caller_identity" "current" {}


# module "s3" {
#   source = "./modules/s3"
#   project_name = var.project_name
# }

module "network" {
  source = "./modules/network"
  project_name = var.project_name
  
}

module "ec2" {
  source = "./modules/ec2"
  project_name = var.project_name
  vpc_id = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids
  private_subnet_ids = module.network.private_subnet_ids
  aws_access_key_id = var.aws_access_key_id
  aws_secret_access_key = var.aws_secret_access_key
  aws_region = var.aws_region
  airflow_broker_endpoint = module.elasticache.airflow_broker_endpoint
  airflow_meta_rds_endpoint = module.rds.airflow_meta_rds_endpoint
 
}

module "rds" {
   source = "./modules/rds"
  project_name = var.project_name
  vpc_id = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids
  private_subnet_ids = module.network.private_subnet_ids
  sg_private_instances = module.ec2.sg_private_instances
  sg_bastion = module.ec2.sg_bastion
  metadata_db_id = var.metadata_db_id
  metadata_db_pw = var.metadata_db_pw  
}

module "elasticache" {
   source = "./modules/elasticache"
  project_name = var.project_name
  vpc_id = module.network.vpc_id
  private_subnet_ids = module.network.private_subnet_ids
  sg_private_instances = module.ec2.sg_private_instances
  sg_bastion = module.ec2.sg_bastion
}
