from django.test import TestCase
from accounts.models import UserRegistration, UserProfile, CompanyRegistration
from jobs.models import Job

class ProfileMatchScoreTests(TestCase):
    def setUp(self):
        # Create a company
        self.company = CompanyRegistration.objects.create(
            username="Test Company",
            email="test@company.com",
            password="password",
            jobtype="Software Engineer",
            company_description="A test company.",
        )

    def test_profile_match_score_with_similar_job(self):
        # Create a user
        user = UserRegistration.objects.create(
            username="testuser",
            email="test@user.com",
            password="password",
        )

        # Use get_or_create to avoid creating duplicate UserProfile
        user_profile, created = UserProfile.objects.get_or_create(user=user)
        user_profile.skills = ["Python", "Django"]
        user_profile.save()

        # Create a job with similar requirements
        similar_job = Job.objects.create(
            company=self.company,
            title="Software Engineer",
            description="A software engineering role.",
            location="Remote",
            salary=5000.0,
            is_salary_negotiable=True,
            working_hours="Flexible",
            duration=6,
            contract_type="Full-Time",
            requirements=["Python", "Django", "REST API"],
            benefits=["Health insurance", "Remote work"],
            responsibilities=["Develop web applications", "Write clean code"],
        )

        # Calculate profile match score
        profile_match_score = user_profile.profile_match_score(similar_job)

        # Check if the profile match score is high
        self.assertGreater(profile_match_score, 0.7)

    def test_profile_match_score_with_non_similar_job(self):
        # Create a user
        user = UserRegistration.objects.create(
            username="testuser",
            email="test@user.com",
            password="password",
        )

        # Use get_or_create to avoid creating duplicate UserProfile
        user_profile, created = UserProfile.objects.get_or_create(user=user)
        user_profile.skills = ["Python", "Django"]
        user_profile.save()

        # Create a job with non-similar requirements
        non_similar_job = Job.objects.create(
            company=self.company,
            title="Graphic Designer",
            description="A graphic design role.",
            location="Onsite",
            salary=4000.0,
            is_salary_negotiable=True,
            working_hours="Flexible",
            duration=6,
            contract_type="Part-Time",
            requirements=["Photoshop", "Illustrator", "UI/UX"],
            benefits=["Health insurance", "Flexible hours"],
            responsibilities=["Design graphics", "Create UI/UX designs"],
        )

        # Calculate profile match score
        profile_match_score = user_profile.profile_match_score(non_similar_job)

        # Check if the profile match score is low
        self.assertLess(profile_match_score, 0.3)