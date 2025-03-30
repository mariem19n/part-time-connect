
from django.db.models.signals import post_save
from django.dispatch import receiver
from .models import UserRegistration, UserProfile
from jobs.models import Job
from django.db import transaction
@receiver(post_save, sender=UserRegistration)
def create_user_profile(sender, instance, created, **kwargs):
    if created:
        UserProfile.objects.create(user=instance)

@receiver(post_save, sender=UserProfile)
def update_user_scores(sender, instance, created, **kwargs):
    """
    Consolidated signal handler for all score updates
    """
    if created:
        return  # No need to calculate scores for newly created profiles
    
    # Check which fields were updated (if any)
    update_fields = kwargs.get('update_fields', None)
    
    # Only proceed if relevant fields were changed or it's a full save
    relevant_fields = {'skills', 'education_certifications', 'profile_views', 
                      'shortlists', 'contacts', 'feedback_score'}
    
    if update_fields is None or any(field in update_fields for field in relevant_fields):
        def _update_scores():
            # Get all jobs the user has applied to
            applied_jobs = Job.objects.filter(applications__user=instance.user).distinct()
            
            # Update all scores for each relevant job
            for job in applied_jobs:
                instance.calculate_popularity_score()
                instance.calculate_engagement_score(job)
                instance.calculate_feedback_score()
                instance.profile_match_score(job)
                instance.calculate_recommendation_score(job)
                
            # Save the previous score
            instance.previous_recommendation_score = instance.recommendation_score
            instance.save(update_fields=['previous_recommendation_score'])
        
        # Defer execution until after transaction commits
        transaction.on_commit(_update_scores)
##################################################################################Recruiter-Focused Candidate Ranking Model
# @receiver(post_save, sender=UserRegistration)
# def create_user_profile(sender, instance, created, **kwargs):
#     if created:
#         UserProfile.objects.create(user=instance)
# @receiver(post_save, sender=UserProfile)
# def on_profile_change(sender, instance, **kwargs):
#     """Handle all profile updates in one place"""
#     changed_fields = kwargs.get('update_fields') or []
    
#     # Only process if relevant fields changed
#     if not changed_fields or any(f in changed_fields for f in ['skills', 'education']):
#         # Remove the async call since we haven't implemented it
#         instance.calculate_recommendation_score()  # Call your existing method

# @receiver(post_save, sender=UserProfile)
# def update_profile_match_score_on_user_change(sender, instance, **kwargs):
#     """
#     Update the profile match score when the user's profile is updated.
#     """
#     def _update_profile_match_score():
#         # Get all jobs the user has applied to
#         applied_jobs = Job.objects.filter(applications__user=instance).distinct()

#         # Recalculate the profile match score for each job
#         for job in applied_jobs:
#             instance.profile_match_score(job)

#     # Defer the execution until after the transaction is committed
#     transaction.on_commit(_update_profile_match_score)

# @receiver(post_save, sender=UserProfile)
# def update_recommendation_score(sender, instance, **kwargs):
#     """
#     Update the recommendation score when a UserProfile is saved.
#     """
#     def _update_recommendation_score():
#         # Get all jobs the user has applied to
#         applied_jobs = Job.objects.filter(applications__user=instance).distinct()

#         # Recalculate the recommendation score for each job
#         for job in applied_jobs:
#             instance.calculate_recommendation_score(job)

#         # Update the previous_recommendation_score
#         instance.previous_recommendation_score = instance.recommendation_score
#         instance.save(update_fields=["previous_recommendation_score"])

#     # Defer the execution until after the transaction is committed
#     transaction.on_commit(_update_recommendation_score)

# @receiver(post_save, sender=UserRegistration)
# def save_user_profile(sender, instance, **kwargs):
#     instance.profile.save()  # Accéder à `profile`, pas `userprofile`

