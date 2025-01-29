from django.db import models

# Create your models here.
# accounts/models.py
from django.db import models
from django.contrib.auth.models import User

# class Order(models.Model):
#     # Define fields for the Order model
#     product_name = models.CharField(max_length=100)
#     quantity = models.IntegerField()
#     # Add other fields as needed

from django.db import models
from django.contrib.auth.models import User

# class UserProfile(models.Model):
#     user = models.OneToOneField(User, on_delete=models.CASCADE)
#     full_name = models.CharField(max_length=200, blank=True, null=True)
#     resume = models.FileField(upload_to='resumes/', blank=True, null=True)
#     skills = models.CharField(max_length=200, blank=True, null=True)

#     def __str__(self):
#         return self.user.username
    
from django.db import models

class UserRegistration(models.Model):
    username = models.CharField(max_length=100)
    email = models.EmailField(unique=True)
    password = models.CharField(max_length=128)  # Note: In production, you should hash passwords
    resume = models.FileField(upload_to='resumes/')
    skills = models.CharField(max_length=200)  # You might want to use ManyToManyField for better scalability

    def __str__(self):
        return self.username


from django.db import models

class Company(models.Model):
    
    company_name = models.CharField(max_length=255, unique=True)
    email = models.EmailField(unique=True)
    password = models.CharField(max_length=128)  # Hashed password
    workplace_images = models.ManyToManyField('WorkplaceImage', blank=True)


    def __str__(self):
        return self.company_name

class WorkplaceImage(models.Model):
    image = models.ImageField(upload_to='workplace_images/')
    uploaded_at = models.DateTimeField(auto_now_add=True)
