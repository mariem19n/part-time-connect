from django.test import TestCase
from faker import Faker
from accounts.models import UserRegistration, UserProfile, CompanyRegistration
from jobs.models import Job, JobApplication

class EngagementScoreTests(TestCase):
    def setUp(self):
        self.fake = Faker()

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

    def test_engagement_score_with_single_job_application(self):
        # Create a user
        user = UserRegistration.objects.create(
            username="testuser",
            email="test@user.com",
            password="password",
        )

        # Use get_or_create to avoid creating duplicate UserProfile
        user_profile, created = UserProfile.objects.get_or_create(user=user)
        if created:
            user_profile.skills = ["Python", "Django"]
            user_profile.save()

        # Create a job application
        JobApplication.objects.create(
            user=user_profile,
            job=self.job,
            duration=6,
            status="Applied",
        )

        # Check if the engagement score is updated
        user_profile.refresh_from_db()
        self.assertGreater(user_profile.engagement_score, 0)

    def test_engagement_score_with_multiple_job_applications(self):
        # Create a user
        user = UserRegistration.objects.create(
            username="testuser",
            email="test@user.com",
            password="password",
        )

        # Use get_or_create to avoid creating duplicate UserProfile
        user_profile, created = UserProfile.objects.get_or_create(user=user)
        if created:
            user_profile.skills = ["Python", "Django"]
            user_profile.save()

        # Create multiple jobs with similar requirements
        similar_jobs = [Job.objects.create(
            company=self.company,
            title=f"Software Engineer {i}",
            description=f"A test job {i}.",
            location="Remote",
            salary=5000.0,
            is_salary_negotiable=True,
            working_hours="Flexible",
            duration=6,
            contract_type="Full-Time",
            requirements=["Python", "Django"],
            benefits=["Health insurance", "Remote work"],
            responsibilities=["Develop web applications", "Write clean code"],
        ) for i in range(5)]

        # Create job applications for the user
        for job in similar_jobs:
            JobApplication.objects.create(
                user=user_profile,
                job=job,
                duration=6,
                status="Applied",
            )

        # Check if the engagement score is updated
        user_profile.refresh_from_db()
        self.assertGreater(user_profile.engagement_score, 0)
    def test_engagement_score_with_non_similar_job_applications(self):
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

        # Create a recruiter's job
        recruiter_job = Job.objects.create(
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

        # Create non-similar jobs
        non_similar_jobs = [Job.objects.create(
            company=self.company,
            title=f"Graphic Designer {i}",
            description=f"A graphic design role {i}.",
            location="Onsite",
            salary=4000.0,
            is_salary_negotiable=True,
            working_hours="Flexible",
            duration=6,
            contract_type="Part-Time",
            requirements=["Photoshop", "Illustrator", "UI/UX"],
            benefits=["Health insurance", "Flexible hours"],
            responsibilities=["Design graphics", "Create UI/UX designs"],
        ) for i in range(5)]

        # Create job applications for the user
        for job in non_similar_jobs:
            JobApplication.objects.create(
                user=user_profile,
                duration=6,
                job=job,
                status="Applied",
            )

        # Calculate engagement score
        user_profile.calculate_engagement_score(recruiter_job)

        # Check if the engagement score remains low
        user_profile.refresh_from_db()
        self.assertLess(user_profile.engagement_score, 0.5)
