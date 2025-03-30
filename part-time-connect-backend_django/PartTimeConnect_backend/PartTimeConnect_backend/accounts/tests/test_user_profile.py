from django.test import TestCase
from accounts.models import UserRegistration, UserProfile

class UserProfileModelTest(TestCase):
    @classmethod
    def setUpTestData(cls):
        """Set up test data for all test methods."""
        # Create a user
        cls.user = UserRegistration.objects.create(
            username="testuser",
            email="testuser@example.com",
            password="testpass123"
        )

        # Create or update a user profile
        cls.profile, created = UserProfile.objects.update_or_create(
            user=cls.user,
            defaults={
                "full_name": "Test User",
                "skills": ["Python", "Django"],
                "education_certifications": ["Bachelor's in CS"],
                "languages_spoken": ["English"]
            }
        )

        # Debug: Print whether the profile was created or updated
        if created:
            print("UserProfile was created.")
        else:
            print("UserProfile was updated.")

        # Debug: Print the created profile details
        print(f"Profile Details: {cls.profile.__dict__}")

    def test_user_profile_creation(self):
        """Test that the UserProfile is created correctly."""
        profile = UserProfile.objects.get(user=self.user)
        print(f"Test 1 - Profile Full Name: {profile.full_name}")
        self.assertEqual(profile.full_name, "Test User")
        self.assertEqual(profile.skills, ["Python", "Django"])
        self.assertEqual(profile.education_certifications, ["Bachelor's in CS"])
        self.assertEqual(profile.languages_spoken, ["English"])

    def test_full_name_field(self):
        """Test that the full_name field is saved correctly."""
        profile = UserProfile.objects.get(user=self.user)
        print(f"Test 2 - Profile Full Name: {profile.full_name}")
        self.assertEqual(profile.full_name, "Test User")

    def test_str_representation(self):
        """Test the __str__ method of the UserProfile model."""
        profile = UserProfile.objects.get(user=self.user)
        print(f"Test 3 - Profile __str__: {str(profile)}")
        self.assertEqual(str(profile), self.user.username)