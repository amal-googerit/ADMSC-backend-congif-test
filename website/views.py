import redis
import json
from django.shortcuts import render
from django.http import JsonResponse
from .models import MenuItem, Hero, Partners, FooterLink
from .utils.redis_client import RedisClient
from .utils.redis_test_json import json_data 

# Create your views here.

redis_client = RedisClient()


def website_data_api(request):
    """
    API endpoint that returns all website data as JSON
    """
    try:
        # Get all data from each model
        menu_items = list(MenuItem.objects.all().values())
        heroes = list(Hero.objects.all().values())
        partners = list(Partners.objects.all().values())
        footer_links = list(FooterLink.objects.all().values())
        
        # Combine all data into a single response
        data = {
            'menu_items': menu_items,
            'heroes': heroes,
            'partners': partners,
            'footer_links': footer_links,
        }
        
        return JsonResponse(data, safe=False)
    
    except Exception as e:
        return JsonResponse({'error': str(e)}, status=500)

def update_redis(request):
    """
    API endpoint that updates the Redis database
    """
    try:
        # here we can impliment the logic for the db update - from the admin side
        redis_client.set_json("mydata", json_data)  # TTL = 1 hour
        return JsonResponse({"status": "ok", "stored": json_data})  
    except Exception as e:
        return JsonResponse({'error': str(e)}, status=500)
