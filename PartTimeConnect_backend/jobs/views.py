from django.shortcuts import get_object_or_404
from django.http import JsonResponse
from .models import Job, JobInteraction
from django.http import JsonResponse
from django.views.decorators.http import require_GET
##################################################################List job offer posted by company X >> Done
@require_GET
def job_list(request):
    try:
        company_id = request.GET.get('company_id')  # Get company ID from request
        if not company_id:
            return JsonResponse({'error': 'company_id parameter is required'}, status=400)
        jobs = Job.objects.filter(company__id=company_id)  # Filter jobs by company ID
        job_data = [
            {
                'id': job.id,
                'title': job.title,
                'location': job.location,
                'salary': job.salary if job.salary is not None else 0.0,
                'is_salary_negotiable': job.is_salary_negotiable,
                'working_hours': job.working_hours,
                'duration': job.duration,
                'contract_type': job.contract_type,
                'requirements': job.requirements,  # JSONField
            }
            for job in jobs
        ]
        return JsonResponse(job_data, safe=False)
    except Exception as e:
        return JsonResponse({'error': str(e)}, status=500)
##################################################################List job offer details >> Done
@require_GET
def job_details(request, job_id):
    try:
        job = Job.objects.get(id=job_id)
        job_data = {
            'id': job.id,
            'title': job.title,
            'description': job.description,
            'location': job.location,
            'salary': job.salary if job.salary is not None else 0.0,
            'is_salary_negotiable': job.is_salary_negotiable,
            'working_hours': job.working_hours,
            'duration': job.duration,
            'contract_type': job.contract_type,
            'requirements': job.requirements,  # JSONField
            'benefits': job.benefits,  # JSONField
            'responsibilities': job.responsibilities,  # JSONField
            'contract_pdf': job.contract_pdf.url if job.contract_pdf else None,
            'applications_count': job.applications_count,
            'views_count': job.views_count,
            'saves_count': job.saves_count,
            'popularity_score': job.popularity_score,
            'company_name': job.company.username,  # Fetch company name
        }
        return JsonResponse(job_data)
    except Job.DoesNotExist:
        return JsonResponse({'error': 'Job not found'}, status=404)
    except Exception as e:
        return JsonResponse({'error': str(e)}, status=500)
################################################################## Recommendation

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




