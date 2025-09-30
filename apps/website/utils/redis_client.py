import json
import os

import redis


class RedisClient:
    def __init__(self) -> None:
        """Initialize Redis client with configuration from environment variables."""
        # Try REDIS_URL first (for Docker), fall back to individual variables
        redis_url = os.getenv("REDIS_URL")

        if redis_url:
            # Use REDIS_URL (Docker setup)
            self.client = redis.from_url(
                redis_url,
                decode_responses=True,
                socket_timeout=5,
                health_check_interval=30,
            )
        else:
            # Fall back to individual environment variables
            self.host = os.getenv("REDIS_HOST", "localhost")
            self.port = int(os.getenv("REDIS_PORT", "6379"))
            self.username = os.getenv("REDIS_USER")
            self.password = os.getenv("REDIS_DJANGO_PASSWORD")

            # decode_responses=True → strings instead of bytes
            self.client = redis.Redis(
                host=self.host,
                port=self.port,
                username=self.username,
                password=self.password,
                decode_responses=True,
                socket_timeout=5,
                health_check_interval=30,
            )

    def set(self, key: str, value, expire: int = None):
        """Store value in Redis (original method)"""
        print(f"Setting value for key: {key}")
        self.client.set(key, value, ex=expire)

    def get(self, key: str):
        """Get value from Redis (original method)"""
        return self.client.get(key)

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
