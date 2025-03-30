from django.test import TestCase
from jobs.models import JobInteraction, Job, CompanyRegistration, UserRegistration

class InteractionModelTests(TestCase):
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

    def test_create_interaction(self):
        # Create a VIEW interaction
        interaction = JobInteraction.objects.create(
            job=self.job,
            user=self.user,
            interaction_type='VIEW'
        )

        # Check if interaction is created correctly
        self.assertEqual(interaction.job, self.job)
        self.assertEqual(interaction.user, self.user)
        self.assertEqual(interaction.interaction_type, 'VIEW')