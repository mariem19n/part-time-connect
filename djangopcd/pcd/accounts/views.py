from django.shortcuts import render, redirect
from django.contrib.auth import authenticate , login, logout
from django.contrib.auth.decorators import login_required
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
import json
from django.contrib.auth.models import User
from rest_framework.response import Response
from rest_framework import status
from rest_framework.parsers import MultiPartParser, FormParser
from .models import Company, User
import json
from django.contrib.auth.hashers import make_password
from .models import UserRegistration
from django.contrib.auth.forms import PasswordChangeForm
from django.contrib.auth import update_session_auth_hash
from rest_framework.decorators import api_view
from .models import Company, JobType, WorkplaceImage
#################################################ok

@api_view(["POST"])
def registerPage(request):
    if request.method == 'POST':
        try:
            # Get form data from request
            username = request.POST.get('username')
            email = request.POST.get('email')
            password = request.POST.get('password')
            skills = request.POST.get("skills", "").split(",")  # Convert to list

            # Handle file upload
            resume = request.FILES.get('resume')  # PDF file uploaded by the user

            # Validate required fields
            if not username or not email or not password or not skills or not resume:
                return JsonResponse({'status': 'error', 'message': 'All fields are required'}, status=400)

            # Create and save the User object (assuming 'User' is a Django model)
            hashed_password = make_password(password)
            user = User.objects.create(username=username, email=email, password=hashed_password)

            # Create and save the UserRegistration object
            user_registration = UserRegistration(
                username=username,
                email=email,
                password=hashed_password,
                resume=resume,
                skills=skills
            )
            user_registration.save()

            return JsonResponse({'status': 'success', 'message': 'User registered successfully!'}, status=201)

        except Exception as e:
            return JsonResponse({'status': 'error', 'message': str(e)}, status=500)

    return JsonResponse({'status': 'error', 'message': 'Invalid request method'}, status=405)


###################################################ok


@api_view(['POST'])
def loginPage(request):
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

###################################################

login_required(login_url='login')
def logoutUser(request) :
    logout(request)
    return redirect('login')


##############################################

login_required(login_url='login')
def updateProfile(request):
    if request.method == 'POST':
        updated = False  # To track if any field was updated
        
        # Handle username update
        new_username = request.POST.get('username')
        if new_username and new_username != request.user.username:
            request.user.username = new_username
            request.user.save()
            updated = True

        # Handle password update
        form = PasswordChangeForm(request.user, request.POST)
        if form.is_valid():
            user = form.save()
            update_session_auth_hash(request, user)  # Keep the user logged in
            updated = True

        # Redirect or show success message
        if updated:
            return redirect('success_page')  # Replace 'success_page' with the name of your success URL
        else:
            # If no updates were made, add an error message
            form.add_error(None, "No changes were made.")
    else:
        form = PasswordChangeForm(request.user)

    return render(request, 'accounts/update_profile.html', {
        'form': form,
        'user': request.user,
    })


###################################################
@api_view(["POST"])
def register_company(request):
    if request.method == "POST":
        try:
            # Get form data from request
            company_name = request.data.get('company_name')
            email = request.data.get('email')
            password = request.data.get('password')
            jobTypes = request.data.get('jobTypes')
            workplace_images = request.FILES.getlist('workplace_images')

            # Validate required fields
            if not company_name or not email or not password or not jobTypes or not workplace_images:
                return JsonResponse({'status': 'error', 'message': 'All fields are required'}, status=400)

            # Hash the password (you may want to use Django's make_password function)
            hashed_password = make_password(password)

            # Create and save the Company object
            company = Company.objects.create(
                company_name=company_name,
                email=email,
                password=hashed_password,  # Ensure password is hashed before saving
                #jobTypes=jobTypes,
            )

            jobTypes_list = jobTypes.split(',')  # Si c'est une chaîne, on la convertit en liste
            company.jobTypes.set(jobTypes_list)  

            # Ajouter les images de l'entreprise
            company.add_images(workplace_images)

            # Récupérer les `jobTypes` et `workplace_images` après avoir associé
            company_job_types = company.jobTypes.all()  # Récupère tous les types de job associés
            company_workplace_images = company.workplace_images.all()  # Récupère toutes les images associées


            return JsonResponse({'status': 'success', 'message': 'Company registered successfully!'}, status=201)

        except Exception as e:
            return JsonResponse({'status': 'error', 'message': str(e)}, status=500)

    return JsonResponse({'status': 'error', 'message': 'Invalid request method'}, status=405)


###################################################
@csrf_exempt
@login_required
def updateProfile(request):
    if request.method == 'PUT':
        try:
            data = json.loads(request.body)
            user = request.user  # Get the authenticated user

            # Update fields if provided
            username = data.get('username', user.username)
            email = data.get('email', user.email)
            skills = data.get('skills', user.userregistration.skills)
            resume = request.FILES.get('resume', user.userregistration.resume)

            user.username = username
            user.email = email
            user.save()

            user_registration = UserRegistration.objects.get(username=user.username)
            user_registration.skills = skills
            if resume:
                user_registration.resume = resume  # Update resume if provided
            user_registration.save()

            return JsonResponse({'status': 'success', 'message': 'Profile updated successfully!'}, status=200)

        except UserRegistration.DoesNotExist:
            return JsonResponse({'status': 'error', 'message': 'User profile not found'}, status=404)
        except Exception as e:
            return JsonResponse({'status': 'error', 'message': str(e)}, status=500)

    return JsonResponse({'status': 'error', 'message': 'Invalid request method'}, status=405)
