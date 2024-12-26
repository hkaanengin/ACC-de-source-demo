output "role_arn" {
  description = "ARN of the Kafka Connect IAM role"
  value       = aws_iam_role.kafka_connect_role.arn
}

output "role_name" {
  description = "Name of the Kafka Connect IAM role"
  value       = aws_iam_role.kafka_connect_role.name
}
