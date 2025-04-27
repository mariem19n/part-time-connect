from django.urls import path
from .views import get_notifications ,get_conversation
from .views import mark_as_read
from .views import send_notification
from . import views

urlpatterns = [
    path('conversation/', views.get_conversation, name='get_conversation'),
    path('notifications/', get_notifications, name='get_notifications'),
    path('notifications/read/', mark_as_read, name='mark_as_read'),
    path('notifications/send/', send_notification, name='send_notification'),
]