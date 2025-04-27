from django.shortcuts import render
from django.http import JsonResponse
from django.views.decorators.http import require_GET, require_POST
from django.views.decorators.csrf import csrf_exempt
from django.contrib.auth.decorators import login_required
from .models import Message
from django.db.models import Q
import json
from rest_framework.decorators import api_view, authentication_classes, permission_classes
from rest_framework.authentication import TokenAuthentication
from rest_framework.permissions import IsAuthenticated
from accounts.models import UserRegistration, CompanyRegistration
######## Messagerie ##########################################################Fetch complete two-way chat history >>> Done
@api_view(['GET'])
@authentication_classes([TokenAuthentication])
@permission_classes([IsAuthenticated])
def  get_conversation(request):
    print("\n===== CONVERSATION REQUEST =====")
    print(f"User: {request.user.username}")
    
    try:
        # 1. Identify current user's profile
        current_user = None
        current_company = None
        
        # Try to find by email first
        if request.user.email:
            current_user = UserRegistration.objects.filter(email=request.user.email).first()
            if not current_user:
                current_company = CompanyRegistration.objects.filter(email=request.user.email).first()
        
        # Fallback to username
        if not current_user and not current_company:
            current_user = UserRegistration.objects.filter(username=request.user.username).first()
            if not current_user:
                current_company = CompanyRegistration.objects.filter(username=request.user.username).first()

        if not current_user and not current_company:
            return JsonResponse(
                {'error': 'No profile found for authenticated user'},
                status=404
            )

        # 2. Get conversation parameters
        other_id = request.GET.get('other_id')
        other_type = request.GET.get('other_type')
        
        if not other_id or not other_type:
            return JsonResponse(
                {'error': 'Both other_id and other_type parameters are required'},
                status=400
            )

        try:
            other_id = int(other_id)
        except ValueError:
            return JsonResponse(
                {'error': 'other_id must be a valid integer'},
                status=400
            )

        if other_type not in ['user', 'company']:
            return JsonResponse(
                {'error': 'other_type must be either "user" or "company"'},
                status=400
            )

        # 3. Fetch entire conversation (both sent and received messages)
        if current_user:  # Current user is a JobSeeker
            if other_type == 'user':
                messages = Message.objects.filter(
                    (Q(sender_user=current_user, receiver_user_id=other_id) |
                     Q(receiver_user=current_user, sender_user_id=other_id))
                )
            else:  # other is company
                messages = Message.objects.filter(
                    (Q(sender_user=current_user, receiver_company_id=other_id) |
                     Q(receiver_user=current_user, sender_company_id=other_id))
                )
        else:  # Current user is a Company
            if other_type == 'user':
                messages = Message.objects.filter(
                    (Q(sender_company=current_company, receiver_user_id=other_id) |
                    Q(receiver_company=current_company, sender_user_id=other_id))
                )
            else:  # other is company
                messages = Message.objects.filter(
                    (Q(sender_company=current_company, receiver_company_id=other_id) |
                    Q(receiver_company=current_company, sender_company_id=other_id))
                )

        messages = messages.select_related(
            'sender_user', 'sender_company', 'receiver_user', 'receiver_company'
        ).order_by('-timestamp')[:100]  # Get last 100 messages

        # 4. Serialize messages
        message_list = []
        for msg in messages:
            # Determine if current user is the sender
            is_current_user = (
                (current_user and msg.sender_user == current_user) or
                (current_company and msg.sender_company == current_company)
            )
            
            # Handle sender info
            sender = msg.sender_user or msg.sender_company
            sender_data = {
                'type': 'user' if msg.sender_user else 'company',
                'id': sender.id,
                'username': sender.username
            }

            # Handle receiver info
            receiver = msg.receiver_user or msg.receiver_company
            receiver_data = {
                'type': 'user' if msg.receiver_user else 'company',
                'id': receiver.id,
                'username': receiver.username
            }

            message_list.append({
                'id': msg.id,
                'content': msg.content,
                'timestamp': msg.timestamp.isoformat(),
                'sender': sender_data,
                'receiver': receiver_data,
                'isMe': is_current_user,  # Frontend can use this directly
                'message_type': msg.message_type,
                'status': msg.status or 'delivered',
                'attachment': msg.attachment.url if msg.attachment else None
            })

        return JsonResponse({
            'messages': message_list,
            'meta': {
                'count': len(message_list),
                'current_user_type': 'user' if current_user else 'company',
                'current_user_id': current_user.id if current_user else current_company.id
            }
        }, status=200)

    except Exception as e:
        import traceback
        traceback.print_exc()
        return JsonResponse(
            {'error': str(e)},
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