from django.core.management.base import BaseCommand
from django.contrib.auth.models import User
from collab.models import Job, JobInteraction
import random

class Command(BaseCommand):
    help = 'Génère des données ciblées pour tester le modèle de recommandation'

    def handle(self, *args, **kwargs):
        # Nettoyer les anciennes données
        JobInteraction.objects.all().delete()
        Job.objects.all().delete()
        User.objects.exclude(is_superuser=True).delete()

        # Créer 5 utilisateurs
        users = []
        for i in range(5):
            user = User.objects.create_user(username=f"user{i+1}", password="test123")
            users.append(user)

        # Créer 5 offres d'emploi
        jobs = []
        for i in range(5):
            job = Job.objects.create(
                title=f"Job {i+1}",
                description="Description test",
                location="Tunis",
                salary=random.uniform(15, 50)
            )
            jobs.append(job)

        # Ajouter des interactions similaires
        for user in users:
            for job in jobs:
                rating = random.randint(3, 5) if user.username != "user5" else random.randint(1, 2)
                JobInteraction.objects.create(user=user, job=job, rating=rating)

        self.stdout.write(self.style.SUCCESS("✅ Données ciblées générées avec succès !"))
