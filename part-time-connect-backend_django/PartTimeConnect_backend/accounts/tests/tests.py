# Create your tests here.
from django.test import TestCase
from django.contrib.auth.models import User
from accounts.models import PasswordResetCode  # Update to match your app's structure

class PasswordResetTests(TestCase):

    def setUp(self):
        # Create a test user
        self.user = User.objects.create_user(
            username='testuser', email='test@example.com', password='testpassword123'
        )

    def test_request_password_reset(self):
        response = self.client.post('/api/request-password-reset/', {'email': 'test@example.com'})
        self.assertEqual(response.status_code, 200)
        self.assertIn('message', response.json())

    def test_verify_reset_code(self):
        # Generate reset code
        code = '123456'
        PasswordResetCode.objects.create(email=self.user.email, code=code)

        response = self.client.post('/api/verify-reset-code/', {'email': 'test@example.com', 'code': code})
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json()['message'], 'Code verified')

    def test_reset_password(self):
        # Generate reset code
        code = '123456'
        PasswordResetCode.objects.create(email=self.user.email, code=code)

        response = self.client.post('/api/reset-password/', {'email': 'test@example.com', 'code': code, 'new_password': 'newSecurePassword123'})
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json()['message'], 'Password reset successful')
