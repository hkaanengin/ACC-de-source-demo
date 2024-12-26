variable "environment" {
  description = "Environment name (e.g., prod, dev, staging)"
  type        = string
}

variable "project_name" {
  description = "Project name that will be used as a prefix for all resources"
  type        = string
}

variable "kafka_topic" {
  description = "Kafka topic name for the S3 sink connector"
  type        = string
}

variable "tags" {
  description = "Additional tags for all resources"
  type        = map(string)
  default     = {}
}