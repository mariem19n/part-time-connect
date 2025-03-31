from django.shortcuts import get_object_or_404
from django.http import JsonResponse
from .models import Job, JobInteraction
from django.views.decorators.http import require_GET
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_POST
from accounts.models import CompanyRegistration
import json
###########################################################################POST job offer by company X >> Done
@csrf_exempt  # Remember to remove this in production!
@require_POST
def create_job_offer(request):
    try:
        print("Received job offer submission request")
        
        # Get company username from request
        company_username = request.POST.get('company_username')
        if not company_username:
            print("Missing company username")
            return JsonResponse({
                'status': 'error',
                'message': 'Company username is required'
            }, status=400)
        
        # Get company profile
        try:
            company = CompanyRegistration.objects.get(username=company_username)
            print(f"Company found: {company.username}")
        except CompanyRegistration.DoesNotExist:
            print("Company not found")
            return JsonResponse({
                'status': 'error',
                'message': 'Company not found'
            }, status=404)

        # Validate required fields
        required_fields = ['title', 'description']
        for field in required_fields:
            if not request.POST.get(field):
                print(f"Missing required field: {field}")
                return JsonResponse({
                    'status': 'error',
                    'message': f'Missing required field: {field}'
                }, status=400)

        # Create job
        job = Job(
            company=company,
            title=request.POST['title'],
            description=request.POST['description'],
            location=request.POST.get('location', 'Remote'),
            salary=float(request.POST['salary']) if request.POST.get('salary') else None,
            is_salary_negotiable=request.POST.get('is_salary_negotiable', 'false').lower() == 'true',
            working_hours=request.POST.get('working_hours', 'Flexible'),
            duration=int(request.POST.get('duration', 0)),
            contract_type=request.POST.get('contract_type', 'Part-Time')
        )

        # Handle JSON fields
        json_fields = ['requirements', 'benefits', 'responsibilities']
        for field in json_fields:
            field_data = request.POST.get(field)
            if field_data:
                try:
                    setattr(job, field, json.loads(field_data))
                    print(f"Processed {field} as JSON")
                except json.JSONDecodeError:
                    setattr(job, field, field_data.split('\n'))
                    print(f"Processed {field} as plain text")

        # Handle file upload
        if 'contract_pdf' in request.FILES:
            job.contract_pdf = request.FILES['contract_pdf']
            print("PDF contract attached")

        job.save()
        print(f"Job created successfully with ID: {job.id}")

        return JsonResponse({
            'status': 'success',
            'job_id': job.id,
            'message': 'Job offer created successfully'
        }, status=201)

    except Exception as e:
        print(f"Error creating job offer: {str(e)}")
        return JsonResponse({
            'status': 'error',
            'message': 'Internal server error'
        }, status=500)
###########################################################################List job offer posted by company X >> Done
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




