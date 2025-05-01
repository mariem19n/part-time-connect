from django.shortcuts import get_object_or_404
from django.http import JsonResponse
from .models import Job, JobInteraction, JobApplication, Shortlist
from django.views.decorators.http import require_http_methods
from django.views.decorators.http import require_GET
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_POST
from accounts.models import CompanyRegistration
import json
from django.core.files.uploadedfile import InMemoryUploadedFile
from django.http.multipartparser import MultiPartParser, MultiPartParserError
from django.core.paginator import Paginator
from django.http import JsonResponse
from django.views.decorators.http import require_GET
from django.contrib.auth.decorators import login_required
from .models import Shortlist, UserProfile, UserRegistration
import json
from django.core.exceptions import ObjectDoesNotExist
from rest_framework.authentication import TokenAuthentication
from rest_framework.permissions import IsAuthenticated
from rest_framework.decorators import api_view, authentication_classes, permission_classes
from .serializers import JobApplicationSerializer
from rest_framework.views import APIView

########################################################################## Get saved  candidat from shortlist >> Done
@api_view(['GET'])
@authentication_classes([TokenAuthentication])
@permission_classes([IsAuthenticated])
@require_GET
def get_shortlisted_candidates(request):
    print(f"Request headers: {request.headers}")  # Debug headers
    
    print(f"Authenticated as: {request.user}")  # Debug user
    
    try:
        recruiter = CompanyRegistration.objects.get(username=request.user.username)
        print(f"Found recruiter: {recruiter.username}")
        
        shortlists = Shortlist.objects.filter(
            recruiter=recruiter
        ).select_related('candidate', 'candidate__user')
        
        data = [{
            'user_id': sl.candidate.user.id,
            'user_name': sl.candidate.full_name,
            'shortlisted_at': sl.shortlisted_at.strftime('%Y-%m-%d'),
            'skills': sl.candidate.skills,
        } for sl in shortlists]
        
        return JsonResponse(data, safe=False)
        
    except CompanyRegistration.DoesNotExist:
        return JsonResponse(
            {'error': 'Only recruiters can access this endpoint'},
            status=403
        )

########################################################################## unsaved a candidat from shortlist >> Done
@api_view(['DELETE'])
@authentication_classes([TokenAuthentication])
@permission_classes([IsAuthenticated])
def remove_from_shortlist(request, candidate_id):
    print("\n=== DELETE FROM SHORTLIST ===")
    print(f"Candidate ID: {candidate_id}")
    
    try:
        recruiter = CompanyRegistration.objects.get(username=request.user.username)
        print(f"Recruiter: {recruiter.username}")
        
        deleted_count, _ = Shortlist.objects.filter(
            recruiter=recruiter,
            candidate_id=candidate_id
        ).delete()
        
        print(f"Deleted {deleted_count} entries")
        
        if deleted_count == 0:
            print("Warning: No matching record found")
            return JsonResponse({'status': 'not found'}, status=404)
            
        return JsonResponse({'status': 'success'})
        
    except CompanyRegistration.DoesNotExist:
        print("Recruiter not found")
        return JsonResponse({'error': 'Only recruiters can delete candidates'}, status=403)
        
    except Exception as e:
        print("Error:", str(e))
        return JsonResponse({'error': str(e)}, status=500)
########################################################################## update job applications status of an job offer X >> Done
@csrf_exempt
@require_http_methods(["PUT"])
def update_application_status(request, job_id, user_id):
    try:
        application = JobApplication.objects.get(job_id=job_id, user_id=user_id)
        data = json.loads(request.body)
        application.status = data.get('status', application.status)
        application.save()
        return JsonResponse({'status': 'success'})
    except JobApplication.DoesNotExist:
        return JsonResponse({'status': 'error', 'message': 'Application not found'}, status=404)
########################################################################## Get job applications Number of an job offer X >> Done
@require_GET
def job_applications_count(request, job_id):
    count = JobApplication.objects.filter(job_id=job_id).count()
    return JsonResponse({'count': count})
########################################################################## Get job applications of an job offer X >> Done
@require_GET
def job_applications(request, job_id):
    applications = JobApplication.objects.filter(job_id=job_id).select_related('user')
    
    data = [{
        'user_id': app.user.id,
        'user_name': app.user.full_name,
        'status': app.status,
        'application_date': app.application_date.strftime('%Y-%m-%d'),
    } for app in applications]
    
    return JsonResponse(data, safe=False)
##########################################################################DELETE job offer created by company X >> Done
@csrf_exempt
@require_http_methods(["DELETE"])
def delete_job_offer(request, job_id):
    try:
        # Get authorization header
        auth_header = request.META.get('HTTP_AUTHORIZATION') or request.headers.get('Authorization')
        if not auth_header or not auth_header.startswith('Token '):
            return JsonResponse({'status': 'error', 'message': 'Unauthorized'}, status=401)
        token = auth_header.split(' ')[1]
        # Verify token using DRF TokenAuthentication
        from rest_framework.authtoken.models import Token
        try:
            token_obj = Token.objects.select_related('user').get(key=token)
            user = token_obj.user
        except Token.DoesNotExist:
            return JsonResponse({'status': 'error', 'message': 'Invalid token'}, status=401)

        # Get the job
        try:
            job = Job.objects.get(id=job_id)
        except Job.DoesNotExist:
            return JsonResponse({'status': 'error', 'message': 'Job not found'}, status=404)
        if job.company.username != user.username and not user.is_staff:
            return JsonResponse({'status': 'error', 'message': 'Not authorized'}, status=403)
        job.delete()
        return JsonResponse({'status': 'success', 'message': 'Job deleted'}, status=200)
    except Exception as e:
        print(f"Error: {str(e)}")
        return JsonResponse({'status': 'error', 'message': str(e)}, status=500)
###########################################################################POST and PUT job offer by company X >> Done
@csrf_exempt
@require_http_methods(["POST", "PUT"])
def create_job_offer(request):
    try:
        print("\n===== Request Data =====")
        print("Method:", request.method)
        print("Content-Type:", request.content_type)

        # Manually parse multipart/form-data for PUT requests
        if request.method == 'PUT' and request.content_type.startswith('multipart/form-data'):
            try:
                parser = MultiPartParser(request.META, request, request.upload_handlers)
                data, files = parser.parse()
                request.POST = data
                # We no longer try to set request.FILES manually
                request._files = files  # Set the files attribute in a valid way
            except MultiPartParserError as e:
                print(f"Parser error: {str(e)}")
                return JsonResponse({'status': 'error', 'message': 'Invalid multipart data'}, status=400)

        print("POST data:", request.POST)
        print("FILES:", request.FILES)
        print(f"Received {'update' if request.method == 'PUT' else 'create'} job request")

        # Extract data
        if 'data' in request.POST:
            json_data = json.loads(request.POST['data'])
        else:
            json_data = request.POST.dict()

        company_username = json_data.get('company_username')
        if not company_username:
            return JsonResponse({'status': 'error', 'message': 'Company username is required'}, status=400)

        from .models import CompanyRegistration, Job  # Adjust import path as needed

        try:
            company = CompanyRegistration.objects.get(username=company_username)
        except CompanyRegistration.DoesNotExist:
            return JsonResponse({'status': 'error', 'message': 'Company not found'}, status=404)

        if request.method == 'PUT':
            job_id = json_data.get('job_id')
            if not job_id:
                return JsonResponse({'status': 'error', 'message': 'Job ID is required for updates'}, status=400)
            try:
                job = Job.objects.get(id=job_id, company=company)
            except Job.DoesNotExist:
                return JsonResponse({'status': 'error', 'message': 'Job not found or not owned by company'}, status=404)
        else:
            job = Job(company=company)

        # Set fields
        job.title = json_data.get('title', job.title)
        job.description = json_data.get('description', job.description)
        job.location = json_data.get('location', job.location)
        if 'salary' in json_data:
            job.salary = float(json_data['salary']) if json_data['salary'] else None
        job.is_salary_negotiable = str(json_data.get('is_salary_negotiable', job.is_salary_negotiable)).lower() == 'true'
        job.working_hours = json_data.get('working_hours', job.working_hours)
        if 'duration' in json_data:
            job.duration = int(json_data['duration']) if json_data['duration'] else None
        job.contract_type = json_data.get('contract_type', job.contract_type)

        # Parse complex fields
        for field in ['requirements', 'benefits', 'responsibilities']:
            if field in json_data:
                try:
                    setattr(job, field, json_data[field] if isinstance(json_data[field], list) else json.loads(json_data[field]))
                except json.JSONDecodeError:
                    setattr(job, field, str(json_data[field]).split('\n'))

        if 'contract_pdf' in request.FILES:
            job.contract_pdf = request.FILES['contract_pdf']

        job.save()

        return JsonResponse({
            'status': 'success',
            'job_id': job.id,
            'message': f"Job {'updated' if request.method == 'PUT' else 'created'} successfully"
        }, status=200 if request.method == 'PUT' else 201)

    except Exception as e:
        print(f"Error processing job: {str(e)}")
        return JsonResponse({'status': 'error', 'message': 'Internal server error'}, status=500)
###########################################################################List job offer >> Done
@require_GET
def get_jobs(request):
    try:
        jobs = Job.objects.all().select_related('company')[:10]  # Limit to 10 for testing
        jobs_list = []
        
        for job in jobs:
            jobs_list.append({
                'id': job.id,
                'title': job.title,
                'description': job.description,
                'location': job.location,
                'salary': str(job.salary) if job.salary else None,  # Convert Decimal to string
                'working_hours': job.working_hours,
                'contract_type': job.contract_type,
                'duration': job.duration,

            })
            
        return JsonResponse({'jobs': jobs_list}, safe=False)
    except Exception as e:
        return JsonResponse({'error': str(e)}, status=500)
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
###########################################################################List job offer details >> Done
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
################################################################################################ Tracking interactions candidat->job offer >>>Done
"""Ces fonctions Django enregistrent les actions d’un utilisateur (vue, sauvegarde ou candidature) sur une offre 
d’emploi en créant une entrée dans la base de données via le modèle JobInteraction, et retournent un statut JSON."""
@csrf_exempt
@require_POST
def view_job(request, job_id):
    print(f"\n===== Starting view_job endpoint =====")
    print(f"Received request for job_id: {job_id}")
    print(f"Request method: {request.method}")
    print(f"Request path: {request.path}")
    print(f"User authenticated: {request.user.is_authenticated}")
    
    try:
        user_id = request.user.id if request.user.is_authenticated else None
        print(f"Creating view interaction for job {job_id} by user {user_id}")
        
        JobInteraction.objects.create(
            job_id=job_id,
            user_id=user_id,
            interaction_type='VIEW'
        )
        
        print("===== Interaction recorded successfully =====")
        return JsonResponse({'status': 'success'})
        
    except Exception as e:
        print(f"\n!!! ERROR in view_job !!!")
        print(f"Type: {type(e).__name__}")
        print(f"Message: {str(e)}")
        print("Full traceback:")
        import traceback
        traceback.print_exc()
        print("===== Failed =====")
        return JsonResponse({'status': 'error', 'message': str(e)}, status=400)

@csrf_exempt
@require_POST
def save_job(request, job_id):
    print(f"\n===== Starting save_job endpoint =====")
    print(f"Received request for job_id: {job_id}")
    print(f"Request method: {request.method}")
    print(f"Request path: {request.path}")
    print(f"User authenticated: {request.user.is_authenticated}")
    
    try:
        user_id = request.user.id if request.user.is_authenticated else None
        print(f"Creating save interaction for job {job_id} by user {user_id}")
        
        JobInteraction.objects.create(
            job_id=job_id,
            user_id=user_id,
            interaction_type='SAVE'
        )
        
        print("===== Save recorded successfully =====")
        return JsonResponse({'status': 'success'})
        
    except Exception as e:
        print(f"\n!!! ERROR in save_job !!!")
        print(f"Type: {type(e).__name__}")
        print(f"Message: {str(e)}")
        print("Full traceback:")
        import traceback
        traceback.print_exc()
        print("===== Failed =====")
        return JsonResponse({'status': 'error', 'message': str(e)}, status=400)



@csrf_exempt
@require_POST
def apply_job(request, job_id):
    print(f"\n===== Starting apply_job endpoint =====")
    print(f"Received request for job_id: {job_id}")
    print(f"Request method: {request.method}")
    print(f"Request path: {request.path}")
    print(f"User authenticated: {request.user.is_authenticated}")
    
    try:
        user_id = request.user.id if request.user.is_authenticated else None
        print(f"Creating apply interaction for job {job_id} by user {user_id}")
        
        JobInteraction.objects.create(
            job_id=job_id,
            user_id=user_id,
            interaction_type='APPLY'
        )
        
        print("===== Application recorded successfully =====")
        return JsonResponse({'status': 'success'})
        
    except Exception as e:
        print(f"\n!!! ERROR in apply_job !!!")
        print(f"Type: {type(e).__name__}")
        print(f"Message: {str(e)}")
        print("Full traceback:")
        import traceback
        traceback.print_exc()
        print("===== Failed =====")
        return JsonResponse({'status': 'error', 'message': str(e)}, status=400)

###########################################################################Apply to job

from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status
from accounts.models import UserProfile
from .models import Job, JobApplication
import json
from django.views.decorators.csrf import csrf_exempt
@csrf_exempt
@api_view(['POST'])
def apply_to_job(request):
    try:
        data = json.loads(request.body)

        user_id = data.get('user_id')
        job_id = data.get('job_id')
        message = data.get('message', '')
        expected_salary = data.get('expected_salary')
        available_now = data.get('available_now', False)

        if not user_id or not job_id:
            return Response({'error': 'user_id and job_id are required'}, status=status.HTTP_400_BAD_REQUEST)

        user_profile = UserProfile.objects.get(user_id=user_id)  # user_id est le FK vers UserRegistration
        job = Job.objects.get(id=job_id)

        JobApplication.objects.create(
            user=user_profile,
            job=job,
            message=message,
            expected_salary=expected_salary,
            available_now=available_now,
            duration=job.duration,  # On prend la durée de l'offre
            status='Applied'
        )

        return Response({'message': 'Application submitted successfully'}, status=status.HTTP_201_CREATED)

    except UserProfile.DoesNotExist:
        return Response({'error': 'User not found'}, status=status.HTTP_404_NOT_FOUND)
    except Job.DoesNotExist:
        return Response({'error': 'Job not found'}, status=status.HTTP_404_NOT_FOUND)
    except Exception as e:
        return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    

##########################################################
class UserJobApplicationsView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        try:
            # Get the UserRegistration instance using the current user's username
            user_reg = get_object_or_404(UserRegistration, username=request.user.username)
            
            # Get the related UserProfile
            user_profile = get_object_or_404(UserProfile, user=user_reg)
            
            # Filter applications by the user's profile
            applications = JobApplication.objects.filter(user=user_profile)
            
            # Serialize the data
            serializer = JobApplicationSerializer(applications, many=True)
            return Response(serializer.data)

        except Exception as e:
            return Response(
                {"error": str(e)},
                status=status.HTTP_400_BAD_REQUEST
            )
