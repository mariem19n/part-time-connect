from django.urls import path
from .views import SimpleAPI  # Import the SimpleAPI view

urlpatterns = [
    path('simple-api/', SimpleAPI.as_view(), name='simple-api'),
]
