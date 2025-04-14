from django.core.management.base import BaseCommand
from django.contrib.auth.models import User
from accounts.models import UserRegistration
from jobs.models import Job, JobInteraction, CompanyRegistration
from faker import Faker
import random


class Command(BaseCommand):
    help = 'Générer des users, jobs et interactions avancées pour test User-Based KNN'

    def handle(self, *args, **kwargs):
        fake = Faker()

        # Nettoyage
        User.objects.filter(username__startswith="test_user").delete()
        UserRegistration.objects.filter(username__startswith="test_user").delete()
        Job.objects.all().delete()
        JobInteraction.objects.all().delete()

        self.stdout.write("✅ Nettoyage terminé")

        # Créer une company
        company, created = CompanyRegistration.objects.get_or_create(
            username='company_test',
            defaults={'email': 'company@test.com', 'password': 'company1234'}
        )

        # Créer les Users
        users = []

        for i in range(1, 8):  # test_user1 → test_user7
            username = f"test_user{i}"
            email = fake.unique.email()

            user_django = User.objects.create_user(username=username, email=email, password="test1234")
            user_reg = UserRegistration.objects.create(username=username, email=email, password="test1234")

            users.append(user_reg)

        self.stdout.write("✅ Utilisateurs créés avec Faker")

        # Créer les Jobs
        jobs = [Job.objects.create(
            title=fake.job(),
            description=fake.text(),
            location=fake.city(),
            salary=random.uniform(20, 50),
            duration=random.randint(1, 12),
            company=company
        ) for _ in range(1, 20)]  # Job1 → Job19

        self.stdout.write("✅ Jobs créés avec Faker")

        # test_user1 : uniquement les 2 premiers jobs
        user_target = users[0]  # test_user1
        for job in jobs[:2]:
            JobInteraction.objects.create(user=user_target, job=job, interaction_type='VIEW')

        # Les autres users : 5 jobs random chacun
        for user in users[1:]:
            interacted_jobs = random.sample(jobs, 5)
            for job in interacted_jobs:
                JobInteraction.objects.create(user=user, job=job, interaction_type='VIEW')

        self.stdout.write(self.style.SUCCESS('✅ Données avancées générées avec succès et prêtes pour test User-Based'))
