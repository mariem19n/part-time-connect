from django.test import TestCase
from django.utils.timezone import now, timedelta
from accounts.models import UserRegistration, UserProfile, CompanyRegistration
from jobs.models import Job
from feedback.models import Feedback

class FeedbackScoreTests(TestCase):
    def setUp(self):
        # Create a company and job
        self.company = CompanyRegistration.objects.create(
            username="Test Company",
            email="test@company.com",
            password="password",
            jobtype="Software Engineer",
            company_description="A test company.",
        )
        self.job = Job.objects.create(
            company=self.company,
            title="Software Engineer",
            description="A test job.",
            location="Remote",
            salary=5000.0,
            is_salary_negotiable=True,
            working_hours="Flexible",
            duration=6,
            contract_type="Full-Time",
            requirements=["Python", "Django"],
            benefits=["Health insurance", "Remote work"],
            responsibilities=["Develop web applications", "Write clean code"],
        )

        # Create a user
        self.user = UserRegistration.objects.create(
            username="testuser",
            email="test@user.com",
            password="password",
        )

        # Use get_or_create to avoid creating duplicate UserProfile
        self.user_profile, created = UserProfile.objects.get_or_create(user=self.user)

    def test_feedback_score_with_no_feedback(self):
        """
        Test feedback score when there is no feedback.
        """
        # Calculate feedback score
        self.user_profile.calculate_feedback_score()

        # Check if the feedback score is 0
        self.assertEqual(self.user_profile.feedback_score, 0)

    def test_feedback_score_with_recent_feedback(self):
        """
        Test feedback score with recent feedback.
        """
        # Add recent feedback
        Feedback.objects.create(
            job=self.job,
            user=self.user,
            rating=5,
            review="Excellent work!",
            is_fake=False,
            created_at=now() - timedelta(days=10),  # Recent feedback
        )

        # Calculate feedback score
        self.user_profile.calculate_feedback_score()

        # Check if the feedback score is updated
        self.assertGreater(self.user_profile.feedback_score, 0)

    def test_feedback_score_with_old_feedback(self):
        """
        Test feedback score with old feedback.
        """
        # Add old feedback
        Feedback.objects.create(
            job=self.job,
            user=self.user,
            rating=5,
            review="Excellent work!",
            is_fake=False,
            created_at=now() - timedelta(days=100),  # Old feedback
        )

        # Calculate feedback score
        self.user_profile.calculate_feedback_score()

        # Check if the feedback score is updated
        self.assertGreater(self.user_profile.feedback_score, 0)

    def test_feedback_score_with_fake_feedback(self):
        """
        Test feedback score with fake feedback.
        """
        # Add fake feedback
        Feedback.objects.create(
            job=self.job,
            user=self.user,
            rating=1,
            review="Poor work!",
            is_fake=True,  # Fake feedback
        )

        # Calculate feedback score
        self.user_profile.calculate_feedback_score()

        # Check if the feedback score is not affected by fake feedback
        self.assertEqual(self.user_profile.feedback_score, 0)

    def test_feedback_score_with_multiple_feedbacks(self):
        """
        Test feedback score with multiple feedbacks.
        """
        # Add multiple feedbacks
        Feedback.objects.create(
            job=self.job,
            user=self.user,
            rating=5,
            review="Excellent work!",
            is_fake=False,
            created_at=now() - timedelta(days=10),  # Recent feedback
        )
        Feedback.objects.create(
            job=self.job,
            user=self.user,
            rating=4,
            review="Good work!",
            is_fake=False,
            created_at=now() - timedelta(days=50),  # Older feedback
        )

        # Calculate feedback score
        self.user_profile.calculate_feedback_score()

        # Check if the feedback score is updated
        self.assertGreater(self.user_profile.feedback_score, 0)

    def test_feedback_score_updated_on_save(self):
        """
        Test feedback score is updated when a Feedback instance is saved.
        """
        # Add feedback
        feedback = Feedback.objects.create(
            job=self.job,
            user=self.user,
            rating=5,
            review="Excellent work!",
            is_fake=False,
            created_at=now() - timedelta(days=10),  # Recent feedback
        )

        # Check if the feedback score is updated
        self.user_profile.refresh_from_db()
        self.assertGreater(self.user_profile.feedback_score, 0)

    def test_feedback_score_updated_on_delete(self):
        """
        Test feedback score is updated when a Feedback instance is deleted.
        """
        # Add feedback
        feedback = Feedback.objects.create(
            job=self.job,
            user=self.user,
            rating=5,
            review="Excellent work!",
            is_fake=False,
            created_at=now() - timedelta(days=10),  # Recent feedback
        )

        # Delete feedback
        feedback.delete()

        # Check if the feedback score is updated
        self.user_profile.refresh_from_db()
        self.assertEqual(self.user_profile.feedback_score, 0)