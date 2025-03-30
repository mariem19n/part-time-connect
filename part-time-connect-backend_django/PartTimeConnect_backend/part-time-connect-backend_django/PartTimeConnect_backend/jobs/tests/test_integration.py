from django.test import TestCase, Client
from django.urls import reverse
from jobs.models import Job,JobInteraction
from feedback.models import Feedback
from accounts.models import UserRegistration, CompanyRegistration

class IntegrationTests(TestCase):
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

        # Set up the client
        self.client = Client()

    def test_view_job(self):
        # Simulate viewing a job
        url = reverse("view_job", args=[self.job.id])
        response = self.client.get(url)

        # Check response and updated views_count
        self.assertEqual(response.status_code, 200)
        self.job.refresh_from_db()
        self.assertEqual(self.job.views_count, 1)

    def test_save_job(self):
        # Simulate saving a job
        url = reverse("save_job", args=[self.job.id])
        response = self.client.post(url)

        # Check response and updated saves_count
        self.assertEqual(response.status_code, 200)
        self.job.refresh_from_db()
        self.assertEqual(self.job.saves_count, 1)

    def test_apply_job(self):
        # Simulate applying to a job
        url = reverse("apply_job", args=[self.job.id])
        response = self.client.post(url)

        # Check response and updated applications_count
        self.assertEqual(response.status_code, 200)
        self.job.refresh_from_db()
        self.assertEqual(self.job.applications_count, 1)