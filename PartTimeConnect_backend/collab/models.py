from django.db import models
from django.contrib.auth.models import User
from jobs.models import Job


class JobInteraction(models.Model):
    INTERACTION_TYPE = [
        ('view', 'Consultation'),
        ('apply', 'Postulation'),
        ('feedback', 'Feedback'),
    ]

    user = models.ForeignKey(User, on_delete=models.CASCADE)
    job = models.ForeignKey(Job, on_delete=models.CASCADE, related_name='collab_interactions')
    interaction_type = models.CharField(max_length=10, choices=INTERACTION_TYPE)
    nb_views = models.IntegerField(default=0)  # Nombre de vues répétées
    time_spent = models.FloatField(default=0)  # Temps passé sur la fiche (en secondes)
    rating = models.FloatField(null=True, blank=True)  # Feedback éventuel
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.user.username} - {self.job.title} - {self.interaction_type}"
