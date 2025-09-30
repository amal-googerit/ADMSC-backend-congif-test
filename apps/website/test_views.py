"""
Additional test cases for website views.
"""

from django.contrib.auth import get_user_model
from django.test import Client, TestCase
from django.urls import reverse

import pytest

from .models import FooterLink, Hero, MenuItem, Partners

User = get_user_model()


@pytest.mark.django_db
class TestWebsiteViews:
    """Test cases for website views using pytest."""

    def test_home_view_returns_200(self):
        """Test that home view returns 200 status code."""
        client = Client()
        response = client.get("/")
        assert response.status_code == 200

    def test_admin_redirects_to_login(self):
        """Test that admin view redirects to login."""
        client = Client()
        response = client.get("/admin/")
        assert response.status_code == 302

    def test_home_view_with_data(self):
        """Test home view with sample data."""
        client = Client()

        # Create test data
        MenuItem.objects.create(label_en="Home", route="/", order=1)
        Hero.objects.create(title_en="Test Title", description_en="Test Description")

        response = client.get("/")
        assert response.status_code == 200
        assert b"Test Title" in response.content


@pytest.mark.django_db
class TestModelCreation:
    """Test model creation using pytest."""

    def test_menu_item_creation(self):
        """Test MenuItem model creation."""
        menu_item = MenuItem.objects.create(
            label_en="Test Menu", route="/test", order=1
        )
        assert menu_item.label_en == "Test Menu"
        assert menu_item.route == "/test"
        assert str(menu_item) == "Test Menu"

    def test_hero_creation(self):
        """Test Hero model creation."""
        hero = Hero.objects.create(
            title_en="Test Hero", description_en="Test Description"
        )
        assert hero.title_en == "Test Hero"
        assert str(hero) == "Test Hero"

    def test_partners_creation(self):
        """Test Partners model creation."""
        partner = Partners.objects.create(
            name_en="Test Partner", image="test.jpg", order=1
        )
        assert partner.name_en == "Test Partner"
        assert str(partner) == "Partners #1"

    def test_footer_link_creation(self):
        """Test FooterLink model creation."""
        footer_link = FooterLink.objects.create(
            key="test", label_en="Test Link", route="/test", order=1
        )
        assert footer_link.key == "test"
        assert footer_link.label_en == "Test Link"
        assert str(footer_link) == "Test Link"
