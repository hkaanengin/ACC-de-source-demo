locals {
  name_prefix = "${var.project_name}-${var.environment}"
  common_tags = merge(
    var.tags,
    {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "terraform"
    }
  )
}

module "s3" {
  source      = "../s3"
  bucket_name = "${local.name_prefix}-bucket"
  environment = var.environment
}

module "iam" {
  source      = "../iam"
  environment = var.environment
  bucket_arn  = module.s3.bucket_arn
}

module "athena" {
  source         = "../athena"
  environment    = var.environment
  s3_bucket_name = module.s3.bucket_name
  database_name  = replace("${local.name_prefix}_db", "-", "_")
}

# Generate S3 sink connector configuration
resource "local_file" "s3_sink_config" {
  content = templatefile("${path.root}/kafka_cluster/s3-sink-connector.json.tpl", {
    kafka_topic = var.kafka_topic
  })
  filename = "${path.root}/kafka_cluster/s3-sink-connector.json"
}
