from datetime import timedelta
from django.utils.timezone import now
from django.contrib.auth.hashers import make_password
from django.db import models
from django.contrib.auth.models import User
import json

########################################################################################################### Registration_Company Backend Model >>> Done
class CompanyRegistration(models.Model):
    username = models.CharField(max_length=100)
    email = models.EmailField(unique=True)
    password = models.CharField(max_length=128)
    jobtype = models.CharField(max_length=200)
    company_description = models.TextField(null=True, blank=True)
    photos = models.TextField(null=True, blank=True)  # Store photo paths as a JSON string

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
    profile_picture = models.ImageField(
        upload_to='profile_pictures/', 
        null=True, 
        blank=True
    )

    def __str__(self):
        return self.username

    def set_resumes(self, resume_paths):
        """Store resume paths as a JSON string."""
        self.resumes = json.dumps(resume_paths)

    def get_resumes(self):
        """Retrieve resume paths as a list."""
        return json.loads(self.resumes) if self.resumes else []

########################################################################################################### Password Reset Backend Model>>> Done
class PasswordResetCode(models.Model):
    email = models.EmailField()
    code = models.CharField(max_length=6)
    created_at = models.DateTimeField(auto_now_add=True)

    def is_expired(self):
        # Define the expiration period (e.g., 10 minutes)
        expiration_time = self.created_at + timedelta(minutes=5)
        return now() > expiration_time
    
############################################################################################################