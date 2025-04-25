from django.db import models
from accounts.models import UserRegistration, CompanyRegistration , UserProfile
from django.utils import timezone

class Job(models.Model):
    CONTRACT_TYPES = [
        ('Full-Time', 'Full-Time'),
        ('Part-Time', 'Part-Time'),
        ('Freelance', 'Freelance'),
        ('Internship', 'Internship'),
    ]

    company = models.ForeignKey(CompanyRegistration, on_delete=models.CASCADE)
    title = models.CharField(max_length=255)
    description = models.TextField()
    # New fields based on the prototype
    location = models.CharField(max_length=255, default='Remote')
    salary = models.FloatField(null=True, blank=True)  # Optional
    is_salary_negotiable = models.BooleanField(default=False)
    working_hours = models.CharField(max_length=100, default="Flexible")
    duration = models.IntegerField(help_text="Duration in months")
    contract_type = models.CharField(max_length=20, choices=CONTRACT_TYPES, default='Part-Time')

    # Additional fields for structured data
    requirements = models.JSONField(default=list)  # Store as list of strings
    benefits = models.JSONField(default=list)
    responsibilities = models.JSONField(default=list)

    contract_pdf = models.FileField(upload_to='contracts/', null=True, blank=True)

    # Tracking fields
    applications_count = models.IntegerField(default=0)
    views_count = models.IntegerField(default=0)
    saves_count = models.IntegerField(default=0)
    popularity_score = models.FloatField(default=0)

    def __str__(self):
        return f"{self.title} - {self.company.username}"

    def update_popularity_score(self):
        """
        Recalculate the popularity score based on interactions and feedback.
        """
        if hasattr(self, '_updating_popularity_score'):
            return
        self._updating_popularity_score = True

        # Calculate feedback score
        feedback_score = self.calculate_feedback_score()

        # Calculate popularity score
        self.popularity_score = (
            (self.applications_count * 0.5) +
            (self.saves_count * 0.2) +
            (self.views_count * 0.1) +
            (feedback_score * 0.2)
        )
        self.save(update_fields=['popularity_score'])
        del self._updating_popularity_score
        return self.popularity_score

    def calculate_feedback_score(self):
        feedbacks = self.feedback_set.all()
        if not feedbacks.exists():
            return 0  # No feedback means score is 0

        total_weighted_rating = sum(
            fb.rating * fb.get_recency_weight() for fb in feedbacks
        )
        total_weight = sum(fb.get_recency_weight() for fb in feedbacks)

        fake_reports = sum(fb.is_fake for fb in feedbacks)
        return (total_weighted_rating - (fake_reports * 2)) / max(total_weight + len(feedbacks), 1)

    def update_counts(self):
        """
        Update counts based on JobInteraction records.
        """
        self.applications_count = self.interactions.filter(interaction_type='APPLY').count()
        self.views_count = self.interactions.filter(interaction_type='VIEW').count()
        self.saves_count = self.interactions.filter(interaction_type='SAVE').count()
        self.save(update_fields=['applications_count', 'views_count', 'saves_count'])

##############################>>>Represents a user's application to a job.
class JobApplication(models.Model):
    APPLICATION_STATUS = [
        ('Saved', 'Saved'),  # Job offer saved by the user
        ('Applied', 'Applied'),  # User has applied for the job
        ('Interviewing', 'Interviewing'),  # User is in the interview process
        ('Completed', 'Completed'),  # Job has been completed
        ('Rejected', 'Rejected'),  # Application was rejected
        ('Offered', 'Offered'),  # Job offer received
    ]

    user = models.ForeignKey(UserProfile, on_delete=models.CASCADE, related_name="applications")
    job = models.ForeignKey(Job, on_delete=models.CASCADE, related_name="applications")
    application_date = models.DateField(default=timezone.now)
    duration = models.IntegerField(help_text="Duration in months")
    status = models.CharField(max_length=20, choices=APPLICATION_STATUS, default='Applied')
    feedback_provided = models.BooleanField(default=False)  # Track if feedback has been provided
    contract_viewed = models.BooleanField(default=False)  # Track if the contract has been viewed

    def __str__(self):
        return f"{self.user.full_name} - {self.job.title} ({self.status})"

###############################>>>Tracks when a recruiter views a candidate profile.
class RecruiterView(models.Model):
    recruiter = models.ForeignKey(CompanyRegistration, on_delete=models.CASCADE, related_name="views")
    candidate = models.ForeignKey(UserProfile, on_delete=models.CASCADE, related_name="recruiter_views")
    viewed_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.recruiter.username} viewed {self.candidate.user.username} at {self.viewed_at}"
###############################>>>Tracks when a recruiter save a candidate profile.
class Shortlist(models.Model):
    recruiter = models.ForeignKey(CompanyRegistration, on_delete=models.CASCADE, related_name="shortlists")
    candidate = models.ForeignKey(UserProfile, on_delete=models.CASCADE, related_name="recruiter_shortlists")
    shortlisted_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.recruiter.username} shortlisted {self.candidate.user.username} at {self.shortlisted_at}"
###############################>>>Tracks when a recruiter contacts a candidate profile.
class RecruiterContact(models.Model):
    recruiter = models.ForeignKey(CompanyRegistration, on_delete=models.CASCADE, related_name="contacts")
    candidate = models.ForeignKey(UserProfile, on_delete=models.CASCADE, related_name="recruiter_contacts")
    contacted_at = models.DateTimeField(auto_now_add=True)
    message = models.TextField(null=True, blank=True)  # Optional: Store the message sent by the recruiter

    def __str__(self):
        return f"{self.recruiter.username} contacted {self.candidate.user.username} at {self.contacted_at}"
###############################>>>Logs and tracks user interactions with job posts for analytics and engagement metrics.
class JobInteraction(models.Model):
    INTERACTION_TYPES = [
        ('IMPRESSION', 'Impression'),# Job was shown to the user
        ('VIEW', 'View'),
        ('SAVE', 'Save'),
        ('APPLY', 'Apply'),
    ]

    job = models.ForeignKey(Job, on_delete=models.CASCADE, related_name='interactions')
    user = models.ForeignKey(UserRegistration, on_delete=models.CASCADE, null=True, blank=True)  # Track which user performed the action
    interaction_type = models.CharField(max_length=10, choices=INTERACTION_TYPES)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.user.username if self.user else 'Anonymous'} {self.interaction_type}ed {self.job.title}"

