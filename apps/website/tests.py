"""
Tests for the website app.
"""
from django.test import TestCase
from django.urls import reverse
from django.contrib.auth import get_user_model

from .models import MenuItem, Hero, Partners, FooterLink

User = get_user_model()


class MenuItemModelTest(TestCase):
    """Test cases for MenuItem model."""

    def test_menu_item_creation(self):
        """Test creating a menu item."""
        menu_item = MenuItem.objects.create(
            label_en="Home",
            label_ar="الرئيسية",
            route="/",
            order=1
        )
        self.assertEqual(str(menu_item), "Home")
        self.assertEqual(menu_item.label_en, "Home")
        self.assertEqual(menu_item.label_ar, "الرئيسية")
        self.assertEqual(menu_item.route, "/")
        self.assertEqual(menu_item.order, 1)


class HeroModelTest(TestCase):
    """Test cases for Hero model."""

    def test_hero_creation(self):
        """Test creating a hero section."""
        hero = Hero.objects.create(
            title_en="Welcome to ADMSC",
            title_ar="مرحباً بكم في ADMSC",
            description_en="This is a test description",
            description_ar="هذا وصف تجريبي",
            button_en="Learn More",
            button_ar="اعرف المزيد",
            background_image="hero-bg.jpg"
        )
        self.assertEqual(str(hero), "Welcome to ADMSC")
        self.assertEqual(hero.title_en, "Welcome to ADMSC")
        self.assertEqual(hero.title_ar, "مرحباً بكم في ADMSC")


class PartnersModelTest(TestCase):
    """Test cases for Partners model."""

    def test_partners_creation(self):
        """Test creating a partner."""
        partner = Partners.objects.create(
            name_en="Partner 1",
            name_ar="شريك 1",
            image="partner1.jpg",
            order=1
        )
        self.assertEqual(str(partner), "Partners #1")
        self.assertEqual(partner.name_en, "Partner 1")
        self.assertEqual(partner.name_ar, "شريك 1")


class FooterLinkModelTest(TestCase):
    """Test cases for FooterLink model."""

    def test_footer_link_creation(self):
        """Test creating a footer link."""
        footer_link = FooterLink.objects.create(
            key="about",
            label_en="About Us",
            label_ar="من نحن",
            route="/about",
            is_external=False,
            order=1
        )
        self.assertEqual(str(footer_link), "About Us")
        self.assertEqual(footer_link.key, "about")
        self.assertEqual(footer_link.label_en, "About Us")
        self.assertEqual(footer_link.is_external, False)


class WebsiteViewsTest(TestCase):
    """Test cases for website views."""

    def test_home_view(self):
        """Test the home view."""
        response = self.client.get('/')
        self.assertEqual(response.status_code, 200)

    def test_admin_view(self):
        """Test the admin view."""
        response = self.client.get('/admin/')
        self.assertEqual(response.status_code, 302)  # Redirects to login