
from django.shortcuts import render, redirect
# from django.contrib.auth.forms import UserCreationForm
from .forms import CreateUserForm
from django.contrib.auth import authenticate , login, logout
# from django.contrib import messages
from django.contrib.auth.decorators import login_required
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
import json
from rest_framework.decorators import api_view
from django.shortcuts import render, redirect
from django.contrib.auth.forms import UserCreationForm
from django.contrib.auth.models import User
from .forms import CreateUserForm  # Assuming you've created this custom form
from django.core.files.storage import FileSystemStorage

from rest_framework.response import Response
from rest_framework.decorators import api_view
from rest_framework import status
from .models import User

from django.core.files.storage import FileSystemStorage
from django.views.decorators.csrf import csrf_exempt
from rest_framework.decorators import api_view, permission_classes, parser_classes
from rest_framework.parsers import MultiPartParser, FormParser
from rest_framework.response import Response
from rest_framework.permissions import AllowAny
from rest_framework import status


from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_http_methods
from .models import UserRegistration
import json
from django.core.exceptions import ValidationError
from django.contrib.auth.hashers import make_password

@csrf_exempt
@require_http_methods(["POST"])

@csrf_exempt
def registerPage(request):
    if request.method == 'POST':
        try:
            # Parse JSON payload
            data = json.loads(request.body)
            username = data.get('username')
            email = data.get('email')
            password = data.get('password')
            skills = data.get('skills')
            resume = request.FILES.get('resume')  # Handle uploaded files (if applicable)

            # Validation for required fields
            if not username or not email or not password or not skills:
                return JsonResponse({'status': 'error', 'message': 'All fields are required'}, status=400)

            # Create and save the User object
            hashed_password = make_password(password)
            user = User.objects.create(username=username, email=email, password=hashed_password)

            # Create and save the UserRegistration object
            user_registration = UserRegistration(
                username=username,
                email=email,
                password=hashed_password,  # Store hashed password for consistency
                resume=resume,
                skills=skills
            )
            user_registration.save()

            return JsonResponse({'status': 'success', 'message': 'User registered successfully!'}, status=201)

        except Exception as e:
            return JsonResponse({'status': 'error', 'message': str(e)}, status=500)

    return JsonResponse({'status': 'error', 'message': 'Invalid request method'}, status=405)
# login_required(login_url='login')
# def registerPage(request):
#     form = CreateUserForm()
#     if request.method == 'POST':
#         form = CreateUserForm(request.POST)  # Corrected variable name
#         if form.is_valid():  # Proper indentation
#             form.save()  # Save the user data
#             return redirect('login')  # Redirect to the login page after successful registration
    
#     context = {'form': form}
#     return render(request, 'accounts/register.html', context)

login_required(login_url='login')
# def loginPage(request):
#     context = {}  
#     if request.method == 'POST':
#         username = request.POST.get('username')
#         password = request.POST.get('password')

#         user = authenticate(request, username=username, password=password)
#         if user is not None:
#             login(request, user)
#             return redirect('home')
#         else:
#             messages.info(request, 'Username OR password is incorrect')
#             return render(request, 'accounts/login.html', context)
#     return render(request, 'accounts/login.html', context)
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
import json
@api_view(['POST'])
# @csrf_exempt  # Disable CSRF for simplicity (secure this for production)
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

# from django.contrib.auth.models import User

# @csrf_exempt
# def loginPage(request):
#     if request.method == 'POST':
#         try:
#             # Parse JSON payload
#             data = json.loads(request.body)
#             email = data.get('email')
#             password = data.get('password')

#             # Validate email and password fields
#             if not email or not password:
#                 return JsonResponse({'error': 'Email and password are required'}, status=400)

#             # Fetch user by email
#             try:
#                 user = User.objects.get(email=email)
#             except User.DoesNotExist:
#                 return JsonResponse({'error': 'Invalid email or password'}, status=401)

#             # Authenticate user using username from the User object
#             user = authenticate(request, username=user.username, password=password)
#             if user is not None:
#                 login(request, user)
#                 return JsonResponse({'message': 'Login successful', 'email': user.email}, status=200)
#             else:
#                 return JsonResponse({'error': 'Invalid email or password'}, status=401)
#         except json.JSONDecodeError:
#             return JsonResponse({'error': 'Invalid JSON payload'}, status=400)
#         except Exception as e:
#             return JsonResponse({'error': f'An unexpected error occurred: {str(e)}'}, status=500)
#     else:
#         return JsonResponse({'error': 'Invalid request method'}, status=405)



login_required(login_url='login')
def logoutUser(request) :
    logout(request)
    return redirect('login')

from django.contrib.auth.forms import UserChangeForm, PasswordChangeForm
from django.contrib.auth import update_session_auth_hash

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


from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.contrib.auth.hashers import make_password
from .models import Company, WorkplaceImage
import json
# If you find this line in views.py or elsewhere, remove it or correct it:

from django.contrib.auth.models import User
from django.contrib.auth.hashers import make_password
from django.http import JsonResponse
from .models import Company, WorkplaceImage

@csrf_exempt
def register_company(request):
    if request.method == 'POST':
        try:
            data = request.POST  # Récupérer les données du formulaire
            company_name = data.get('company_name')
            email = data.get('email')
            password = data.get('password')

            if not company_name or not email or not password:
                return JsonResponse({'error': 'Tous les champs obligatoires doivent être remplis'}, status=400)

            # Vérifier si l'entreprise existe déjà
            if Company.objects.filter(email=email).exists():
                return JsonResponse({'error': 'Email déjà utilisé'}, status=400)

            # Hacher le mot de passe
            hashed_password = make_password(password)

            # Créer l'entreprise
            company = Company.objects.create(
                company_name=company_name,
                email=email,
                password=hashed_password,
            )

            # Créer un utilisateur pour l'entreprise
            user = User.objects.create_user(username=email, password=password)
            user.company = company
            user.save()

            # Sauvegarder les images
            images = request.FILES.getlist('workplace_images')
            for img in images:
                image_obj = WorkplaceImage.objects.create(image=img)
                company.workplace_images.add(image_obj)

            return JsonResponse({'message': 'Entreprise et utilisateur enregistrés avec succès'}, status=201)

        except Exception as e:
            return JsonResponse({'error': str(e)}, status=500)

    return JsonResponse({'error': 'Méthode non autorisée'}, status=405)


# from django.contrib.auth.models import User
# from django.contrib.auth.hashers import make_password
# from django.http import JsonResponse
# from .models import Company

# from django.contrib.auth.models import User
# from django.contrib.auth.hashers import make_password
# from django.http import JsonResponse
# from django.views.decorators.csrf import csrf_exempt
# from .models import Company
# import json
# login_required(login_url='login')
# @csrf_exempt
# def update_company(request):
#     if request.method == 'PUT':  # Only accept PUT request
#         try:
#             data = request.body.decode('utf-8')  # Parse the body as JSON data
#             data = json.loads(data)  # Convert to Python dict

#             # Extract data from the request
            
#             companyname = data.get('username')
#             email = data.get('email')
#             password = data.get('password')
#             company_name = data.get('company_name')

#             # Validate input
#             if not user_id or not email:
#                 return JsonResponse({'error': 'User ID and email are required'}, status=400)

#             # Fetch the user object by ID
#             try:
#                 user = User.objects.get(id=user_id)
#             except User.DoesNotExist:
#                 return JsonResponse({'error': 'User not found'}, status=404)

#             # Update user fields
#             if username:
#                 user.username = username
#             if email:
#                 user.email = email
#             if password:  # Hash password if provided
#                 user.password = make_password(password)

#             # Update the associated company information (if needed)
#             if company_name:
#                 # Get the company by email (same as user email)
#                 company = Company.objects.filter(email=user.email).first()
#                 if company:
#                     company.company_name = company_name
#                     company.save()

#             # Save the user data
#             user.save()

#             return JsonResponse({'message': 'User information updated successfully'}, status=200)

#         except Exception as e:
#             return JsonResponse({'error': str(e)}, status=500)

#     return JsonResponse({'error': 'Method not allowed'}, status=405)  # Only PUT method is allowed

import json
from django.http import JsonResponse
from django.contrib.auth.hashers import make_password
from django.contrib.auth.decorators import login_required
from django.views.decorators.csrf import csrf_exempt
from .models import UserRegistration

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
