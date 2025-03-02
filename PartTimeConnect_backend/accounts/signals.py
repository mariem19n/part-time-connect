from django.db.models.signals import post_save
from django.dispatch import receiver
from .models import UserRegistration, UserProfile
from jobs.models import Job
from django.db import transaction
##################################################################################Recruiter-Focused Candidate Ranking Model
@receiver(post_save, sender=UserRegistration)
def create_user_profile(sender, instance, created, **kwargs):
    if created:
        UserProfile.objects.create(user=instance)

@receiver(post_save, sender=UserRegistration)
def save_user_profile(sender, instance, **kwargs):
    instance.profile.save()  # Accéder à `profile`, pas `userprofile`

@receiver(post_save, sender=UserProfile)
def update_profile_match_score_on_user_change(sender, instance, **kwargs):
    """
    Update the profile match score when the user's profile is updated.
    """
    def _update_profile_match_score():
        # Get all jobs the user has applied to
        applied_jobs = Job.objects.filter(applications__user=instance).distinct()

        # Recalculate the profile match score for each job
        for job in applied_jobs:
            instance.profile_match_score(job)

    # Defer the execution until after the transaction is committed
    transaction.on_commit(_update_profile_match_score)

@receiver(post_save, sender=UserProfile)
def update_recommendation_score(sender, instance, **kwargs):
    """
    Update the recommendation score when a UserProfile is saved.
    """
    def _update_recommendation_score():
        # Get all jobs the user has applied to
        applied_jobs = Job.objects.filter(applications__user=instance).distinct()

        # Recalculate the recommendation score for each job
        for job in applied_jobs:
            instance.calculate_recommendation_score(job)

        # Update the previous_recommendation_score
        instance.previous_recommendation_score = instance.recommendation_score
        instance.save(update_fields=["previous_recommendation_score"])

    # Defer the execution until after the transaction is committed
    transaction.on_commit(_update_recommendation_score)

