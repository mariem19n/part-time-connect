# jobs/urls.py
from django.urls import path
from . import views

urlpatterns = [
    path("job/<int:job_id>/view/", views.view_job, name="view_job"),
    path("job/<int:job_id>/save/", views.save_job, name="save_job"),
    path("job/<int:job_id>/apply/", views.apply_job, name="apply_job"),
]