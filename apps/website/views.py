from django.shortcuts import render
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_http_methods
from django.conf import settings
import json
import subprocess
import os
import hmac
import hashlib
from .models import MenuItem, Hero, Partners, FooterLink
from .utils.redis_client import RedisClient
from .utils.redis_test_json import json_data

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
            'admin': '/admin/',
            'webhook': '/api/webhook/deploy/'
        }
    })

def website_data_api(request):
    """
    API endpoint to get website data from Redis
    """
    try:
        # Try to get data from Redis first
        cached_data = redis_client.get('website_data')
        
        if cached_data:
            return JsonResponse({
                'status': 'success',
                'source': 'redis',
                'data': cached_data
            })
        else:
            # Fallback to database
            menu_items = list(MenuItem.objects.values())
            heroes = list(Hero.objects.values())
            partners = list(Partners.objects.values())
            footer_links = list(FooterLink.objects.values())
            
            data = {
                'menu_items': menu_items,
                'heroes': heroes,
                'partners': partners,
                'footer_links': footer_links
            }
            
            # Cache the data in Redis
            redis_client.set('website_data', data, expire=3600)  # 1 hour
            
            return JsonResponse({
                'status': 'success',
                'source': 'database',
                'data': data
            })
            
    except Exception as e:
        return JsonResponse({
            'status': 'error',
            'message': str(e)
        }, status=500)

def update_redis(request):
    """
    API endpoint to update Redis with JSON data
    """
    try:
        # Update Redis with the JSON data
        redis_client.set('website_data', json_data, expire=3600)
        
        return JsonResponse({
            'status': 'success',
            'message': 'Redis updated successfully',
            'data': json_data
        })
        
    except Exception as e:
        return JsonResponse({
            'status': 'error',
            'message': str(e)
        }, status=500)

@csrf_exempt
@require_http_methods(["POST"])
def webhook_deploy_dev(request):
    """
    Webhook endpoint for development deployment logging (CI/CD handles deployment)
    """
    try:
        # Verify webhook signature if secret is configured
        webhook_secret = getattr(settings, 'DEV_WEBHOOK_SECRET', None)
        if webhook_secret:
            signature = request.META.get('HTTP_X_HUB_SIGNATURE_256', '')
            if not signature:
                return JsonResponse({'error': 'Missing signature'}, status=401)
            
            # Verify signature
            body = request.body
            expected_signature = 'sha256=' + hmac.new(
                webhook_secret.encode('utf-8'),
                body,
                hashlib.sha256
            ).hexdigest()
            
            if not hmac.compare_digest(signature, expected_signature):
                return JsonResponse({'error': 'Invalid signature'}, status=401)
        
        # Parse webhook payload
        payload = json.loads(request.body.decode('utf-8'))
        
        # Check if this is a push to develop/dev branch
        ref = payload.get('ref', '')
        if ref in ['refs/heads/develop', 'refs/heads/dev']:
            # Log the webhook request (deployment handled by CI/CD)
            return JsonResponse({
                'status': 'received',
                'message': 'Development deployment request received. CI/CD pipeline will handle deployment.',
                'environment': 'development',
                'note': 'Deployment is handled securely through GitHub Actions CI/CD pipeline'
            })
        else:
            return JsonResponse({
                'status': 'ignored',
                'message': f'Not a push to develop/dev branch (received: {ref})'
            })
            
    except json.JSONDecodeError:
        return JsonResponse({'error': 'Invalid JSON payload'}, status=400)
    except Exception as e:
        return JsonResponse({
            'status': 'error',
            'message': str(e)
        }, status=500)

@csrf_exempt
@require_http_methods(["POST"])
def webhook_deploy_prod(request):
    """
    Webhook endpoint for production deployment (manual approval required)
    """
    try:
        # Verify webhook signature if secret is configured
        webhook_secret = getattr(settings, 'PROD_WEBHOOK_SECRET', None)
        if webhook_secret:
            signature = request.META.get('HTTP_X_HUB_SIGNATURE_256', '')
            if not signature:
                return JsonResponse({'error': 'Missing signature'}, status=401)
            
            # Verify signature
            body = request.body
            expected_signature = 'sha256=' + hmac.new(
                webhook_secret.encode('utf-8'),
                body,
                hashlib.sha256
            ).hexdigest()
            
            if not hmac.compare_digest(signature, expected_signature):
                return JsonResponse({'error': 'Invalid signature'}, status=401)
        
        # Parse webhook payload
        payload = json.loads(request.body.decode('utf-8'))
        
        # Check if this is a push to main branch
        if payload.get('ref') == 'refs/heads/main':
            # For production, we don't auto-deploy, just log the request
            return JsonResponse({
                'status': 'received',
                'message': 'Production deployment request received. Manual approval required.',
                'environment': 'production',
                'note': 'Please use GitHub Actions workflow dispatch to deploy to production'
            })
        else:
            return JsonResponse({
                'status': 'ignored',
                'message': 'Not a push to main branch'
            })
            
    except json.JSONDecodeError:
        return JsonResponse({'error': 'Invalid JSON payload'}, status=400)
    except Exception as e:
        return JsonResponse({
            'status': 'error',
            'message': str(e)
        }, status=500)

# Note: Direct deployment functions removed - all deployments now go through secure CI/CD pipeline