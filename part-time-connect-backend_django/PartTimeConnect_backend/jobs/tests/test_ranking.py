from django.test import TestCase
from accounts.models import UserRegistration, UserProfile , CompanyRegistration
from jobs.models import Job, JobApplication, RecruiterView, Shortlist, RecruiterContact
from django.utils import timezone
from feedback.models import Feedback

class RankingTests(TestCase):
    @classmethod
    def setUpTestData(cls):
        """Set up test data for all test methods."""
        # Create a recruiter (company)
        cls.recruiter = CompanyRegistration.objects.create(
            username="recruiter1",
            email="recruiter1@example.com",
            password="testpass123",
            jobtype="IT",
            company_description="A leading tech company"
        )

        # Create candidates
        cls.candidate1 = UserRegistration.objects.create(
            username="candidate1",
            email="candidate1@example.com",
            password="testpass123",
            skills="Python, Django"
        )
        cls.candidate2 = UserRegistration.objects.create(
            username="candidate2",
            email="candidate2@example.com",
            password="testpass123",
            skills="JavaScript, React"
        )

        # Create user profiles for candidates
        cls.profile1, _ = UserProfile.objects.update_or_create(
            user=cls.candidate1,
            defaults={
                "full_name": "John Doe",
                "skills": ["Python", "Django"],
                "education_certifications": ["Bachelor's in CS"],
                "languages_spoken": ["English"]
            }
        )
        cls.profile2, _ = UserProfile.objects.update_or_create(
            user=cls.candidate2,
            defaults={
                "full_name": "Jane Smith",
                "skills": ["JavaScript", "React"],
                "education_certifications": ["Master's in CS"],
                "languages_spoken": ["English", "French"]
            }
        )

        # Create a job
        cls.job = Job.objects.create(
            company=cls.recruiter,
            title="Software Engineer",
            description="Looking for a skilled software engineer.",
            requirements=["Python", "Django", "JavaScript"],
            benefits=["Health insurance", "Flexible hours"],
            responsibilities=["Develop web applications", "Collaborate with teams"],
            duration=12  # Add the required duration field
        )

        # Create job applications
        JobApplication.objects.create(user=cls.profile1, job=cls.job, status="Applied", duration=12)
        JobApplication.objects.create(user=cls.profile2, job=cls.job, status="Applied", duration=6)

        # Create feedback for candidates
        Feedback.objects.create(job=cls.job, user=cls.candidate1, rating=5, review="Excellent candidate!")
        Feedback.objects.create(job=cls.job, user=cls.candidate2, rating=4, review="Very good candidate.")

        # Create recruiter interactions
        RecruiterView.objects.create(recruiter=cls.recruiter, candidate=cls.profile1)
        Shortlist.objects.create(recruiter=cls.recruiter, candidate=cls.profile1)
        RecruiterContact.objects.create(recruiter=cls.recruiter, candidate=cls.profile1, message="We'd like to interview you.")

    def test_ranking(self):
        """Test ranking candidates for a job."""
        # Calculate recommendation scores for each candidate
        self.profile1.calculate_engagement_score(self.job)
        self.profile1.calculate_popularity_score()
        self.profile1.calculate_feedback_score()
        self.profile1.calculate_recommendation_score(self.job)

        self.profile2.calculate_engagement_score(self.job)
        self.profile2.calculate_popularity_score()
        self.profile2.calculate_feedback_score()
        self.profile2.calculate_recommendation_score(self.job)

        # Debug: Print recommendation scores
        print(f"John Doe's Recommendation Score: {self.profile1.recommendation_score}")
        print(f"Jane Smith's Recommendation Score: {self.profile2.recommendation_score}")

        # Rank candidates by recommendation score
        ranked_candidates = UserProfile.objects.order_by('-recommendation_score')

        # Debug: Print ranked candidates
        for candidate in ranked_candidates:
            print(f"Candidate: {candidate.full_name}, Recommendation Score: {candidate.recommendation_score}")

        # Assert the ranking is correct
        self.assertEqual(ranked_candidates[0].full_name, "John Doe")
        self.assertEqual(ranked_candidates[1].full_name, "Jane Smith")
