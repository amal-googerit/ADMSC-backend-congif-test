"""
Pytest configuration and fixtures.
"""

from django.contrib.auth import get_user_model
from django.test import Client

import pytest

User = get_user_model()


@pytest.fixture
def client():
    """Provide a test client."""
    return Client()


@pytest.fixture
def user():
    """Provide a test user."""
    return User.objects.create_user(
        username="testuser", email="test@example.com", password="testpass123"
    )


@pytest.fixture
def admin_user():
    """Provide an admin user."""
    return User.objects.create_superuser(
        username="admin", email="admin@example.com", password="adminpass123"
    )
