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

module "kafka_sink" {
  source = "./modules/kafka_sink"
  
  project_name = var.project_name
  environment  = var.environment
  kafka_topic  = var.kafka_topic
  
  tags = {
    Purpose = "Kafka Data Pipeline"
    Owner   = "Data Team"
  }
}