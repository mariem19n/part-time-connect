from django.db import models

from django.contrib.auth.models import User

class JobOffer(models.Model):
    title = models.CharField(max_length=100)
    category = models.CharField(max_length=100)
    location = models.CharField(max_length=100)
    description = models.TextField()
    company = models.CharField(max_length=100)
    salary = models.FloatField(null=True, blank=True)
    job_type = models.CharField(max_length=50, choices=[('full-time', 'Full-Time'),
                                                        ('part-time', 'Part-Time'),
                                                        ('freelance', 'Freelance'),
                                                        ('remote', 'Remote')],
                                                        default='full-time')
    required_skills = models.JSONField(default=list)  # List of required skills for the job

    def __str__(self):
        return self.title

class UserProfile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    preferred_categories = models.JSONField(default=list)  # List of preferred job categories
    search_history = models.JSONField(default=list)  # List of job IDs or categories the user has searched for
    location = models.CharField(max_length=100, null=True, blank=True)  # User's location
    preferred_salary_range = models.JSONField(default=list)  # List of salary range preferences [min_salary, max_salary]
    preferred_job_types = models.JSONField(default=list)  # List of job types like full-time, part-time
    preferred_skills = models.JSONField(default=list)  # List of skills the user is interested in
    contract_type = models.CharField(max_length=50, choices=[('full-time', 'Full-Time'),
                                                            ('part-time', 'Part-Time'),
                                                            ('freelance', 'Freelance'),
                                                            ( 'internship', 'Internship')],
                                                            default='full-time')

    def __str__(self):
        return self.user.username
