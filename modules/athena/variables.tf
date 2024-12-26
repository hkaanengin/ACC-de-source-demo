variable "environment" {
  description = "Environment name"
  type        = string
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket for Athena queries"
  type        = string
}

variable "database_name" {
  description = "Name of the Athena database"
  type        = string
  default     = "kafka_data"
}
