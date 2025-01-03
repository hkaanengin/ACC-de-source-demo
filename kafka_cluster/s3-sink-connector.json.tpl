{
  "name": "s3-sink",
  "config": {
    "connector.class": "io.confluent.connect.s3.S3SinkConnector",
    "tasks.max": "1",
    "topics": "${kafka_topic}",
    "s3.bucket.name": "${S3_BUCKET_NAME}",
    "s3.region": "${AWS_REGION}",
    "flush.size": "1000",
    "rotate.interval.ms": "60000",
    "storage.class": "io.confluent.connect.s3.storage.S3Storage",
    "format.class": "io.confluent.connect.s3.format.parquet.ParquetFormat",
    "partitioner.class": "io.confluent.connect.storage.partitioner.TimeBasedPartitioner",
    "path.format": "'year'=YYYY/'month'=MM/'day'=dd/'hour'=HH",
    "locale": "US",
    "timezone": "UTC",
    "partition.duration.ms": "3600000",
    "schema.compatibility": "NONE",
    "aws.access.key.id": "${AWS_ACCESS_KEY_ID}",
    "aws.secret.access.key": "${AWS_SECRET_ACCESS_KEY}"
  }
}
