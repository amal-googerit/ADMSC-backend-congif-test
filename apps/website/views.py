from django.shortcuts import render
from django.http import JsonResponse
from .models import MenuItem, Hero, Partners, FooterLink
from .utils.redis_client import RedisClient
from .utils.redis_test_json import home_data 
from .utils.redis_seo import SEO_DATA
import json
from datetime import datetime

# Create your views here.

redis_client = RedisClient()

def home(request):
    """
    Simple home view for testing
    """
    return JsonResponse({
        'message': 'Welcome to ADMSC API',
        'endpoints': {
            'website_data': '/api/website-data/',
            'update_redis': '/api/update-redis/',
            'admin': '/admin/'
        }
    })

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
        redis_client.set_json("home_page", home_data)  # TTL = 1 hour
        print('Task completed')
        redis_client.set_json("seo_data", SEO_DATA)  # TTL = 1 hour
        redis_client.set_json("test", "tested")  # TTL = 1 hour
        return JsonResponse({"status": "ok", "stored": home_data})  
    except Exception as e:
        return JsonResponse({'error': str(e)}, status=500)

def set_health_status(request):
    """
    API endpoint to set health status (for amal-googerit only)
    """
    try:
        # Check if user is amal-googerit (you can add more sophisticated auth later)
        user_agent = request.META.get('HTTP_USER_AGENT', '')
        if 'amal-googerit' not in user_agent and 'amal-googerit' not in str(request.META):
            return JsonResponse({'error': 'Unauthorized'}, status=403)
        
        # Get health status from request
        data = json.loads(request.body.decode('utf-8'))
        status = data.get('status', '').upper()
        pr_number = data.get('pr_number', 'unknown')
        
        if status not in ['GOOD', 'BAD']:
            return JsonResponse({'error': 'Invalid status. Use GOOD or BAD'}, status=400)
        
        # Store health status in Redis
        health_data = {
            'status': status,
            'pr_number': pr_number,
            'timestamp': str(datetime.now()),
            'set_by': 'amal-googerit'
        }
        
        redis_client.set_json(f"health_status_pr_{pr_number}", health_data, expire=86400)  # 24 hours
        
        return JsonResponse({
            'status': 'success',
            'message': f'Health status set to {status} for PR #{pr_number}',
            'data': health_data
        })
        
    except json.JSONDecodeError:
        return JsonResponse({'error': 'Invalid JSON'}, status=400)
    except Exception as e:
        return JsonResponse({'error': str(e)}, status=500)

def get_health_status(request):
    """
    API endpoint to get current health status
    """
    try:
        pr_number = request.GET.get('pr_number', 'latest')
        
        if pr_number == 'latest':
            # Get the latest health status
            keys = redis_client.client.keys('health_status_pr_*')
            if keys:
                latest_key = max(keys, key=lambda k: redis_client.client.hget(k, 'timestamp') or '')
                health_data = redis_client.get_json(latest_key)
            else:
                health_data = {'status': 'UNKNOWN', 'message': 'No health status found'}
        else:
            # Get specific PR health status
            health_data = redis_client.get_json(f"health_status_pr_{pr_number}")
            if not health_data:
                health_data = {'status': 'UNKNOWN', 'message': f'No health status found for PR #{pr_number}'}
        
        return JsonResponse(health_data)
        
    except Exception as e:
        return JsonResponse({'error': str(e)}, status=500)