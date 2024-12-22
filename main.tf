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

# variables.tf
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

# outputs.tf
output "bucket_name" {
  value = module.s3.bucket_name
}

output "bucket_arn" {
  value = module.s3.bucket_arn
}

output "role_arn" {
  value = module.iam.role_arn
}

# modules/s3/main.tf
resource "aws_s3_bucket" "sink_bucket" {
  bucket = var.bucket_name

  tags = {
    Environment = var.environment
    Purpose     = "Kafka Connect S3 Sink"
  }
}

resource "aws_s3_bucket_versioning" "sink_bucket_versioning" {
  bucket = aws_s3_bucket.sink_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "sink_bucket_encryption" {
  bucket = aws_s3_bucket.sink_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_kms_key" "s3_key" {
  description             = "KMS key for S3 bucket encryption"
  deletion_window_in_days = 7
  enable_key_rotation    = true

  tags = {
    Environment = var.environment
    Purpose     = "Kafka Connect S3 Sink"
  }
}

resource "aws_s3_bucket_policy" "sink_bucket_policy" {
  bucket = aws_s3_bucket.sink_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "EnforceTLS"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.sink_bucket.arn,
          "${aws_s3_bucket.sink_bucket.arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport": "false"
          }
        }
      }
    ]
  })
}

# modules/s3/variables.tf
variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

# modules/s3/outputs.tf
output "bucket_name" {
  value = aws_s3_bucket.sink_bucket.id
}

output "bucket_arn" {
  value = aws_s3_bucket.sink_bucket.arn
}

# modules/iam/main.tf
resource "aws_iam_role" "kafka_connect_role" {
  name = "kafka-connect-s3-sink-role"

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

  tags = {
    Environment = var.environment
    Purpose     = "Kafka Connect S3 Sink"
  }
}

resource "aws_iam_role_policy" "s3_access_policy" {
  name = "kafka-connect-s3-sink-policy"
  role = aws_iam_role.kafka_connect_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:DeleteObject"
        ]
        Resource = [
          var.bucket_arn,
          "${var.bucket_arn}/*"
        ]
      }
    ]
  })
}

# modules/iam/variables.tf
variable "environment" {
  description = "Environment name"
  type        = string
}

variable "bucket_arn" {
  description = "ARN of the S3 bucket"
  type        = string
}

# modules/iam/outputs.tf
output "role_arn" {
  value = aws_iam_role.kafka_connect_role.arn
}