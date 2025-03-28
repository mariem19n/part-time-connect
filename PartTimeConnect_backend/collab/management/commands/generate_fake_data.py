from django.core.management.base import BaseCommand
from faker import Faker
from django.contrib.auth.models import User
from collab.models import Job, JobInteraction
import random

class Command(BaseCommand):
    help = 'Generate fake users, jobs, and interactions'

    def handle(self, *args, **kwargs):
        fake = Faker()

        for _ in range(30):
            User.objects.create_user(
                username=fake.user_name(),
                email=fake.email(),
                password='password123'
            )

        for _ in range(20):
            Job.objects.create(
                title=fake.job(),
                description=fake.text(),
                location=fake.city(),
                salary=random.uniform(15, 50)
            )

        users = list(User.objects.all())
        jobs = list(Job.objects.all())

        for _ in range(300):
            JobInteraction.objects.create(
                user=random.choice(users),
                job=random.choice(jobs),
                rating=random.randint(1, 5)
            )

        self.stdout.write(self.style.SUCCESS('Fake data generated!'))
