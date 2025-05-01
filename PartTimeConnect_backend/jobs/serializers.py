from rest_framework import serializers
from .models import JobApplication

class JobApplicationSerializer(serializers.ModelSerializer):
    job_title = serializers.CharField(source='job.title')
    job_description = serializers.CharField(source='job.description')  # facultatif
    class Meta:
        model = JobApplication
        fields = ['id', 'job_title', 'job_description', 'status', 'application_date']
