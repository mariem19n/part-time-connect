# chat/consumers.py
import json
from channels.generic.websocket import AsyncWebsocketConsumer
from channels.db import database_sync_to_async
from django.core.exceptions import ValidationError
from .models import Message
from accounts.models import UserRegistration, CompanyRegistration, UserProfile
from jobs.models import JobApplication
from channels.auth import login, logout
from django.contrib.auth.models import AnonymousUser
from urllib.parse import parse_qs
from rest_framework.authtoken.models import Token
from jobs.models import Job
from django.http import JsonResponse
from django.views.decorators.http import require_GET
from django.views.decorators.csrf import csrf_exempt

class ChatConsumer(AsyncWebsocketConsumer):
    ######################################################"okay"
    async def connect(self):
        print("\n🔵 New WebSocket connection attempt")
    
        try:
            # 1. Extract token from query parameters
            query_params = parse_qs(self.scope["query_string"].decode())
            token_key = query_params.get('token', [None])[0]
            
            if not token_key:
                print("🔴 No token provided")
                await self.close(code=4001)
                return

            # 2. Authenticate user using token
            self.user = await self.get_user_from_token(token_key)
            
            if not self.user.is_authenticated:
                print("🔴 User not authenticated")
                await self.close(code=4001)
                return

            # 3. Get the associated custom user profile
            custom_user = await self.get_custom_user(self.user)
            
            if not custom_user:
                print(f"🔴 No custom user profile found for {self.user.username}")
                print("User must have either UserRegistration or CompanyRegistration")
                await self.close(code=4003)
                return

            # 4. Determine room name based on user type
            if custom_user.user_type == 'JobSeeker':
                self.room_name = f"user_{custom_user.id}"
            elif custom_user.user_type == 'JobProvider':
                self.room_name = f"company_{custom_user.id}"
            else:
                print("🔴 Unknown user type")
                await self.close(code=4003)
                return

            # Rest of the connection logic remains the same...
            self.room_group_name = f"chat_{self.room_name}"
            print(f"🟢 Connection accepted for {self.room_group_name}")

            await self.channel_layer.group_add(
                self.room_group_name,
                self.channel_name
            )

            await self.accept()
            print(f"🟢 WebSocket connection established for {self.room_group_name}")

        except Exception as e:
            print(f"🔴 Connection error: {str(e)}")
            await self.close(code=4000)
    @database_sync_to_async
    def get_custom_user(self, user):
        """Get either UserRegistration or CompanyRegistration for the user"""
        try:
            # Try email first
            if user.email:
                user_reg = UserRegistration.objects.filter(email=user.email).first()
                if user_reg:
                    return user_reg
                
                company_reg = CompanyRegistration.objects.filter(email=user.email).first()
                if company_reg:
                    return company_reg

            # Fallback to username matching if email is empty
            user_reg = UserRegistration.objects.filter(username=user.username).first()
            if user_reg:
                return user_reg
            
            company_reg = CompanyRegistration.objects.filter(username=user.username).first()
            if company_reg:
                return company_reg

            print(f"🔴 No custom user found for {user.username} (ID: {user.id})")
            return None
        except Exception as e:
            print(f"🔴 Error getting custom user: {e}")
            return None
    @database_sync_to_async
    def get_user_from_token(self, token_key):
        try:
            token = Token.objects.get(key=token_key)
            user = token.user
            
            # Debug print to check user details
            print(f"🔵 Authenticated user: {user.username}, Email: {user.email}")
            
            if not user.email:
                # Try to get email from custom models if Django user email is empty
                user_reg = UserRegistration.objects.filter(username=user.username).first()
                company_reg = CompanyRegistration.objects.filter(username=user.username).first()
                
                if user_reg:
                    user.email = user_reg.email
                elif company_reg:
                    user.email = company_reg.email
                else:
                    print("🔴 No email found in custom models either")
                    
            return user
        except Token.DoesNotExist:
            return AnonymousUser()

    async def disconnect(self, close_code):
        print(f"🟠 Déconnexion WebSocket (code: {close_code})")
        # Leave room group
        if hasattr(self, 'room_group_name'):
            await self.channel_layer.group_discard(
                self.room_group_name,
                self.channel_name
            )
    #######################################################""
    # Receive message from WebSocket
    async def receive(self, text_data):
        try:
            data = json.loads(text_data)
            message_type = data.get('type')
            
            if message_type == 'chat_message':
                await self.handle_chat_message(data)
            elif message_type == 'job_application':
                await self.handle_job_application(data)
            elif message_type == 'profile_view':
                await self.handle_profile_view(data)
                
        except Exception as e:
            print(f"🔴 Erreur de traitement: {str(e)}")
            await self.send(text_data=json.dumps({
                'error': str(e),
                'type': 'error'
            }))
    ######################################################"okay"
    async def handle_chat_message(self, data):
        try:
            # Determine sender type and get the appropriate sender instance
            if hasattr(self.user, 'userregistration'):
                sender_user = self.user.userregistration
                sender_company = None
                sender_type = 'user'
            elif hasattr(self.user, 'companyregistration'):
                sender_user = None
                sender_company = self.user.companyregistration
                sender_type = 'company'
            else:
                raise ValueError("Unknown sender type")
            
            # Prepare receiver data
            receiver_id = data['receiver_id']
            receiver_type = data['receiver_type']
            
            # Get receiver instance
            if receiver_type == 'user':
                receiver_user = await sync_to_async(UserRegistration.objects.get)(id=receiver_id)
                receiver_company = None
            else:
                receiver_user = None
                receiver_company = await sync_to_async(CompanyRegistration.objects.get)(id=receiver_id)
            
            # Save message to database
            message = await sync_to_async(Message.objects.create)(
                sender_user=sender_user,
                sender_company=sender_company,
                receiver_user=receiver_user,
                receiver_company=receiver_company,
                content=data['content'],
                message_type=data.get('message_type', 'text'),
                attachment=data.get('attachment'),
                status='delivered'
            )
            
            # Prepare response data
            response_data = {
                'id': str(message.id),
                'sender_id': str(sender_user.id if sender_user else sender_company.id),
                'sender_type': sender_type,
                'receiver_id': receiver_id,
                'receiver_type': receiver_type,
                'content': message.content,
                'timestamp': message.timestamp.isoformat(),
                'message_type': message.message_type,
                'status': message.status
            }
            
            # Add attachment URL if exists
            if message.attachment:
                response_data['attachment'] = self.scope['request'].build_absolute_uri(message.attachment.url)
            
            # Determine receiver's room name
            receiver_room = f"chat_{receiver_type}_{receiver_id}"
            
            # Send to receiver (not back to sender)
            if str(sender_user.id if sender_user else sender_company.id) != receiver_id:
                await self.channel_layer.group_send(
                    receiver_room,
                    {
                        'type': 'chat.message',
                        'message': response_data
                    }
                )
            
            # Also send back to sender for their own UI update
            sender_room = f"chat_{sender_type}_{sender_user.id if sender_user else sender_company.id}"
            await self.channel_layer.group_send(
                sender_room,
                {
                    'type': 'chat.message',
                    'message': response_data
                }
            )
            
        except Exception as e:
            logger.error(f"Error handling chat message: {str(e)}")
            await self.send_json({
                'type': 'error',
                'message': f"Failed to send message: {str(e)}"
            })
    #######################################################""
    async def handle_job_application(self, data):
        # In a real app, you'd create a JobApplication here
        job_application = await self.create_job_application(
            user_id=data['user_id'],
            job_id=data['job_id'],
            message=data.get('message')
        )
        
        # Get company room name
        company_room = f"company_{job_application.job.company.id}"
        
        # Send notification to company
        await self.channel_layer.group_send(
            f"chat_{company_room}",
            {
                'type': 'notification',
                'notification_type': 'job_application',
                'application': {
                    'id': job_application.id,
                    'user': await self.get_user_info(job_application.user),
                    'job': {
                        'id': job_application.job.id,
                        'title': job_application.job.title
                    },
                    'timestamp': job_application.application_date.isoformat(),
                    'message': job_application.message
                }
            }
        )

    async def handle_profile_view(self, data):
        # Save profile view notification
        viewer = self.user
        viewed_user_id = data['user_id']
        
        # Create a notification message
        message = await self.save_message(
            sender=viewer,
            receiver_id=viewed_user_id,
            receiver_type='user',
            content=f"Your profile was viewed by {viewer.username}",
            message_type='profile_view'
        )
        
        # Update profile views count
        await self.update_profile_views(viewed_user_id)
        
        # Send notification to user
        user_room = f"user_{viewed_user_id}"
        
        await self.channel_layer.group_send(
            f"chat_{user_room}",
            {
                'type': 'notification',
                'notification_type': 'profile_view',
                'viewer': await self.get_viewer_info(viewer),
                'timestamp': message.timestamp.isoformat()
            }
        )

    # Handler for chat messages from room group
    async def chat_message(self, event):
        await self.send(text_data=json.dumps(event))

    # Handler for notifications from room group
    async def notification(self, event):
        await self.send(text_data=json.dumps(event))
    @database_sync_to_async
    def save_message(self, sender, receiver_id, receiver_type, content, message_type, attachment=None):
        try:
            # Get sender - handle both UserRegistration and CompanyRegistration
            sender_user = None
            sender_company = None
            
            # Check if sender is UserRegistration
            if hasattr(sender, 'userregistration'):
                sender_user = sender.userregistration
            # Check if sender is CompanyRegistration
            elif hasattr(sender, 'companyregistration'):
                sender_company = sender.companyregistration
            else:
                # Fallback - try to find by email
                sender_user = UserRegistration.objects.filter(email=sender.email).first()
                if not sender_user:
                    sender_company = CompanyRegistration.objects.filter(email=sender.email).first()
            
            # Get receiver
            receiver_user = None
            receiver_company = None
            if receiver_type == 'user':
                receiver_user = UserRegistration.objects.get(id=receiver_id)
            else:
                receiver_company = CompanyRegistration.objects.get(id=receiver_id)
            
            message = Message(
                sender_user=sender_user,
                sender_company=sender_company,
                receiver_user=receiver_user,
                receiver_company=receiver_company,
                content=content,
                message_type=message_type,
                attachment=attachment
            )
            message.save()
            return message
        except Exception as e:
            print(f"Error saving message: {e}")
            raise


    @database_sync_to_async
    def create_job_application(self, user_id, job_id, message=None):
        user = UserRegistration.objects.get(id=user_id)
        job = Job.objects.get(id=job_id)
        
        application = JobApplication(
            user=user,
            job=job,
            message=message,
            status='applied'
        )
        application.save()
        return application

    @database_sync_to_async
    def update_profile_views(self, user_id):
        profile = UserProfile.objects.get(user__id=user_id)
        profile.profile_views += 1
        profile.save()
        profile.calculate_popularity_score()  # Recalculate popularity score

    @database_sync_to_async
    def get_sender_info(self, message):
        if message.sender_user:
            return {
                'type': 'user',
                'id': message.sender_user.id,
                'username': message.sender_user.username
            }
        else:
            return {
                'type': 'company',
                'id': message.sender_company.id,
                'username': message.sender_company.username
            }

    @database_sync_to_async
    def get_receiver_info(self, message):
        if message.receiver_user:
            return {
                'type': 'user',
                'id': message.receiver_user.id,
                'username': message.receiver_user.username
            }
        else:
            return {
                'type': 'company',
                'id': message.receiver_company.id,
                'username': message.receiver_company.username
            }

    @database_sync_to_async
    def get_user_info(self, user):
        return {
            'id': user.id,
            'username': user.username,
            'skills': user.skills
        }

    @database_sync_to_async
    def get_viewer_info(self, viewer):
        if hasattr(viewer, 'userregistration'):
            return {
                'type': 'user',
                'id': viewer.userregistration.id,
                'username': viewer.userregistration.username
            }
        else:
            return {
                'type': 'company',
                'id': viewer.companyregistration.id,
                'username': viewer.companyregistration.username,
                'jobtype': viewer.companyregistration.jobtype
            }
    
    @database_sync_to_async
    def get_chat_messages(self, user, receiver_id, receiver_type):
        if receiver_type == 'user':
            messages = Message.objects.filter(
                Q(sender_user=user, receiver_user_id=receiver_id) |
                Q(receiver_user=user, sender_user_id=receiver_id)
            )
        else:
            messages = Message.objects.filter(
                Q(sender_user=user, receiver_company_id=receiver_id) |
                Q(receiver_user=user, sender_company_id=receiver_id)
            )
        
        messages = messages.order_by('-timestamp')[:50]  # Get last 50 messages
        
        message_list = []
        for msg in messages:
            message_list.append({
                'id': str(msg.id),
                'content': msg.content,
                'timestamp': msg.timestamp.isoformat(),
                'sender': {
                    'type': 'user' if msg.sender_user else 'company',
                    'id': str(msg.sender_user.id) if msg.sender_user else str(msg.sender_company.id),
                    'username': msg.sender_user.username if msg.sender_user else msg.sender_company.username
                },
                'receiver': {
                    'type': 'user' if msg.receiver_user else 'company',
                    'id': str(msg.receiver_user.id) if msg.receiver_user else str(msg.receiver_company.id),
                    'username': msg.receiver_user.username if msg.receiver_user else msg.receiver_company.username
                },
                'message_type': msg.message_type,
                'status': 'delivered'
            })
        
        return message_list