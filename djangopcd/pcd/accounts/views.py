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
        return JsonResponse({'detail': 'CSRF cookie set'})
    if request.method == 'POST':
        try:
            data = json.loads(request.body)
            username = data.get('username')
            password = data.get('password')

            user = authenticate(request, username=username, password=password)
            if user is not None:
                login(request, user)
                return JsonResponse({'message': 'Login successful', 'username': user.username}, status=200)
            else:
                return JsonResponse({'error': 'Invalid username or password'}, status=401)
        except json.JSONDecodeError:
            return JsonResponse({'error': 'Invalid JSON payload'}, status=400)
    return JsonResponse({'error': 'Invalid request method'}, status=405)
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

