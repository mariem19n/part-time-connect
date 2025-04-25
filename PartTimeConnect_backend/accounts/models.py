from datetime import timedelta
from django.utils.timezone import now
from django.contrib.auth.hashers import make_password
from django.db import models
from django.contrib.auth.models import User
import json
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity
from datetime import datetime, timedelta
########################################################################################################### Registration_Company Backend Model >>> Done
class CompanyRegistration(models.Model):
    username = models.CharField(max_length=100)
    email = models.EmailField(unique=True)
    password = models.CharField(max_length=128)
    jobtype = models.CharField(max_length=200)
    company_description = models.TextField(null=True, blank=True)
    photos = models.TextField(null=True, blank=True)  # Store photo paths as a JSON string
    user_type = models.CharField(max_length=20, default='JobProvider')  # Always 'JobProvider'

    def __str__(self):
        return self.username

    def set_photos(self, photo_paths):
        """Store photo paths as a JSON string."""
        self.photos = json.dumps(photo_paths)

    def get_photos(self):
        """Retrieve photo paths as a list."""
        return json.loads(self.photos) if self.photos else []
########################################################################################################### Registration_User Backend Model >>> Done
class UserRegistration(models.Model):
    username = models.CharField(max_length=100)
    email = models.EmailField(unique=True)
    password = models.CharField(max_length=128)
    skills = models.CharField(max_length=200)
    resumes = models.TextField(null=True, blank=True)  # Store resume paths as a JSON string
    user_type = models.CharField(max_length=20, default='JobSeeker')  # Default to 'JobSeeker'

    def __str__(self):
        return self.username

    def set_resumes(self, resume_paths):
        """Store resume paths as a JSON string."""
        self.resumes = json.dumps(resume_paths)

    #@property
    def get_resumes(self):
        """Retrieve resume paths as a list."""
        return json.loads(self.resumes) if self.resumes else []
###############################
class UserProfile(models.Model):  # Stores additional user details
    user = models.OneToOneField(UserRegistration, on_delete=models.CASCADE, related_name="profile")
    full_name = models.CharField(max_length=255, blank=True, default="Unknown")
    phone = models.CharField(max_length=20, null=True, blank=True)
    #location = models.CharField(max_length=255, null=True, blank=True)
    preferred_locations = models.JSONField(default=list)
    
    def add_preferred_location(self, location):
        if location not in self.preferred_locations:
            self.preferred_locations.append(location)
            self.save()
    
    def remove_preferred_location(self, location):
        if location in self.preferred_locations:
            self.preferred_locations.remove(location)
            self.save()
            
    about_me = models.TextField(null=True, blank=True)
    skills = models.JSONField(default=list)
    education_certifications = models.JSONField(default=list)
    languages_spoken = models.JSONField(default=list)
    experience = models.ManyToManyField('jobs.JobApplication', related_name="user_experience") # store job applications
    portfolio = models.JSONField(default=list)  # List of projects

    engagement_score = models.FloatField(default=0)  # Indique l'intérêt du candidat (ex : nombre de candidatures envoyées à des postes similaires).
    popularity_score = models.FloatField(default=0)  # Mesure l'intérêt des recruteurs (ex : nombre de vues, de sélections, de contacts reçus).
    feedback_score = models.FloatField(default=0)  # Note donnée par d'anciens employeurs (ex : avis, évaluations de performances).
    recommendation_score = models.FloatField(default=0)  # Score global calculé pour recommander un candidat aux recruteurs --> calculate_recommendation_score()
    previous_recommendation_score = models.FloatField(default=0)  # Track previous value
    # Fields to track popularity metrics
    profile_views = models.PositiveIntegerField(default=0)  # Number of profile views
    shortlists = models.PositiveIntegerField(default=0)     # Number of times shortlisted
    contacts = models.PositiveIntegerField(default=0)       # Number of times contacted


    def __str__(self):
        return self.user.username

    def calculate_engagement_score(self, recruiter_job, similarity_threshold=0.7):
        """
        Calculate the engagement score for the user based on their job applications.
        :param recruiter_job: The job being offered by the recruiter (Job instance).
        """
        applications = self.applications.all()
        total_applications = applications.count()

        # Calculate the time period for application frequency
        if total_applications > 0:
            first_application_date = applications.earliest('application_date').application_date
            time_period = (datetime.now().date() - first_application_date).days / 30  # Convert days to months
        else:
            time_period = 1  # Default to 1 month if no applications exist

        # Avoid division by zero or negative time periods
        if time_period < 1:
            time_period = 1

        application_frequency = total_applications / time_period  # Applications per month

        # Rest of the engagement score calculation...
        similar_role_applications = 0

        # Prepare text data for similarity comparison
        recruiter_job_text = f"{recruiter_job.title} {' '.join(recruiter_job.requirements)}"
        applied_jobs_text = [f"{app.job.title} {' '.join(app.job.requirements)}" for app in applications]

        # Handle the case where there are no applied jobs
        if not applied_jobs_text:
            engagement_score = 0  # No applied jobs means no engagement
        else:
            # Convert text data into TF-IDF vectors
            vectorizer = TfidfVectorizer()
            tfidf_matrix = vectorizer.fit_transform([recruiter_job_text] + applied_jobs_text)

            # Compute cosine similarity between the recruiter's job and each applied job
            recruiter_vector = tfidf_matrix[0:1]  # First vector is the recruiter's job
            applied_vectors = tfidf_matrix[1:]  # Remaining vectors are the applied jobs

            similarities = cosine_similarity(recruiter_vector, applied_vectors)

            # Count how many applied jobs are similar to the recruiter's job
            for similarity in similarities[0]:
                if similarity > similarity_threshold:  # Use the provided threshold
                    similar_role_applications += 1

            # Calculate engagement score
            engagement_score = (
                (similar_role_applications / total_applications if total_applications > 0 else 0) * 0.6 +
                (application_frequency / 5) * 0.4  # Assuming max frequency is 5
            )

        # Update the engagement score
        self.engagement_score = engagement_score
        self.save()

    def profile_match_score(self, job):
        """
        Calculate a score based on how well the user's profile matches job requirements.
        :param job: The job being offered by the recruiter (Job instance).
        :return: A score between 0 and 1 indicating the relevance of the candidate to the job.
        """
        # Helper function to safely join items that might be strings or dicts
        def safe_join(items):
            if not items:  # Handle empty lists
                return ""
            return ' '.join(
                item if isinstance(item, str) else item.get('name', '')
                for item in items
            )

        # Prepare text data for similarity comparison
        candidate_profile_text = " ".join([
            safe_join(self.skills),
            safe_join(self.education_certifications),
            safe_join(self.languages_spoken)
        ])
        job_requirements_text = safe_join(job.requirements) if hasattr(job, 'requirements') else ""

        # Handle empty text
        if not candidate_profile_text.strip():
            candidate_profile_text = "No information provided"
        if not job_requirements_text.strip():
            job_requirements_text = "No information provided"

        # Debug: Print the input text
        print(f"Candidate Profile Text: {candidate_profile_text}")
        print(f"Job Requirements Text: {job_requirements_text}")
        
        # Convert text data into TF-IDF vectors
        vectorizer = TfidfVectorizer()
        tfidf_matrix = vectorizer.fit_transform([candidate_profile_text, job_requirements_text])

        # Compute cosine similarity between the candidate's profile and the job requirements
        similarity = cosine_similarity(tfidf_matrix[0:1], tfidf_matrix[1:2])[0][0]
        return similarity

    def calculate_popularity_score(self):
        """
        Calculate the Candidate Popularity Score based on profile views, shortlists, and contacts.
        """
        # Define weights for each metric
        VIEW_WEIGHT = 0.4  # 40% weight for profile views
        SHORTLIST_WEIGHT = 0.4  # 40% weight for shortlists
        CONTACT_WEIGHT = 0.2  # 20% weight for contacts
        # Normalize the metrics (optional, to ensure they are on the same scale)
        max_views = UserProfile.objects.aggregate(max_views=models.Max('profile_views'))['max_views'] or 1
        max_shortlists = UserProfile.objects.aggregate(max_shortlists=models.Max('shortlists'))['max_shortlists'] or 1
        max_contacts = UserProfile.objects.aggregate(max_contacts=models.Max('contacts'))['max_contacts'] or 1

        normalized_views = self.profile_views / max_views
        normalized_shortlists = self.shortlists / max_shortlists
        normalized_contacts = self.contacts / max_contacts

        # Calculate the popularity score
        popularity_score = (
            (normalized_views * VIEW_WEIGHT) +
            (normalized_shortlists * SHORTLIST_WEIGHT) +
            (normalized_contacts * CONTACT_WEIGHT)
        )
        # Update the popularity_score field
        self.popularity_score = popularity_score
        self.save(update_fields=['popularity_score'])

    def calculate_feedback_score(self):
        """
        Calculate the feedback score based on ratings and recency of feedback.
        """
        from feedback.models import Feedback
        # Get all feedback for the user
        feedbacks = Feedback.objects.filter(user=self.user)

        if not feedbacks.exists():
            self.feedback_score = 0
            self.save(update_fields=['feedback_score'])
            return

        # Calculate the weighted average rating
        total_weighted_rating = 0
        total_weight = 0

        for feedback in feedbacks:
            # Skip fake feedback
            if feedback.is_fake:
                continue

            # Get the recency weight
            recency_weight = feedback.get_recency_weight()

            # Add to the total weighted rating
            total_weighted_rating += feedback.rating * recency_weight
            total_weight += recency_weight

        # Calculate the feedback score
        if total_weight > 0:
            feedback_score = (total_weighted_rating / total_weight) / 5  # Normalize to 0-1
        else:
            feedback_score = 0

        # Update the feedback_score field
        self.feedback_score = feedback_score
        self.save(update_fields=['feedback_score'])

    def calculate_recommendation_score(self, job):
        # Calculate individual scores
        self.calculate_popularity_score()  # Update popularity score
        self.calculate_engagement_score(job)  # Update engagement score
        self.calculate_feedback_score()  # Update feedback score
        profile_match_score = self.profile_match_score(job)  # Calculate profile match score

        # Calculate the new recommendation score
        new_recommendation_score = (
            (self.popularity_score * 0.2) +
            (self.engagement_score * 0.3) +
            (self.feedback_score * 0.1) +
            (profile_match_score * 0.4)  #  Use the calculated profile_match_score
        )

        # Debug: Print the new recommendation score
        print(f"New Recommendation Score for {self.user.username}: {new_recommendation_score}")

        # Only update if the score has changed
        if self.recommendation_score != new_recommendation_score:
            self.recommendation_score = new_recommendation_score
            self.save(update_fields=['recommendation_score'])
            print(f"Saved Recommendation Score for {self.user.username}: {self.recommendation_score}")
########################################################################################################### Password Reset Backend Model>>> Done
class PasswordResetCode(models.Model):
    email = models.EmailField()
    code = models.CharField(max_length=6)
    created_at = models.DateTimeField(auto_now_add=True)

    def is_expired(self):
        # Define the expiration period (e.g., 10 minutes)
        expiration_time = self.created_at + timedelta(minutes=5)
        return now() > expiration_time
