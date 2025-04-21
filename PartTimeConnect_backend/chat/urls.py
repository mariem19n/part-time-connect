from django.urls import path
from .views import get_notifications
from .views import mark_as_read
from .views import send_notification
from . import views

urlpatterns = [
    path('messages/', views.get_chat_messages, name='get_chat_messages'),
    path('notifications/', get_notifications, name='get_notifications'),
    path('notifications/read/', mark_as_read, name='mark_as_read'),
    path('notifications/send/', send_notification, name='send_notification'),
]