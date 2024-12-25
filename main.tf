# main.tf
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.0.0"
}

provider "aws" {
  region = var.aws_region
}

module "s3" {
  source      = "./modules/s3"
  bucket_name = var.bucket_name
  environment = var.environment
}

module "iam" {
  source      = "./modules/iam"
  environment = var.environment
  bucket_arn  = module.s3.bucket_arn
}

module "athena" {
  source         = "./modules/athena"
  environment    = var.environment
  s3_bucket_name = module.s3.bucket_name
  database_name  = var.src_database_name
}