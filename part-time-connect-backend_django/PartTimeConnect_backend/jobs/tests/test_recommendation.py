from django.test import TestCase
from accounts.models import UserRegistration, UserProfile, CompanyRegistration
from jobs.models import Job, JobApplication
from feedback.models import Feedback

class RecommendationScoreTests(TestCase):
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

    def test_recommendation_score_with_no_data(self):
        """
        Test recommendation score when there is no data.
        """
        # Calculate recommendation score
        self.user_profile.calculate_recommendation_score(self.job)

        # Check if the recommendation score is 0
        self.assertEqual(self.user_profile.recommendation_score, 0)

    def test_recommendation_score_with_full_data(self):
        """
        Test recommendation score with all components.
        """
        # Simulate popularity, engagement, feedback, and profile match
        self.user_profile.popularity_score = 0.8
        self.user_profile.engagement_score = 0.7
        self.user_profile.feedback_score = 0.9
        self.user_profile.save()

        # Mock profile match score
        self.user_profile.profile_match_score = lambda job: 0.85

        # Calculate recommendation score
        self.user_profile.calculate_recommendation_score(self.job)

        # Check if the recommendation score is updated
        self.assertGreater(self.user_profile.recommendation_score, 0)
        self.assertLessEqual(self.user_profile.recommendation_score, 1)

    def test_recommendation_score_updated_on_feedback_save(self):
        """
        Test recommendation score is updated when feedback is saved.
        """
        # Add feedback
        feedback = Feedback.objects.create(
            job=self.job,
            user=self.user,
            rating=5,
            review="Excellent work!",
            is_fake=False,
        )

        # Check if the recommendation score is updated
        self.user_profile.refresh_from_db()
        self.assertGreater(self.user_profile.recommendation_score, 0)

    def test_recommendation_score_updated_on_job_application_save(self):
        """
        Test recommendation score is updated when a job application is saved.
        """
        # Create a job application with a duration value
        job_application = JobApplication.objects.create(
            user=self.user_profile,
            job=self.job,
            status="Applied",
            duration=6,  # Provide a value for the duration field
        )

        # Check if the recommendation score is updated
        self.user_profile.refresh_from_db()
        self.assertGreater(self.user_profile.recommendation_score, 0)
