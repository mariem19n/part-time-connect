from django.test import TestCase
from accounts.models import UserRegistration, CompanyRegistration
from jobs.models import Job
from feedback.models import Feedback

class FakeFeedbackDetectionTests(TestCase):
    def setUp(self):
        # Create a company
        self.company = CompanyRegistration.objects.create(
            username="Test Company",
            email="test@company.com",
            password="password",
            jobtype="Software Engineer",
            company_description="A test company.",
        )

        # Create a user with profile information
        self.user = UserRegistration.objects.create(
            username="testuser",
            email="test@user.com",
            password="password",
            skills="Python, Django",  # Add skills
            resumes='["resume1.pdf", "resume2.pdf"]',  # Add resumes
        )

        # Create a job with the required duration field
        self.job = Job.objects.create(
            company=self.company,
            title="Software Engineer",
            description="Develop awesome software.",
            location="Remote",
            duration=12,  # Add the required duration field
        )

    def test_repetitive_content(self):
        feedback1 = Feedback.objects.create(job=self.job, user=self.user, rating=5, review="Great job!")
        feedback2 = Feedback.objects.create(job=self.job, user=self.user, rating=5, review="Great job!")
        Feedback.detect_fake_feedback(feedback2)
        self.assertTrue(feedback2.is_fake)

    def test_suspicious_timing(self):
        for _ in range(6):
            Feedback.objects.create(job=self.job, user=self.user, rating=5, review="Great job!")
        feedback = Feedback.objects.create(job=self.job, user=self.user, rating=5, review="Great job!")
        Feedback.detect_fake_feedback(feedback)
        self.assertTrue(feedback.is_fake)

    def test_spam_keywords(self):
        feedback = Feedback.objects.create(job=self.job, user=self.user, rating=1, review="This is a scam!")
        Feedback.detect_fake_feedback(feedback)
        self.assertTrue(feedback.is_fake)