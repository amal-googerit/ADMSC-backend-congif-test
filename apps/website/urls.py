from django.urls import path
from . import views

urlpatterns = [
    path('', views.home, name='home'),
    path('api/website-data/', views.website_data_api, name='website_data_api'),
    path('api/update-redis/', views.update_redis, name='update_redis'),
    path('api/webhook/deploy/dev/', views.webhook_deploy_dev, name='webhook_deploy_dev'),
    path('api/webhook/deploy/prod/', views.webhook_deploy_prod, name='webhook_deploy_prod'),
]
