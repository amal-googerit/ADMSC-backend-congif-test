import redis
import json
import os

class RedisClient:
    def __init__(self):
        self.host = os.getenv("REDIS_HOST", "127.0.0.1")
        self.port = int(os.getenv("REDIS_PORT", 6379))
        self.password = os.getenv("REDIS_PASSWORD", None)

        # decode_responses=True → strings instead of bytes
        self.client = redis.Redis(
            host=self.host,
            port=self.port,
            password=self.password,
            decode_responses=True,
            socket_timeout=5,
            health_check_interval=30
        )

    def set_json(self, key: str, value: dict, expire: int = None):
        """Store dict as JSON in Redis"""
        print(f"Setting JSON for key: {key}")
        self.client.set(key, json.dumps(value), ex=expire)

    def get_json(self, key: str):
        """Fetch JSON from Redis and parse it"""
        raw = self.client.get(key)
        return json.loads(raw) if raw else None

    def delete(self, key: str):
        """Delete a key"""
        self.client.delete(key)

    def exists(self, key: str) -> bool:
        return self.client.exists(key) == 1