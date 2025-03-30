from django.test import TestCase
from faker import Faker
from accounts.models import UserRegistration, UserProfile, CompanyRegistration
from jobs.models import Job
from feedback.models import Feedback

class JobPopularityTests(TestCase):
    def setUp(self):
        self.fake = Faker()

        # Create a single company and job for unit tests
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
            applications_count=10,
            views_count=50,
            saves_count=5,
        )

    def test_popularity_score_with_single_company(self):
        # Create a user with a profile
        user = UserRegistration.objects.create(
            username="testuser",
            email="test@user.com",
            password="password",
        )
        if not UserProfile.objects.filter(user=user).exists():
            UserProfile.objects.create(user=user, skills=[self.fake.job()])

        # Add feedback
        feedback = Feedback.objects.create(
            job=self.job,
            user=user,
            rating=5,
            review="Great job!",
            is_fake=False,
        )

        # Check if the popularity score was updated
        self.job.refresh_from_db()
        self.assertNotEqual(self.job.popularity_score, 0)

    def test_popularity_score_with_multiple_companies(self):
        # Create multiple companies and jobs
        companies = [CompanyRegistration.objects.create(
            username=self.fake.company(),
            email=self.fake.email(),
            password=self.fake.password(),
            jobtype=self.fake.job(),
            company_description=self.fake.paragraph(),
        ) for _ in range(10)]

        jobs = [Job.objects.create(
            company=self.fake.random_element(companies),
            title=self.fake.job(),
            description=self.fake.paragraph(),
            location=self.fake.city(),
            salary=self.fake.random_int(min=2000, max=10000),
            is_salary_negotiable=self.fake.boolean(),
            working_hours="9 AM - 5 PM",
            duration=self.fake.random_int(min=1, max=12),
            contract_type=self.fake.random_element(["Full-Time", "Part-Time", "Freelance", "Internship"]),
            requirements=["Good communication", "Teamwork"],
            benefits=["Flexible hours", "Career growth"],
            responsibilities=["Project management", "Coding tasks"],
            applications_count=self.fake.random_int(min=0, max=200),
            views_count=self.fake.random_int(min=0, max=500),
            saves_count=self.fake.random_int(min=0, max=100),
        ) for _ in range(50)]

        # Create users with profiles
        users = [UserRegistration.objects.create(
            username=self.fake.user_name(),
            email=self.fake.email(),
            password=self.fake.password(),
        ) for _ in range(20)]

        for user in users:
            profile, created = UserProfile.objects.get_or_create(user=user)
            if created:
                profile.skills = [self.fake.job()]
                profile.save()

        # Add feedback for each job
        for job in jobs:
            for _ in range(self.fake.random_int(min=1, max=10)):
                Feedback.objects.create(
                    job=job,
                    user=self.fake.random_element(users),
                    rating=self.fake.random_int(min=1, max=5),
                    review=self.fake.text(),
                    is_fake=self.fake.boolean(),
                )

        # Check if popularity scores are updated
        for job in jobs:
            job.refresh_from_db()
            self.assertNotEqual(job.popularity_score, 0)