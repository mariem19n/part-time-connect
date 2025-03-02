from django.test import TestCase
from jobs.models import Job
from accounts.models import UserRegistration, CompanyRegistration
from django.utils import timezone
from datetime import timedelta
from feedback.models import Feedback

class FeedbackCalculationTests(TestCase):
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

    def test_calculate_feedback_score(self):
        # Add feedback with different ratings and recency
        Feedback.objects.create(job=self.job, user=self.user, rating=5, created_at=timezone.now() - timedelta(days=10))
        Feedback.objects.create(job=self.job, user=self.user, rating=4, created_at=timezone.now() - timedelta(days=40))
        Feedback.objects.create(job=self.job, user=self.user, rating=1, is_fake=True)

        # Calculate feedback score
        feedback_score = self.job.calculate_feedback_score()

        # Check if feedback score is calculated correctly
        self.assertAlmostEqual(feedback_score, 1.703, delta=0.1)