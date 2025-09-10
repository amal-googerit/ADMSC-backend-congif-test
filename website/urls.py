from django.urls import path
from . import views

urlpatterns = [
    path('api/website-data/', views.website_data_api, name='website_data_api'),
    path('api/update-redis/', views.update_redis, name='update_redis'),
]
