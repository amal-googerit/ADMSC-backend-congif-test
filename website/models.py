from django.db import models

from django.db import models


# ---------- Header ----------
class MenuItem(models.Model):
    label_en = models.CharField(max_length=255)
    label_ar = models.CharField(max_length=255, null=True, blank=True)
    route = models.CharField(max_length=255, help_text="URL path or route name")
    order = models.PositiveIntegerField(default=0)

    def __str__(self):
        return self.label_en


# ---------- Hero ----------
class Hero(models.Model):
    title_en = models.CharField(max_length=255)
    title_ar = models.CharField(max_length=255, null=True, blank=True)
    description_en = models.TextField(null=True, blank=True)
    description_ar = models.TextField(null=True, blank=True)
    button_en = models.CharField(max_length=255, null=True, blank=True)
    button_ar = models.CharField(max_length=255, null=True, blank=True)
    background_image = models.CharField(max_length=512, null=True, blank=True)

    def __str__(self):
        return self.title_en


# ---------- Partners ----------
class Partners(models.Model):
    name_en = models.CharField(max_length=100)
    name_ar = models.CharField(max_length=100, null=True, blank=True)
    image = models.CharField(max_length=512)
    order = models.PositiveIntegerField(default=0)

    def __str__(self):
        return f"Partners #{self.pk}"


# ---------- Footer ----------
class FooterLink(models.Model):
    key = models.SlugField(max_length=64, help_text="e.g. about, contact")
    label_en = models.CharField(max_length=255)
    label_ar = models.CharField(max_length=255, null=True, blank=True)
    route = models.CharField(max_length=255)
    is_external = models.BooleanField(default=False)
    order = models.PositiveIntegerField(default=0)

    def __str__(self):
        return self.label_en