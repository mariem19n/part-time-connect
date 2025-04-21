from django.shortcuts import render
from django.http import JsonResponse
from django.views.decorators.http import require_GET
from django.views.decorators.csrf import csrf_exempt
from django.contrib.auth.decorators import login_required
from .models import Message
from django.db.models import Q
import json
from rest_framework.decorators import api_view, authentication_classes, permission_classes
from rest_framework.authentication import TokenAuthentication
from rest_framework.permissions import IsAuthenticated
from accounts.models import UserRegistration, CompanyRegistration


from django.views.decorators.http import require_GET, require_POST



@api_view(['GET'])
@authentication_classes([TokenAuthentication])
@permission_classes([IsAuthenticated])
def get_chat_messages(request):
    print("\n===== REQUEST DATA =====")
    print(f"User: {request.user.username}")
    print(f"Email: {request.user.email}")
    print(f"Params: {request.GET}")

    try:
        # 1. Identify sender profile
        sender_user = None
        sender_company = None
        
        # First try to find by email (more reliable)
        if request.user.email:
            sender_user = UserRegistration.objects.filter(email=request.user.email).first()
            if not sender_user:
                sender_company = CompanyRegistration.objects.filter(email=request.user.email).first()
        
        # Fallback to username if email not found or empty
        if not sender_user and not sender_company:
            sender_user = UserRegistration.objects.filter(username=request.user.username).first()
            if not sender_user:
                sender_company = CompanyRegistration.objects.filter(username=request.user.username).first()

        if not sender_user and not sender_company:
            print("🔴 No profile found for authenticated user")
            return JsonResponse(
                {'error': 'No user profile found. Please complete your registration.'},
                status=404
            )

        # 2. Validate request parameters
        receiver_id = request.GET.get('receiver_id')
        receiver_type = request.GET.get('receiver_type')

        if not receiver_id or not receiver_type:
            return JsonResponse(
                {'error': 'Both receiver_id and receiver_type parameters are required'},
                status=400
            )

        try:
            receiver_id = int(receiver_id)
        except ValueError:
            return JsonResponse(
                {'error': 'receiver_id must be a valid integer'},
                status=400
            )

        if receiver_type not in ['user', 'company']:
            return JsonResponse(
                {'error': 'receiver_type must be either "user" or "company"'},
                status=400
            )

        # 3. Fetch messages
        if receiver_type == 'user':
            messages = Message.objects.filter(
                (Q(sender_user=sender_user) | Q(sender_company=sender_company)) &
                Q(receiver_user_id=receiver_id)
            )
        else:  # company
            messages = Message.objects.filter(
                (Q(sender_user=sender_user) | Q(sender_company=sender_company)) &
                Q(receiver_company_id=receiver_id)
            )

        messages = messages.select_related(
            'sender_user', 'sender_company', 'receiver_user', 'receiver_company'
        ).order_by('-timestamp')[:50]

        # 4. Serialize messages
        message_list = []
        for msg in messages:
            # Handle sender
            sender = msg.sender_user or msg.sender_company
            sender_data = {
                'type': 'user' if msg.sender_user else 'company',
                'id': sender.id,
                'username': sender.username,
                'email': sender.email if hasattr(sender, 'email') else None
            }

            # Handle receiver
            receiver = msg.receiver_user or msg.receiver_company
            receiver_data = {
                'type': 'user' if msg.receiver_user else 'company',
                'id': receiver.id,
                'username': receiver.username,
                'email': receiver.email if hasattr(receiver, 'email') else None
            }

            message_list.append({
                'id': msg.id,
                'content': msg.content,
                'timestamp': msg.timestamp.isoformat(),
                'sender': sender_data,
                'receiver': receiver_data,
                'message_type': msg.message_type,
                'status': msg.status or 'delivered',
                'attachment': msg.attachment.url if msg.attachment else None
            })

        return JsonResponse({
            'messages': message_list,
            'meta': {
                'count': len(message_list),
                'sender_type': 'user' if sender_user else 'company',
                'sender_id': sender_user.id if sender_user else sender_company.id
            }
        }, status=200)

    except Exception as e:
        import traceback
        traceback.print_exc()
        return JsonResponse(
            {
                'error': 'An unexpected error occurred',
                'details': str(e),
                'type': type(e).__name__
            },
            status=500
        )
######################
from django.core.exceptions import ValidationError
from django.views.decorators.csrf import csrf_exempt
from django.contrib.auth.decorators import login_required
from django.views.decorators.http import require_POST
from .models import Notification
from accounts.models import UserRegistration, CompanyRegistration
import requests
from django.conf import settings

@login_required
@require_POST
def send_notification(request):
    try:
        data = json.loads(request.body)
        
        # 1. First save to database
        notification = Notification.objects.create(
            recipient_id=data['recipient_id'],
            recipient_type=data['recipient_type'],
            sender_id=request.user.id,
            sender_type='company' if hasattr(request.user, 'companyregistration') else 'user',
            notification_type=data['type'],
            message=data['message'],
            related_id=data.get('related_id')
        )
        
        # 2. Send via OneSignal directly from the view
        one_signal_payload = {
            'app_id': settings.ONESIGNAL_APP_ID,
            'contents': {'en': data['message']},
            'headings': {'en': data.get('title', 'New Notification')},
            'data': {
                'type': data['type'],
                'sender_id': request.user.id,
                'sender_type': 'company' if hasattr(request.user, 'companyregistration') else 'user',
                'related_id': data.get('related_id')
            },
            'filters': [
                {
                    'field': 'tag', 
                    'key': 'external_user_id',
                    'relation': '=', 
                    'value': str(data['recipient_id'])
                }
            ]
        }
        
        headers = {
            'Authorization': f'Basic {settings.ONESIGNAL_API_KEY}',
            'Content-Type': 'application/json'
        }
        
        # Make the request to OneSignal API
        response = requests.post(
            'https://onesignal.com/api/v1/notifications',
            json=one_signal_payload,
            headers=headers
        )
        
        # Check if OneSignal request was successful
        if response.status_code != 200:
            return JsonResponse({
                'status': 'error',
                'message': 'Failed to send push notification',
                'onesignal_response': response.json()
            }, status=500)
        
        return JsonResponse({
            'status': 'success',
            'notification_id': notification.id,
            'onesignal_response': response.json()
        })
    
    except json.JSONDecodeError:
        return JsonResponse({'error': 'Invalid JSON'}, status=400)
    except Exception as e:
        return JsonResponse({'error': str(e)}, status=500)

@login_required
@require_GET
def get_notifications(request):
    try:
        # Determine if user is a company or regular user
        is_company = hasattr(request.user, 'companyregistration')
        
        notifications = Notification.objects.filter(
            recipient_id=request.user.id,
            recipient_type='company' if is_company else 'user'
        ).order_by('-created_at')[:20]

        notifs_list = []
        for notif in notifications:
            notifs_list.append({
                'id': notif.id,
                'type': notif.notification_type,
                'message': notif.message,
                'is_read': notif.is_read,
                'created_at': notif.created_at.strftime("%Y-%m-%d %H:%M"),
                'sender': {
                    'id': notif.sender_id,
                    'type': notif.sender_type
                },
                'related_id': notif.related_id
            })

        return JsonResponse({'notifications': notifs_list}, safe=False)

    except Exception as e:
        return JsonResponse({'error': str(e)}, status=500)

@login_required
@require_POST
def mark_as_read(request):
    try:
        data = json.loads(request.body)
        Notification.objects.filter(
            id=data['notification_id'],
            recipient_id=request.user.id,
            recipient_type='company' if hasattr(request.user, 'companyregistration') else 'user'
        ).update(is_read=True)
        
        return JsonResponse({'status': 'success'})
    
    except json.JSONDecodeError:
        return JsonResponse({'error': 'Invalid JSON'}, status=400)
    except Exception as e:
        return JsonResponse({'error': str(e)}, status=500)