from django.urls import path
from .views import recommendations_api

urlpatterns = [
    path("api/recommendations/", recommendations_api, name="recommendations_api"),
]
