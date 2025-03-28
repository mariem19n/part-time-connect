from django.urls import path
from . import views

urlpatterns = [
    path('jobs/', views.job_seeker_recommendations),
    path('candidates/', views.recruiter_recommendations),
    path('candidates/<int:job_id>/', views.recruiter_recommendations),

]