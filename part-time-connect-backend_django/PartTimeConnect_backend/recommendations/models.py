from django.db import models
from jobs.models import Job
# from accounts.models import UserProfile
from accounts.models import UserRegistration

class JobEmbedding(models.Model):
    job = models.OneToOneField(Job, on_delete=models.CASCADE)
    embedding = models.BinaryField()  # Stores FAISS-compatible embeddings
    updated_at = models.DateTimeField(auto_now=True)

class UserJobMatch(models.Model):
    user = models.ForeignKey(UserRegistration, on_delete=models.CASCADE)
    job = models.ForeignKey(Job, on_delete=models.CASCADE)
    score = models.FloatField()
    explanation = models.JSONField()
    last_updated = models.DateTimeField(auto_now=True)

    class Meta:
        unique_together = ('user', 'job')