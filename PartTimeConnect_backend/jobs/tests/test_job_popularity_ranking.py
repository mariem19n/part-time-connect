from django.test import TestCase
from faker import Faker
from accounts.models import UserRegistration, UserProfile, CompanyRegistration
from jobs.models import Job
from feedback.models import Feedback

class JobPopularityRankingTests(TestCase):
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

        # Create multiple jobs with varying engagement and feedback
        self.jobs = []
        for i in range(5):
            job = Job.objects.create(
                company=self.company,
                title=f"Job {i}",
                description=self.fake.paragraph(),
                location="Remote",
                salary=5000.0,
                is_salary_negotiable=True,
                working_hours="Flexible",
                duration=6,
                contract_type="Full-Time",
                requirements=["Python", "Django"],
                benefits=["Health insurance", "Remote work"],
                responsibilities=["Develop web applications", "Write clean code"],
                applications_count=i * 10,  # Vary applications
                views_count=i * 50,        # Vary views
                saves_count=i * 5,         # Vary saves
            )
            self.jobs.append(job)

        # Create a user with a profile
        self.user = UserRegistration.objects.create(
            username="testuser",
            email="test@user.com",
            password="password",
        )
        if not UserProfile.objects.filter(user=self.user).exists():
            UserProfile.objects.create(user=self.user, skills=[self.fake.job()])

        # Add feedback to each job
        for job in self.jobs:
            Feedback.objects.create(
                job=job,
                user=self.user,
                rating=5 - self.jobs.index(job),  # Vary ratings (5, 4, 3, 2, 1)
                review="Great job!",
                is_fake=False,
            )
            job.update_popularity_score()  # Update popularity score after feedback

    def test_job_popularity_ranking(self):
        # Fetch jobs ordered by popularity_score (descending)
        ranked_jobs = Job.objects.all().order_by("-popularity_score")

        # Print the ranking of jobs
        print("\nJob Rankings:")
        for i, job in enumerate(ranked_jobs, start=1):
            print(f"{i}. {job.title} (Popularity Score: {job.popularity_score:.2f})")

        # Verify that jobs are ranked correctly
        for i in range(len(ranked_jobs) - 1):
            self.assertGreaterEqual(
                ranked_jobs[i].popularity_score,
                ranked_jobs[i + 1].popularity_score,
                f"Job {ranked_jobs[i].title} should be ranked higher than Job {ranked_jobs[i + 1].title}",
            )