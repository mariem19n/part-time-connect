from django.shortcuts import render

# Create your views here.
import logging
import os  # Added to handle path joining
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from .services.recommender import RecommendationEngine
from .models import Job, UserRegistration
from PyPDF2 import PdfReader  # For extracting text from PDF

# Set up logging
logger = logging.getLogger(__name__)
logging.basicConfig(level=logging.INFO)

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_recommendations(request):
    logger.info("Request received to fetch recommendations.")
    
    try:
        # Fetch the UserRegistration based on the authenticated user's username
        try:
            user_profile = UserRegistration.objects.get(username=request.user.username)
            logger.info(f"User registration retrieved: {user_profile}")
            
            resumes = user_profile.get_resumes()
            logger.info(f"Resumes for {user_profile.username}: {resumes}")
            
            # Extract and log text from each resume
            for resume in resumes:
                try:
                    # Construct the correct file path using 'media/' if not already included
                    resume_path = os.path.join('media', resume) if not resume.startswith('media/') else resume
                    resume_text = extract_text_from_pdf(resume_path)
                    logger.info(f"Extracted text from {resume_path}: {resume_text[:300]}...")
                except Exception as e:
                    logger.error(f"Failed to extract text from {resume}: {str(e)}")
            
        except UserRegistration.DoesNotExist:
            logger.error("UserRegistration does not exist for this user.")
            return Response({"error": "User registration not found."}, status=400)
        
        all_jobs = Job.objects.all()
        logger.info(f"Retrieved {len(all_jobs)} jobs.")
        
        engine = RecommendationEngine()
        logger.info("Recommendation engine instantiated.")
        
        recommendations = engine.get_recommendations(user_profile, all_jobs)
        logger.info(f"Recommendations generated: {recommendations}")
        
        return Response(recommendations)
    
    except Exception as e:
        logger.error(f"Error occurred while processing recommendations: {str(e)}")
        return Response({'error': f"Error occurred: {str(e)}"}, status=500)

# Function to extract text from a PDF resume
def extract_text_from_pdf(pdf_path):
    try:
        with open(pdf_path, 'rb') as file:
            reader = PdfReader(file)
            text = ""
            for page in reader.pages:
                text += page.extract_text() or ""
            return text
    except Exception as e:
        raise Exception(f"Failed to extract text from PDF: {str(e)}")
