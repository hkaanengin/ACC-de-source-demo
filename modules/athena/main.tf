resource "aws_athena_database" "kafka_data" {
  name   = var.database_name
  bucket = var.s3_bucket_name
}

resource "aws_athena_workgroup" "kafka_analytics" {
  name = "kafka_analytics"

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = false

    result_configuration {
      output_location = null
    }
  }

  tags = {
    Environment = var.environment
    Purpose     = "Kafka Data Analytics"
  }
}
