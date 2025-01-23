from datetime import timedelta
from django.utils.timezone import now
from django.db import models

class PasswordResetCode(models.Model):
    email = models.EmailField()
    code = models.CharField(max_length=6)
    created_at = models.DateTimeField(auto_now_add=True)

    def is_expired(self):
        # Define the expiration period (e.g., 10 minutes)
        expiration_time = self.created_at + timedelta(minutes=5)
        return now() > expiration_time
