from django.urls import path

from . import views

urlpatterns = [
    path("", views.home, name="home"),
    path("api/website-data/", views.website_data_api, name="website_data_api"),
    path("api/update-redis/", views.update_redis, name="update_redis"),
    path("api/health/status/", views.get_health_status, name="get_health_status"),
    path("api/health/set/", views.set_health_status, name="set_health_status"),
]
