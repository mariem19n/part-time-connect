from django.db import models
from django.utils import timezone
from datetime import timedelta
from django.utils.timezone import now
from jobs.models import Job
from accounts.models import UserRegistration

class Feedback(models.Model):
    job = models.ForeignKey(Job, on_delete=models.CASCADE)
    user = models.ForeignKey(UserRegistration, on_delete=models.CASCADE)
    rating = models.IntegerField(default=3)  # 1 to 5 stars
    review = models.TextField(blank=True)
    is_fake = models.BooleanField(default=False)  # True if reported as fake
    created_at = models.DateTimeField(auto_now_add=True)

    def get_recency_weight(self):
        """
        Calculate the recency weight of the feedback.
        """
        days_since = (now() - self.created_at).days
        return max(1.5 - (days_since // 30) * 0.1, 1)

    @classmethod
    def detect_fake_feedback(cls, feedback):
        """
        Detect if the feedback is fake based on rule-based checks.
        """
        # Check for repetitive content
        similar_reviews = cls.objects.filter(job=feedback.job, review=feedback.review).count()
        if similar_reviews > 1:
            feedback.is_fake = True
            return

        # Check user activity
        user_feedbacks = cls.objects.filter(user=feedback.user).count()
        if user_feedbacks == 1 and not (feedback.user.skills or feedback.user.resumes):
            feedback.is_fake = True
            return

        # Detect suspicious timing
        recent_feedbacks = cls.objects.filter(
            job=feedback.job,
            created_at__gte=timezone.now() - timedelta(minutes=10)
        )
        if recent_feedbacks.count() > 5:  # Too many reviews in a short time
            feedback.is_fake = True
            return

        # Keyword analysis
        spam_keywords = ["scam", "fake", "free money", "urgent"]
        if any(keyword in feedback.review.lower() for keyword in spam_keywords):
            feedback.is_fake = True
            return

        # If none of the checks fail, mark as not fake
        feedback.is_fake = False
