from django.test import TestCase
from jobs.models import Job,JobInteraction
from feedback.models import Feedback
from accounts.models import UserRegistration, CompanyRegistration
from django.utils import timezone
from datetime import timedelta

class PopularityCalculationTests(TestCase):
    def setUp(self):
        # Create a test company and user
        self.company = CompanyRegistration.objects.create(username="Test Company")
        self.user = UserRegistration.objects.create(username="testuser")

        # Create a test job
        self.job = Job.objects.create(
            company=self.company,
            title="Software Engineer",
            description="Develop awesome software.",
            location="Remote",
            duration=12,
            requirements=["Python", "Django"],
        )

    def test_update_popularity_score(self):
        # Create interactions and feedback for the job
        JobInteraction.objects.create(job=self.job, user=self.user, interaction_type='VIEW')
        JobInteraction.objects.create(job=self.job, user=self.user, interaction_type='SAVE')
        JobInteraction.objects.create(job=self.job, user=self.user, interaction_type='APPLY')

        # Add feedback
        Feedback.objects.create(job=self.job, user=self.user, rating=5, created_at=timezone.now() - timedelta(days=10))
        Feedback.objects.create(job=self.job, user=self.user, rating=4, created_at=timezone.now() - timedelta(days=40))
        Feedback.objects.create(job=self.job, user=self.user, rating=1, is_fake=True)

        # Update popularity score
        self.job.update_popularity_score()

        # Check if popularity score is calculated correctly
        self.assertAlmostEqual(self.job.popularity_score, 1.1406, delta=0.1)