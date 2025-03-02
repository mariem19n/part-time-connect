from django.shortcuts import get_object_or_404
from django.http import JsonResponse
from .models import Job, JobInteraction

def view_job(request, job_id):
    job = get_object_or_404(Job, id=job_id)
    JobInteraction.objects.create(job=job, user=request.user if request.user.is_authenticated else None, interaction_type='VIEW')
    return JsonResponse({"message": "Job viewed", "popularity_score": job.popularity_score})

def save_job(request, job_id):
    job = get_object_or_404(Job, id=job_id)
    JobInteraction.objects.create(job=job, user=request.user if request.user.is_authenticated else None, interaction_type='SAVE')
    return JsonResponse({"message": "Job saved", "popularity_score": job.popularity_score})

def apply_job(request, job_id):
    job = get_object_or_404(Job, id=job_id)
    JobInteraction.objects.create(job=job, user=request.user if request.user.is_authenticated else None, interaction_type='APPLY')
    return JsonResponse({"message": "Application submitted", "popularity_score": job.popularity_score})




