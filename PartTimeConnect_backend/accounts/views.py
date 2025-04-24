import random
import json
import os
from rest_framework.decorators import api_view ,authentication_classes, permission_classes
from rest_framework.response import Response
from rest_framework.authtoken.models import Token
from rest_framework.permissions import AllowAny, IsAuthenticated
from .models import PasswordResetCode, UserRegistration, CompanyRegistration, UserProfile
from django.core.mail import send_mail
from django.contrib.auth.decorators import login_required
from django.contrib.auth import authenticate , login, logout
from django.contrib.auth.hashers import make_password, check_password
from django.contrib.auth.models import User
from django.shortcuts import render, redirect
from django.conf import settings
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_protect, ensure_csrf_cookie, csrf_exempt
from django.views.decorators.http import require_http_methods
from django.core.files.storage import default_storage,FileSystemStorage
import traceback
from rest_framework.permissions import IsAuthenticated
from rest_framework.authentication import TokenAuthentication
from django.db.models import Q
from django.core.paginator import Paginator, EmptyPage


# accounts/views.py
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_POST
import json
from jobs.models import RecruiterView, Shortlist, RecruiterContact  # Add this import

# accounts/views.py
@csrf_exempt
@require_POST
def record_recruiter_view(request):
    try:
        data = json.loads(request.body)
        recruiter_id = data.get('recruiter_id')
        candidate_user_id = data.get('candidate_id')
        
        if not recruiter_id or not candidate_user_id:
            return JsonResponse({'status': 'error', 'message': 'Missing required fields'}, status=400)
            
        recruiter = CompanyRegistration.objects.get(id=recruiter_id)
        candidate_user = UserRegistration.objects.get(id=candidate_user_id)
        
        # Get or create the candidate profile
        candidate_profile, created = UserProfile.objects.get_or_create(
            user=candidate_user,
            defaults={
                'full_name': candidate_user.username,
                'skills': []
            }
        )
        
        # Create the view record
        RecruiterView.objects.create(
            recruiter=recruiter,
            candidate=candidate_profile
        )
        
        # Update candidate's profile views count
        candidate_profile.profile_views += 1
        candidate_profile.save()
        
        return JsonResponse({'status': 'success'})
    except CompanyRegistration.DoesNotExist:
        return JsonResponse({'status': 'error', 'message': 'Recruiter not found'}, status=404)
    except UserRegistration.DoesNotExist:
        return JsonResponse({'status': 'error', 'message': 'Candidate not found'}, status=404)
    except Exception as e:
        return JsonResponse({'status': 'error', 'message': str(e)}, status=400)

@csrf_exempt
@require_POST
def record_shortlist(request):
    try:
        data = json.loads(request.body)
        recruiter_id = data.get('recruiter_id')
        candidate_user_id = data.get('candidate_id')  # This should be UserRegistration ID
        
        from accounts.models import CompanyRegistration, UserProfile, UserRegistration
        from jobs.models import Shortlist
        
        recruiter = CompanyRegistration.objects.get(id=recruiter_id)
        candidate_user = UserRegistration.objects.get(id=candidate_user_id)
        candidate_profile = candidate_user.profile
        
        Shortlist.objects.create(
            recruiter=recruiter,
            candidate=candidate_profile
        )
        
        return JsonResponse({'status': 'success'})
    except Exception as e:
        return JsonResponse({'status': 'error', 'message': str(e)}, status=400)

@csrf_exempt
@require_POST
def record_recruiter_contact(request):
    try:
        data = json.loads(request.body)
        recruiter_id = data.get('recruiter_id')
        candidate_user_id = data.get('candidate_id')  # This should be UserRegistration ID
        message = data.get('message', '')
        
        from accounts.models import CompanyRegistration, UserProfile, UserRegistration
        from jobs.models import RecruiterContact
        
        recruiter = CompanyRegistration.objects.get(id=recruiter_id)
        candidate_user = UserRegistration.objects.get(id=candidate_user_id)
        candidate_profile = candidate_user.profile
        
        RecruiterContact.objects.create(
            recruiter=recruiter,
            candidate=candidate_profile,
            message=message
        )
        
        return JsonResponse({'status': 'success'})
    except Exception as e:
        return JsonResponse({'status': 'error', 'message': str(e)}, status=400)

######################################################################################################## Profile Page
@csrf_exempt
@api_view(['GET'])
def get_profile(request, user_id):
    if request.method != "GET":
        return JsonResponse({"error": "Invalid request method"}, status=405)

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

########################################################################################################## Get candidat Home Page Job Provider >>>Done
@api_view(['GET'])
def get_candidates(request):
    search_query = request.GET.get('search', '')
    skills_filter = request.GET.get('skills', '').split(',') if request.GET.get('skills') else []
    
    # Get candidates with profiles only
    candidates = UserRegistration.objects.filter(
        user_type='JobSeeker',
        profile__isnull=False  # Only include users with profiles
    ).select_related('profile')
    
    # Apply search filter if provided
    if search_query:
        candidates = candidates.filter(
            Q(username__icontains=search_query) |
            Q(profile__full_name__icontains=search_query)
        )
    
    # Apply skills filter if provided
    if skills_filter:
        candidates = candidates.filter(profile__skills__overlap=skills_filter)
    
    # Pagination
    page = request.GET.get('page', 1)
    paginator = Paginator(candidates, 10)
    
    try:
        candidates_page = paginator.page(page)
    except EmptyPage:
        return JsonResponse({"error": "Page not found"}, status=404)
    
    candidate_list = []
    for candidate in candidates_page:
        try:
            profile = candidate.profile
            candidate_list.append({
                "id": candidate.id,
                "username": candidate.username,
                "full_name": profile.full_name if profile.full_name else candidate.username,
                "about_me": profile.about_me if profile.about_me else "No description available",
                "skills": profile.skills if hasattr(profile, 'skills') else [],
                "profile_picture": None,  # Add if you have profile pictures
            })
        except UserProfile.DoesNotExist:
            # Skip candidates without profiles
            continue
    
    return JsonResponse({
        "count": paginator.count,
        "results": candidate_list,
    }, safe=False)
########################################################################################################## Update Location >>>Done
@csrf_exempt
@api_view(['POST'])
@authentication_classes([TokenAuthentication])
@permission_classes([IsAuthenticated])
def update_user_location(request):
    try:
        # Get the token user
        token_user = request.user
        
        # Find the corresponding UserRegistration
        try:
            user_registration = UserRegistration.objects.get(username=token_user.username)
        except UserRegistration.DoesNotExist:
            return Response({
                'status': 'error',
                'message': 'User registration not found'
            }, status=404)
        
        # Get or create user profile
        profile, created = UserProfile.objects.get_or_create(user=user_registration)
        
        # Parse JSON data from request body
        data = json.loads(request.body)
        locations = data.get('locations', [])
        
        # Validate locations
        if not locations:
            return Response({
                'status': 'error',
                'message': 'At least one location is required'
            }, status=400)
        
        # Convert single location to list if needed
        if not isinstance(locations, list):
            locations = [locations]
        
        # Update preferred locations
        profile.preferred_locations = locations
        profile.save()
        
        return Response({
            'status': 'success',
            'message': 'Locations updated successfully',
            'locations': profile.preferred_locations
        })
        
    except json.JSONDecodeError:
        return Response({
            'status': 'error',
            'message': 'Invalid JSON data'
        }, status=400)
    except Exception as e:
        return Response({
            'status': 'error',
            'message': str(e)
        }, status=500)
#############################################################################Messagerie search box >>>Done
def search_users(request):
    query = request.GET.get('q', '')
    
    # Search both UserRegistration and CompanyRegistration
    users = UserRegistration.objects.filter(
        Q(username__icontains=query) |
        Q(email__icontains=query)
    ).values('id', 'username', 'email', 'user_type')[:10]  # Parenthèse fermante ajoutée ici
    
    companies = CompanyRegistration.objects.filter(
        Q(username__icontains=query) |
        Q(email__icontains=query)
    ).values('id', 'username', 'email', 'user_type')[:10]  # Parenthèse fermante ajoutée ici
    
    results = list(users) + list(companies)
    return JsonResponse(results, safe=False)
########################################################################################################### Registration_Company Backend + Token >>> Done
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
            user_type = request.POST.get('user_type')

            # Validate required fields
            required_fields = ['username', 'email', 'password', 'jobtype', 'company_description']
            missing_fields = [field for field in required_fields if not request.POST.get(field)]
            if missing_fields or not photos:
                return JsonResponse({
                    'status': 'error',
                    'message': f'Missing required fields: {", ".join(missing_fields)}'
                }, status=400)
            # Check for existing company
            if CompanyRegistration.objects.filter(username=username).exists():
                return JsonResponse({
                    'status': 'error',
                    'message': 'Company with this username already exists'
                }, status=400)

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

            # Store photo paths
            if hasattr(company_registration, 'set_photos'):
                company_registration.set_photos(saved_files)
            else:
                company_registration.photos = json.dumps(saved_files)

            company_registration.save()


            # Create corresponding Django User and token (same as login approach)
            user = User.objects.create_user(
                username=username,
                email=email,
                password=password
            )
            token, created = Token.objects.get_or_create(user=user)

            return JsonResponse({
                'status': 'success',
                'message': 'Company registered successfully!',
                'id': company_registration.id,
                #'files': saved_files,
                'user_type': user_type,
                'username': username,
                'email': email,
                'jobtype': jobtype,
                'company_description': company_description,
                'photos': saved_files,
                'token': token.key
            }, status=201)

        except Exception as e:
            return JsonResponse({'status': 'error', 'message': str(e)}, status=500)

    return JsonResponse({'status': 'error', 'message': 'Invalid request method'}, status=405)
########################################################################################################### Registration_User Backend + Token >>> Done
@csrf_exempt
@require_http_methods(["POST"])
def registerPage(request):
    if request.method == 'POST':
        try:
            print("Received POST request for registration.")
            # Get form data from request
            data = request.POST
            username = data.get('username')
            # Check for existing user before creating
            if UserRegistration.objects.filter(username=username).exists():
                return JsonResponse({
                    'status': 'error',
                    'message': 'Username already exists'
                }, status=400)
            email = data.get('email')
            password = data.get('password')
            skills = data.get("skills", "")
            resumes = request.FILES.getlist('resume')
            user_type = data.get('user_type')

            print(f"Username: {username}, Email: {email}, Skills: {skills}")
            print(f"Number of resumes uploaded: {len(resumes)}")

            # Validate required fields
            required_fields = ['username', 'email', 'password', 'skills']
            missing_fields = [field for field in required_fields if not data.get(field)]
            if missing_fields or not resumes:
                print(f"Validation failed: Missing fields: {missing_fields}")
                return JsonResponse({
                    'status': 'error',
                    'message': f'Missing required fields: {", ".join(missing_fields)}'
                }, status=400)
            # Hash the password
            hashed_password = make_password(password)
            print("Password hashed successfully.")

            # Save resumes to the media directory and store their paths
            saved_files = []
            fs = FileSystemStorage()
            for resume in resumes:
                print(f"Processing resume: {resume.name}")
                filename = fs.save(f"resumes/{resume.name}", resume)
                saved_files.append(filename)
                print(f"Resume saved at: {filename}")

            # Create and save the UserRegistration object
            user_registration = UserRegistration(
                username=username,
                email=email,
                password=hashed_password,
                skills=skills,
                user_type='JobSeeker'
            )
            print("UserRegistration object created.")
            # Store resume paths
            if hasattr(user_registration, 'set_resumes'):
                user_registration.set_resumes(saved_files)
            else:
                user_registration.resumes = json.dumps(saved_files)
            print("Resume paths stored in UserRegistration object.")
            user_registration.save()
            print("UserRegistration object saved to the database.")
            # Create corresponding Django User and token (same as login approach)
            user = User.objects.create_user(
                username=username,
                email=email,
                password=password
            )
            token, created = Token.objects.get_or_create(user=user)
            return JsonResponse({
                'status': 'success',
                'message': 'User registered successfully!',
                'id': user_registration.id,
                'files': saved_files,
                'user_type': user_type,
                'username': username,
                'email': email,
                'skills': skills,
                'resumes': saved_files,
                'token': token.key
            }, status=201)


        except Exception as e:
            # Proper error logging
            print(f"Exception occurred: {str(e)}")
            traceback.print_exc()  # This will print the full traceback
            return JsonResponse({
                'status': 'error',
                'message': str(e)
            }, status=500)
    
    return JsonResponse({
        'status': 'error',
        'message': 'Invalid request method'
    }, status=405)
########################################################################################################### Log_Out Backend >>> Done
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
    print("Login attempt received")  # Log de début
    if request.method == 'GET':
        return JsonResponse({'detail': 'CSRF cookie set'})
    if request.method == 'POST':
        try:
            print("Parsing request body...")
            data = json.loads(request.body)
            username = data.get('username')
            password = data.get('password')
            print(f"Received username: {username}, password: {'***' if password else 'None'}")
        except json.JSONDecodeError:
            print("Error: Invalid JSON payload")
            return JsonResponse({'error': 'Invalid JSON payload'}, status=400)

        if not username or not password:
            print("Error: Missing username or password")
            return JsonResponse({'error': 'Username and password are required.'}, status=400)
        try:
            print(f"Checking company login for {username}...")
            company = CompanyRegistration.objects.get(username=username)
            print("Company found, verifying password...")
            if check_password(password, company.password):
                print("Company login successful!")
                # You might need to create or associate a User model for token generation.
                user = User.objects.get_or_create(username=company.username)[0]  # Create a User if not found
                token, created = Token.objects.get_or_create(user=user)
                print(f"Generated token: {token.key}")  # Debug line in Django
                return JsonResponse({
                    'message': 'Company login successful',
                    'id': company.id,  # ✅ Added ID field
                    'username': company.username,
                    'user_type': 'JobProvider',
                    'email': company.email,
                    'jobtype': company.jobtype,
                    'company_description': company.company_description,
                    'photos': company.get_photos(),
                    #'photos': []  # Instead of company.get_photos()
                    'token': token.key
                }, status=200)
        except CompanyRegistration.DoesNotExist:
            pass
        try:
            print(f"Checking job seeker login for {username}...")
            job_seeker = UserRegistration.objects.get(username=username)
            print("Job seeker found, verifying password...")
            if check_password(password, job_seeker.password):
                print("Job seeker login successful!")
                # Generate token
                user = User.objects.get_or_create(username=job_seeker.username)[0]
                token, created = Token.objects.get_or_create(user=user)
                print(f"Generated token: {token.key}")  # Debug line in Django
                return JsonResponse({
                    'message': 'Job seeker login successful',
                    'id': job_seeker.id,  # ✅ Added ID field
                    'username': job_seeker.username,
                    'user_type': 'JobSeeker',
                    'email': job_seeker.email,
                    'skills': job_seeker.skills,
                    'resumes': job_seeker.get_resumes(),
                    'token': token.key
                }, status=200)
        except UserRegistration.DoesNotExist:
            print(f"No job seeker found with username: {username}")
            pass
        print("Error: Invalid username or password")
        return JsonResponse({'error': 'Invalid username or password'}, status=401)
    print("Error: Invalid request method")
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
