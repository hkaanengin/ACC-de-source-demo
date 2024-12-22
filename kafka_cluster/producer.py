from kafka import KafkaProducer
import json
from typing import Dict, Any, List
import logging
import requests
from datetime import datetime
import time
import random
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)
BASE_URL = "https://randomuser.me/api/?nat=tr"

class KafkaProducer:
    def __init__(self, bootstrap_servers: str, topic: str):
        """
        Initialize the Kafka producer
        
        Args:
            bootstrap_servers: Comma-separated list of host:port pairs
            topic: The Kafka topic to produce to
        """
        self.topic = topic
        try:
            self.producer = KafkaProducer(
                bootstrap_servers=bootstrap_servers,
                value_serializer=lambda x: json.dumps(x).encode('utf-8'),
                # Enable basic error handling and retries
                retries=3,
                acks='all',
                batch_size=16384,  # Optimize batch size for better throughput
                linger_ms=100      # Wait up to 100ms to batch messages
            )
            logger.info(f"Successfully connected to Kafka at {bootstrap_servers}")
        except Exception as e:
            logger.error(f"Failed to connect to Kafka: {str(e)}")
            raise

    def send_messages(self, messages: List[Dict[str, Any]]) -> None:
        """
        Send multiple messages to the Kafka topic
        
        Args:
            messages: List of dictionaries containing the messages to be sent
        """
        try:
            futures = []
            for message in messages:
                future = self.producer.send(self.topic, value=message)
                futures.append(future)
            
            # Wait for all messages to be delivered
            for future in futures:
                record_metadata = future.get(timeout=10)
                
            logger.info(f"Batch of {len(messages)} messages sent successfully to {self.topic}")
        except Exception as e:
            logger.error(f"Failed to send messages: {str(e)}")
            raise

    def close(self) -> None:
        """Close the Kafka producer"""
        self.producer.close()
        logger.info("Kafka producer closed")

def populate_user_data() -> Dict[str, Any]:
    """Generate a single user record with proper timestamps and data types"""
    response = requests.get(BASE_URL)
    if response.status_code == 200:
        user_data = response.json()['results'][0]
        current_time = datetime.utcnow()
        
        return {
            # Metadata for partitioning
            "year": current_time.year,
            "month": current_time.month,
            "day": current_time.day,
            "hour": current_time.hour,
            "timestamp": current_time.isoformat(),
            
            # user data
            "user_id": user_data['login']['uuid'],
            "user_name": f"{user_data['name']['first']} {user_data['name']['last']}",
            "date_of_birth": user_data['dob']['date'],
            "age": int(user_data['dob']['age']),  # Ensure integer type
            "gender": user_data['gender'],
            "nationality": user_data['nat'],
            "registration_number": user_data['login']['username'],
            "address": {
                "street": f"{user_data['location']['street']['name']} {user_data['location']['street']['number']}",
                "city": user_data['location']['city'],
                "state": user_data['location']['state'],
                "country": user_data['location']['country'],
                "postcode": str(user_data['location']['postcode'])  # Ensure string type
            },
            "email": user_data['email'],
            "phone_number": user_data['phone'],
            "picture": user_data['picture']['large'],
            "registered_age": int(user_data['registered']['age'])  # Ensure integer type
        }

def generate_batch(batch_size: int = 100) -> List[Dict[str, Any]]:
    """Generate a batch of user records"""
    return [populate_user_data() for _ in range(batch_size)]
        
# Example usage
if __name__ == "__main__":
    # Create producer instance
    producer = KafkaProducer(
        bootstrap_servers=os.getenv('KAFKA_BOOTSTRAP_SERVERS', 'localhost:9092'),
        topic=os.getenv('KAFKA_TOPIC', 'user-data')
    )
    
    try:
        while True:  # Continuous production of data
            # Generate and send a batch of messages
            batch = generate_batch(batch_size=int(os.getenv('BATCH_SIZE', '100')))
            producer.send_messages(batch)
            
            # Wait a bit before sending the next batch
            time.sleep(random.uniform(1, 5))  # Random delay between 1-5 seconds
            
    except KeyboardInterrupt:
        logger.info("Stopping data production...")
    finally:
        # Always close the producer
        producer.close()