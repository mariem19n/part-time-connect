# jobs/urls.py
from django.urls import path
from . import views
from .views import job_list,create_job_offer, delete_job_offer, get_jobs ,view_job, save_job,apply_job,get_shortlisted_candidates , apply_to_job
from .views import UserJobApplicationsView


urlpatterns = [

    path('job-list/', job_list, name='job-list'),
    path('job-details/<int:job_id>/', views.job_details, name='job-details'),
    path('offer/',create_job_offer, name='job-offer'),
    path('offer/<int:job_id>/', delete_job_offer, name='delete-job-offer'),
    path('get_jobs/', get_jobs, name='get_jobs'),
    path("<int:job_id>/view/", views.view_job, name="view_job"),
    path("<int:job_id>/save/", views.save_job, name="save_job"),
    path("<int:job_id>/apply/", views.apply_job, name="apply_job"),
    path('<int:job_id>/applications/', views.job_applications, name='job_applications'),
    path('<int:job_id>/applications/count/', views.job_applications_count, name='job_applications_count'),
    path('<int:job_id>/applications/<int:user_id>/', views.update_application_status, name='update_application_status'),
    path('shortlists/', get_shortlisted_candidates, name='get_shortlisted_candidates'),
    path('shortlists/<int:candidate_id>/', views.remove_from_shortlist, name='remove_from_shortlist'),
    path('api/apply_to_job/', apply_to_job, name='apply_to_job'),
    path('my-applications/', UserJobApplicationsView.as_view(), name='my-applications'),


]