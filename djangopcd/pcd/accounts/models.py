from django.db import models
from django.contrib.auth.models import User

# class Order(models.Model):
#     # Define fields for the Order model
#     product_name = models.CharField(max_length=100)
#     quantity = models.IntegerField()
#     # Add other fields as needed


# class UserProfile(models.Model):
#     user = models.OneToOneField(User, on_delete=models.CASCADE)
#     full_name = models.CharField(max_length=200, blank=True, null=True)
#     resume = models.FileField(upload_to='resumes/', blank=True, null=True)
#     skills = models.CharField(max_length=200, blank=True, null=True)

#     def __str__(self):
#         return self.user.username
    
####################################################"ok"

class UserRegistration(models.Model):
    username = models.CharField(max_length=100)
    email = models.EmailField(unique=True)
    password = models.CharField(max_length=128)  # Note: In production, you should hash passwords
    resume = models.FileField(upload_to='resumes/')
    skills = models.CharField(max_length=200)  # You might want to use ManyToManyField for better scalability

    def __str__(self):
        return self.username
####################################################

class JobType(models.Model):
    name = models.CharField(max_length=100 , blank=True)

    def __str__(self):
        return self.name

class Company(models.Model):
    
    company_name = models.CharField(max_length=255, unique=True)
    email = models.EmailField(unique=True)
    password = models.CharField(max_length=128)  # Hashed password
    workplace_images = models.ManyToManyField('WorkplaceImage', blank=True)
    jobTypes = models.ManyToManyField(JobType)


    def __str__(self):
        return self.company_name
    
    def add_images(self, images):
        for image in images:
            workplace_image = WorkplaceImage.objects.create(image=image)
            self.workplace_images.add(workplace_image)

class WorkplaceImage(models.Model):
    image = models.ImageField(upload_to='workplace_images/')
    uploaded_at = models.DateTimeField(auto_now_add=True)
