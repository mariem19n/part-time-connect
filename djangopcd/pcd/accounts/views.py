import random
import json
import os
from rest_framework.decorators import api_view
from rest_framework.response import Response
from .models import PasswordResetCode, UserRegistration, CompanyRegistration
from django.core.mail import send_mail
from django.contrib.auth.decorators import login_required
from django.contrib.auth import authenticate , login, logout
from django.contrib.auth.hashers import make_password
from django.contrib.auth.models import User
from django.shortcuts import render, redirect
from django.conf import settings
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_protect, ensure_csrf_cookie, csrf_exempt
from django.views.decorators.http import require_http_methods
from django.core.files.storage import default_storage
from django.contrib.auth import update_session_auth_hash
from rest_framework.decorators import api_view
from .models import CompanyRegistration
from django.shortcuts import get_object_or_404
from django.contrib.auth.hashers import check_password
##########################
from django.shortcuts import render, redirect, get_object_or_404
from django.contrib.auth.decorators import login_required
from django.contrib import messages
from .forms import ProfileUpdateForm
from .models import UserRegistration
################################
from django.http import JsonResponse
from django.shortcuts import get_object_or_404
from django.views.decorators.csrf import csrf_exempt
import json
from .models import UserRegistration  # Ensure you import your model
########################################################################################################### Registration_Company Backend >>> Done
@csrf_exempt
@require_http_methods(["POST"])
def companyRegistration(request):
    if request.method == 'POST':
        try:
            # Get form data from request
            username = request.POST.get('username')
            email = request.POST.get('email')
            password = request.POST.get('password')
            jobtype = request.POST.get("jobtype", "")
            company_description = request.POST.get('company_description', '')
            photos = request.FILES.getlist('photo')

            # Validate required fields
            if not username or not email or not password or not jobtype or not photos or not company_description:
                return JsonResponse({'status': 'error', 'message': 'All fields are required'}, status=400)

            # Hash the password
            hashed_password = make_password(password)

            # Save photos to the media directory and store their paths
            saved_files = []
            for photo in photos:
                photo_path = default_storage.save(f"photos/{photo.name}", photo)
                saved_files.append(photo_path)

            # Create and save the CompanyRegistration object
            company_registration = CompanyRegistration(
                username=username,
                email=email,
                password=hashed_password,
                jobtype=jobtype,
                company_description=company_description,
            )
            company_registration.set_photos(saved_files)  # Store photo paths as a JSON string
            company_registration.save()

            return JsonResponse({
                'status': 'success',
                'message': 'Company registered successfully!',
                'files': saved_files
            }, status=201)

        except Exception as e:
            return JsonResponse({'status': 'error', 'message': str(e)}, status=500)

    return JsonResponse({'status': 'error', 'message': 'Invalid request method'}, status=405)
########################################################################################################### Registration_User Backend >>> Done
@csrf_exempt
@require_http_methods(["POST"])
def registerPage(request):
    if request.method == 'POST':
        try:

            # Get form data from request
            username = request.POST.get('username')
            email = request.POST.get('email')
            password = request.POST.get('password')
            skills = request.POST.get("skills", "")
            resumes = request.FILES.getlist('resume')

            # Validate required fields
            if not username or not email or not password or not skills or not resumes:
                return JsonResponse({'status': 'error', 'message': 'All fields are required'}, status=400)

            # Hash the password
            hashed_password = make_password(password)

            # Save resumes to the media directory and store their paths
            saved_files = []
            for resume in resumes:
                resume_path = default_storage.save(f"resumes/{resume.name}", resume)
                saved_files.append(resume_path)

            # Create and save the UserRegistration object
            user_registration = UserRegistration(
                username=username,
                email=email,
                password=hashed_password,
                skills=skills,
            )
            user_registration.set_resumes(saved_files)  # Store resume paths as a JSON string
            user_registration.save()

            return JsonResponse({
                'status': 'success',
                'message': 'User registered successfully!',
                'files': saved_files
            }, status=201)

        except Exception as e:
            return JsonResponse({'status': 'error', 'message': str(e)}, status=500)

    return JsonResponse({'status': 'error', 'message': 'Invalid request method'}, status=405)

########################################################################################################### Log_Out Backend >>> Failed
@csrf_protect  # Add CSRF protection explicitly
@login_required(login_url='login')
def logoutUser(request):
    if request.method == 'POST':  # Ensure logout is only allowed via POST
        logout(request)
        return redirect('login')
    return JsonResponse({'error': 'Invalid request method'}, status=405)
########################################################################################################### Log_In Backend >>> Done
@ensure_csrf_cookie  # Ensure CSRF cookie is set for GET requests
@csrf_protect  # Add CSRF protection for POST requests
@api_view(['GET', 'POST'])
def loginPage(request):
    if request.method == 'GET':
        # ✅ Ensure CSRF token is set
        return JsonResponse({'detail': 'CSRF cookie set'})

    if request.method == 'POST':
        try:
            # ✅ Parse JSON payload from request
            data = json.loads(request.body)
            username = data.get('username')
            password = data.get('password')
        except json.JSONDecodeError:
            return JsonResponse({'error': 'Invalid JSON payload'}, status=400)

        # ✅ Ensure both username and password are provided
        if not username or not password:
            return JsonResponse({'error': 'Username and password are required.'}, status=400)

        # ✅ Check if user is a Company
        try:
            company = CompanyRegistration.objects.get(username=username)
            if check_password(password, company.password):
                return JsonResponse({
                    'message': 'Company login successful',
                    'id': company.id,  # ✅ Added ID field
                    'username': company.username,
                    'user_type': 'company',
                    'email': company.email,
                    'jobtype': company.jobtype,
                    'company_description': company.company_description,
                    'photos': company.get_photos()
                }, status=200)
        except CompanyRegistration.DoesNotExist:
            pass  

        # ✅ Check if user is a Job Seeker
        try:
            job_seeker = UserRegistration.objects.get(username=username)
            if check_password(password, job_seeker.password):
                return JsonResponse({
                    'message': 'Job seeker login successful',
                    'id': job_seeker.id,  # ✅ Added ID field
                    'username': job_seeker.username,
                    'user_type': 'job_seeker',
                    'email': job_seeker.email,
                    'skills': job_seeker.skills,
                    'resumes': job_seeker.get_resumes()
                }, status=200)
        except UserRegistration.DoesNotExist:
            pass

        # ❌ If no account is found
        return JsonResponse({'error': 'Invalid username or password'}, status=401)

    return JsonResponse({'error': 'Invalid request method'}, status=405)



##########################################"getprofile >>> Done"

@csrf_exempt  # Disable CSRF for testing (Remove in production)
@api_view(['GET'])  # ✅ Enforces GET requests only
def get_profile(request, user_id):
    if request.method != "GET":
        return JsonResponse({"error": "Invalid request method"}, status=405)  # ✅ Uses request.method
    
    try:
        user = UserRegistration.objects.get(id=user_id)
        return JsonResponse({
            "id": user.id,
            "username": user.username,
            "email": user.email,
            #"location": user.location,
            "key_skills": user.skills.split(",") if user.skills else []
        }, status=200)
    except UserRegistration.DoesNotExist:
        return JsonResponse({"error": "User not found"}, status=404)


########################################################################################################### Password Reset Backend >>> Done
@api_view(['POST'])
def request_password_reset(request):
    email = request.data.get('email')  # Get email from request body
    if not email:
        return Response({'error': 'Email is required'}, status=400)

    # Check if email exists in the User model
    if not User.objects.filter(email=email).exists():
        # Send a generic response for security reasons
        return Response({'message': 'If the email exists, a code will be sent.'})

    # Generate 6-digit random code
    code = f"{random.randint(100000, 999999)}"

    # Save the code in the database
    PasswordResetCode.objects.create(email=email, code=code)

    # Send the reset code via email
    send_mail(
        'Password Reset Code',
        f'Your reset code is: {code}',
        settings.DEFAULT_FROM_EMAIL,
        [email],
        fail_silently=False,
    )

    return Response({'message': 'If the email exists, a code will be sent.'})


@api_view(['POST'])
def verify_reset_code(request):
    email = request.data.get('email')
    code = request.data.get('code')

    if not email or not code:
        return Response({'error': 'Email and code are required'}, status=400)

    try:
        # Check if the reset code exists
        reset_code = PasswordResetCode.objects.get(email=email, code=code)

        # Verify if the code has expired
        if reset_code.is_expired():
            return Response({'error': 'Code expired'}, status=400)

        return Response({'message': 'Code verified'})
    except PasswordResetCode.DoesNotExist:
        return Response({'error': 'Invalid email or code'}, status=400)


@api_view(['POST'])
def reset_password(request):
    email = request.data.get('email')
    code = request.data.get('code')
    new_password = request.data.get('new_password')

    if not email or not code or not new_password:
        return Response({'error': 'Email, code, and new password are required'}, status=400)

    try:
        # Fetch the reset code and validate
        reset_code = PasswordResetCode.objects.get(email=email, code=code)

        # Verify if the code has expired
        if reset_code.is_expired():
            return Response({'error': 'Code expired'}, status=400)

        # Reset the user's password
        user = User.objects.get(email=email)
        user.password = make_password(new_password)
        user.save()

        # Invalidate the reset code after successful reset
        reset_code.delete()
        return Response({'message': 'Password reset successful'})
    except PasswordResetCode.DoesNotExist:
        return Response({'error': 'Invalid email or code'}, status=400)
    except User.DoesNotExist:
        return Response({'error': 'User not found'}, status=400)
    
####################################################################### set company descpription

@csrf_exempt
def set_company_description(request, company_id):
    if request.method == "POST":
        company = get_object_or_404(CompanyRegistration, id=company_id)
        data = json.loads(request.body)
        company_description = data.get("company_description")

        if company_description is not None:
            company.company_description = company_description
            company.save()
            return JsonResponse({"message": "About Us updated successfully"})
        
        return JsonResponse({"error": "Invalid data"}, status=400)
    
    return JsonResponse({"error": "Invalid request method"}, status=405)
################################################################### edit company description
@csrf_exempt
def edit_company_description(request, company_id):
    if request.method == "PUT":
        company = get_object_or_404(CompanyRegistration, id=company_id)
        data = json.loads(request.body)
        new_company_description = data.get("company_description")

        if new_company_description is not None:
            company.company_description = new_company_description
            company.save()
            return JsonResponse({"message": "About Us updated successfully", "company_description": company.company_description})
        
        return JsonResponse({"error": "Invalid data"}, status=400)
    
    return JsonResponse({"error": "Invalid request method"}, status=405)

################################################################### update company name
@csrf_exempt
def update_company_name(request, company_id):
    if request.method == "POST":
        company = get_object_or_404(CompanyRegistration, id=company_id)
        data = json.loads(request.body)
        new_name = data.get("username")

        if new_name:
            if CompanyRegistration.objects.filter(username=new_name).exists():
                return JsonResponse({"error": "Company name already exists"}, status=400)

            company.username = new_name
            company.save()
            return JsonResponse({"message": "Company name updated successfully"})
        
        return JsonResponse({"error": "Invalid data"}, status=400)
    
    return JsonResponse({"error": "Invalid request method"}, status=405)
########################################################ajouter photos pour l'utilisateur
# views.py



from django.shortcuts import render, get_object_or_404
from django.http import JsonResponse
from .models import UserRegistration
from django.core.exceptions import ValidationError
@csrf_exempt
def update_profile_picture(request, user_id):
    if request.method == 'POST' and request.FILES.get('profile_picture'):
        user = get_object_or_404(UserRegistration, id=user_id)
        
        # Check if user already has a profile picture
        if user.profile_picture:
            # If profile picture exists, update it
            user.profile_picture = request.FILES['profile_picture']
            user.save()
            return JsonResponse({"message": "Profile picture updated successfully."}, status=200)
        
        # If no profile picture exists, add the new one
        user.profile_picture = request.FILES['profile_picture']
        user.save()
        return JsonResponse({"message": "Profile picture uploaded successfully."}, status=200)
    
    return JsonResponse({"error": "No profile picture provided."}, status=400)


######################################################### update user name

@csrf_exempt
def update_user_name(request, user_id):
    if request.method == "POST":
        user = get_object_or_404(UserRegistration, id=user_id)
        data = json.loads(request.body)
        new_name = data.get("username")

        if new_name:
            if UserRegistration.objects.filter(username=new_name).exists():
                return JsonResponse({"error": "Username already exists"}, status=400)

            user.username = new_name
            user.save()
            return JsonResponse({"message": "Username updated successfully"})
        
        return JsonResponse({"error": "Invalid data"}, status=400)
    
    return JsonResponse({"error": "Invalid request method"}, status=405)

###################################################### update the skills
@csrf_exempt
def update_user_skills(request, user_id):
    if request.method == "PUT":
        try:
            user = get_object_or_404(UserRegistration, id=user_id)
            data = json.loads(request.body)
            new_skills = data.get("skills")

            if not new_skills:
                return JsonResponse({"error": "Skills field is required"}, status=400)

            user.skills = new_skills
            user.save()
            return JsonResponse({"message": "Skills updated successfully", "skills": user.skills})

        except json.JSONDecodeError:
            return JsonResponse({"error": "Invalid JSON format"}, status=400)

    return JsonResponse({"error": "Invalid request method"}, status=405)

#################################################################### update the workplace company photos

