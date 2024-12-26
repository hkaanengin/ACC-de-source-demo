# Kafka to S3 Data Pipeline

This project sets up a data pipeline that:
1. Generates user data using a Kafka producer
2. Streams it through Kafka
3. Sinks it to AWS S3 using Kafka Connect
4. Makes it queryable via AWS Athena

## Prerequisites

- Docker and Docker Compose
- Python 3.8+
- AWS Account with appropriate permissions
- Terraform

## Setup

1. **Install Python Dependencies**
```bash
pip install -r requirements.txt
```

2. **Deploy AWS Infrastructure**
```bash
terraform init
terraform apply
```

3. **Configure Environment**
Create a `.env` file with your AWS credentials:
```
AWS_ACCESS_KEY_ID=your_access_key
AWS_SECRET_ACCESS_KEY=your_secret_key
AWS_REGION=us-east-1
S3_BUCKET_NAME=my-kafka-sink-bucket
```

4. **Start Kafka Infrastructure**
```bash
docker-compose up -d
```

5. **Run Data Producer**
```bash
python kafka_cluster/producer.py
```

## Components

- `kafka_cluster/producer.py`: Generates and sends user data to Kafka
- `kafka_cluster/s3-sink-connector.json`: Kafka Connect S3 sink configuration
- `modules/`: Terraform modules for AWS infrastructure
- `docker-compose.yml`: Local Kafka infrastructure

## Querying Data in Athena

Once data is in S3, you can query it using Athena with SQL queries like:
```sql
SELECT * FROM kafka_data.user_data
WHERE year = 2024 AND month = 12
LIMIT 10;