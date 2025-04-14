import random
from django.core.management.base import BaseCommand
from faker import Faker
from django.contrib.auth import get_user_model

from jobs.models import Job
from accounts.models import CompanyRegistration
from collab.models import JobInteraction
from collab.recommender import get_recommendations_for_user

fake = Faker()
User = get_user_model()


class Command(BaseCommand):
    help = "Test complet du modèle de recommandation"

    def handle(self, *args, **kwargs):
        # Récupérer les utilisateurs existants
        users = User.objects.all()
        if not users.exists():
            print("Aucun utilisateur trouvé. Créez des users d'abord.")
            return

        print(f"{users.count()} users trouvés")

        # Créer des entreprises fictives
        companies = []
        for _ in range(5):
            company = CompanyRegistration.objects.create(
                username=fake.company(),
                email=fake.company_email(),
                password="hashedpassword123",
                jobtype=random.choice(['Tech', 'Design', 'Admin']),
                company_description=fake.text(),
            )
            companies.append(company)
        print(f"{len(companies)} companies créées")

        # Créer des jobs fictifs
        jobs = []
        for _ in range(20):
            job = Job.objects.create(
                title=fake.job(),
                description=fake.text(),
                location=fake.city(),
                salary=random.randint(200, 1000),
                working_hours=f"{random.randint(4, 8)}h/day",
                contract_type=random.choice(['Part-Time', 'Freelance', 'Internship']),
                duration=random.randint(1, 6),  
                company=random.choice(companies),
            )
            jobs.append(job)
        print(f"{len(jobs)} jobs créés")

        # Générer des interactions aléatoires
        for user in users:
            interacted_jobs = random.sample(jobs, k=random.randint(5, 15))
            for job in interacted_jobs:
                JobInteraction.objects.create(
                    user=user,
                    job=job,
                    nb_views=random.randint(1, 10),
                    time_spent=random.uniform(1, 120),
                    interaction_type=random.choice(['view', 'apply']),
                    rating=random.randint(1, 5) if random.random() < 0.7 else None,
                )
        print("Interactions générées")

        # Choisir un user aléatoire pour le test
        user_to_test = random.choice(users)
        print(f"Recommandations pour l'utilisateur : {user_to_test.email}")

        # Appeler le recommender
        recommended_jobs = get_recommendations_for_user(user_to_test.id, top_n=5)

        if not recommended_jobs:
            print("Aucune recommandation trouvée.")
        else:
            print("Jobs recommandés :")
            for job in recommended_jobs:
                print(f"- {job.title} | {job.location} | {job.salary} DT")
