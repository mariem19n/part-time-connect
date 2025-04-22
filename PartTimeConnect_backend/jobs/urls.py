# jobs/urls.py
from django.urls import path
from . import views
from .views import job_list,create_job_offer, delete_job_offer, get_jobs

urlpatterns = [

    path('job-list/', job_list, name='job-list'),
    path('job-details/<int:job_id>/', views.job_details, name='job-details'),
    path('offer/',create_job_offer, name='job-offer'),
    path('offer/<int:job_id>/', delete_job_offer, name='delete-job-offer'),
    path('get_jobs/', get_jobs, name='get_jobs'),


    path("job/<int:job_id>/view/", views.view_job, name="view_job"),
    path("job/<int:job_id>/save/", views.save_job, name="save_job"),
    path("job/<int:job_id>/apply/", views.apply_job, name="apply_job"),

]