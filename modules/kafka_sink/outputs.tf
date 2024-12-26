output "bucket_name" {
  description = "Name of the created S3 bucket"
  value       = module.s3.bucket_name
}

output "bucket_arn" {
  description = "ARN of the created S3 bucket"
  value       = module.s3.bucket_arn
}

output "iam_role_arn" {
  description = "ARN of the IAM role for Kafka Connect"
  value       = module.iam.role_arn
}

output "athena_database_name" {
  description = "Name of the Athena database"
  value       = aws_athena_database.kafka_data.name
}

output "athena_workgroup_name" {
  description = "Name of the Athena workgroup"
  value       = aws_athena_workgroup.kafka_analytics.name
}
