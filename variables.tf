variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

variable "environment" {
  description = "Environment name (e.g., prod, dev, staging)"
  type        = string
  default     = "prod"
}

variable "project_name" {
  description = "Project name that will be used as a prefix for all resources"
  type        = string
  default     = "kafka-s3"
}

variable "kafka_topic" {
  description = "Kafka topic name for the S3 sink connector"
  type        = string
  default     = "user-data"
}