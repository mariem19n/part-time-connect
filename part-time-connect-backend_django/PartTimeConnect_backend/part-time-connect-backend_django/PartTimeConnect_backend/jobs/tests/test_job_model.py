from django.test import TestCase
from jobs.models import Job, CompanyRegistration, JobInteraction, UserRegistration
from accounts.models import UserRegistration, CompanyRegistration , UserProfile
from django.utils import timezone
from feedback.models import Feedback

class JobModelTests(TestCase):
    def setUp(self):
        # Create a test company and user
        self.company = CompanyRegistration.objects.create(username="Test Company")
        self.user = UserRegistration.objects.create(username="testuser")

        # Create or get the user profile
        self.user_profile, created = UserProfile.objects.get_or_create(
        user=self.user,
        defaults={
            "full_name": "Test User",
            "skills": ["Python", "Django"],
            "education_certifications": ["Bachelor's in Computer Science"],
            "languages_spoken": ["English", "French"],
        }
    )
        # Create a test job
        self.job = Job.objects.create(
            company=self.company,
            title="Software Engineer",
            description="Develop awesome software.",
            location="Remote",
            duration=12,
            requirements=["Python", "Django"],
        )

    def test_update_counts(self):
        # Create interactions for the job
        JobInteraction.objects.create(job=self.job, user=self.user, interaction_type='VIEW')
        JobInteraction.objects.create(job=self.job, user=self.user, interaction_type='SAVE')
        JobInteraction.objects.create(job=self.job, user=self.user, interaction_type='APPLY')

        # Update counts
        self.job.update_counts()

        # Check if counts are updated correctly
        self.assertEqual(self.job.views_count, 1)
        self.assertEqual(self.job.saves_count, 1)
        self.assertEqual(self.job.applications_count, 1)

    def test_update_popularity_score(self):
        # Create interactions and feedback for the job
        JobInteraction.objects.create(job=self.job, user=self.user, interaction_type='VIEW')
        JobInteraction.objects.create(job=self.job, user=self.user, interaction_type='SAVE')
        JobInteraction.objects.create(job=self.job, user=self.user, interaction_type='APPLY')

        # Add feedback
        Feedback.objects.create(job=self.job, user=self.user, rating=5)

        # Update popularity score
        self.job.update_popularity_score()

        # Check if popularity score is calculated correctly
        self.assertGreater(self.job.popularity_score, 0)