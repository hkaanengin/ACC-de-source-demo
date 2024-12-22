variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  default     = "prod"
}

variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "src_database_name" {
  description = "Name of the source database"
  type        = string
}