from django.test import TestCase
from faker import Faker
from accounts.models import UserRegistration, UserProfile, CompanyRegistration
from jobs.models import Job,RecruiterView, Shortlist, RecruiterContact

class PopularityScoreTests(TestCase):
    def setUp(self):
        self.fake = Faker()

        # Create a company
        self.company = CompanyRegistration.objects.create(
            username="Test Company",
            email="test@company.com",
            password="password",
            jobtype="Software Engineer",
            company_description="A test company.",
        )

    def test_popularity_score_with_profile_views(self):
        # Create a user
        user = UserRegistration.objects.create(
            username="testuser",
            email="test@user.com",
            password="password",
        )
        user_profile, _ = UserProfile.objects.get_or_create(user=user)  # Use get_or_create

        # Simulate profile views
        RecruiterView.objects.create(recruiter=self.company, candidate=user_profile)
        RecruiterView.objects.create(recruiter=self.company, candidate=user_profile)

        # Calculate popularity score
        user_profile.calculate_popularity_score()

        # Check if the popularity score is updated
        user_profile.refresh_from_db()
        self.assertGreater(user_profile.popularity_score, 0)

    def test_popularity_score_with_shortlists(self):
        # Create a user
        user = UserRegistration.objects.create(
            username="testuser",
            email="test@user.com",
            password="password",
        )
        user_profile, _ = UserProfile.objects.get_or_create(user=user)  # Use get_or_create

        # Simulate shortlists
        Shortlist.objects.create(recruiter=self.company, candidate=user_profile)
        Shortlist.objects.create(recruiter=self.company, candidate=user_profile)

        # Calculate popularity score
        user_profile.calculate_popularity_score()

        # Check if the popularity score is updated
        user_profile.refresh_from_db()
        self.assertGreater(user_profile.popularity_score, 0)

    def test_popularity_score_with_contacts(self):
        # Create a user
        user = UserRegistration.objects.create(
            username="testuser",
            email="test@user.com",
            password="password",
        )
        user_profile, _ = UserProfile.objects.get_or_create(user=user)  # Use get_or_create

        # Simulate contacts
        RecruiterContact.objects.create(recruiter=self.company, candidate=user_profile)
        RecruiterContact.objects.create(recruiter=self.company, candidate=user_profile)

        # Calculate popularity score
        user_profile.calculate_popularity_score()

        # Check if the popularity score is updated
        user_profile.refresh_from_db()
        self.assertGreater(user_profile.popularity_score, 0)

    def test_popularity_score_with_all_metrics(self):
        # Create a user
        user = UserRegistration.objects.create(
            username="testuser",
            email="test@user.com",
            password="password",
        )
        user_profile, _ = UserProfile.objects.get_or_create(user=user)  # Use get_or_create

        # Simulate profile views, shortlists, and contacts
        RecruiterView.objects.create(recruiter=self.company, candidate=user_profile)
        Shortlist.objects.create(recruiter=self.company, candidate=user_profile)
        RecruiterContact.objects.create(recruiter=self.company, candidate=user_profile)

        # Calculate popularity score
        user_profile.calculate_popularity_score()

        # Check if the popularity score is updated
        user_profile.refresh_from_db()
        self.assertGreater(user_profile.popularity_score, 0)