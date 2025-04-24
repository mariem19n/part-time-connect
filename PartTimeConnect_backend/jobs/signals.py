from django.db.models.signals import post_save, post_delete
from django.dispatch import receiver
from jobs.models import Job , JobApplication , RecruiterView, Shortlist, RecruiterContact, JobInteraction
from feedback.models import Feedback
from accounts.models import UserProfile

@receiver(post_save, sender=Job)
def update_job_popularity_on_job_update(sender, instance, **kwargs):
    """
    Update the popularity score of a job whenever the job is updated.
    """
    instance.update_popularity_score()

@receiver(post_save, sender=JobInteraction)
def update_job_counts_on_interaction_save(sender, instance, **kwargs):
    """
    Update the job's counts (views, saves, applications) when a JobInteraction is saved.
    """
    job = instance.job
    job.update_counts()  # Update counts based on JobInteraction records
    job.update_popularity_score()  # Recalculate popularity score

@receiver(post_delete, sender=JobInteraction)
def update_job_counts_on_interaction_delete(sender, instance, **kwargs):
    """
    Update the job's counts (views, saves, applications) when a JobInteraction is deleted.
    """
    job = instance.job
    job.update_counts()  # Update counts based on JobInteraction records
    job.update_popularity_score()  # Recalculate popularity score

@receiver(post_save, sender=Feedback)
def update_job_popularity_on_feedback(sender, instance, **kwargs):
    """
    Update the popularity score of a job whenever feedback is saved.
    """
    job = instance.job
    job.update_popularity_score()

@receiver(post_delete, sender=Feedback)
def update_job_popularity_on_feedback_delete(sender, instance, **kwargs):
    """
    Update the popularity score of a job whenever feedback is deleted.
    """
    job = instance.job
    job.update_popularity_score()
##################################################################################################### Recruiter-Focused Candidate Ranking Model
@receiver(post_save, sender=JobApplication)
def update_engagement_score(sender, instance, **kwargs):
    """
    Update the user's engagement score whenever a job application is saved.
    """
    if kwargs.get('created', False) or instance.tracker.has_changed('job'):
        user_profile = instance.user
        recruiter_job = instance.job
        user_profile.calculate_engagement_score(recruiter_job)
        user_profile.calculate_recommendation_score(recruiter_job)  # Update recommendation score


@receiver(post_save, sender=Job)
def update_profile_match_score_on_job_change(sender, instance, **kwargs):
    """
    Update the profile match score when a job's requirements are updated.
    """
    # Get all users who have applied to this job
    applicants = UserProfile.objects.filter(applications__job=instance).distinct()

    # Recalculate the profile match score for each applicant
    for user_profile in applicants:
        user_profile.profile_match_score(instance)
        user_profile.calculate_recommendation_score(instance)

####################################################
@receiver(post_save, sender=RecruiterView)
def update_profile_views(sender, instance, **kwargs):
    """
    Increment the profile_views field when a recruiter views the candidate's profile.
    """
    # Increment the profile_views count
    instance.candidate.profile_views += 1
    instance.candidate.save(update_fields=['profile_views'])

    # Recalculate the popularity score (which is part of the recommendation score)
    instance.candidate.calculate_popularity_score()
    # Optional: Recalculate the recommendation_score for all jobs
    for job in Job.objects.all():
        instance.candidate.calculate_recommendation_score(job)

@receiver(post_save, sender=Shortlist)
def update_shortlists(sender, instance, **kwargs):
    """
    Increment the shortlists field when a recruiter shortlists the candidate.
    """
    instance.candidate.shortlists += 1
    instance.candidate.save(update_fields=['shortlists'])
    # Recalculate the popularity score (which is part of the recommendation score)
    instance.candidate.calculate_popularity_score()
    # Optional: Recalculate the recommendation_score for all jobs
    for job in Job.objects.all():
        instance.candidate.calculate_recommendation_score(job)

@receiver(post_save, sender=RecruiterContact)
def update_contacts(sender, instance, **kwargs):
    """
    Increment the contacts field when a recruiter contacts the candidate.
    """
    instance.candidate.contacts += 1
    instance.candidate.save(update_fields=['contacts'])
    # Recalculate the popularity score (which is part of the recommendation score)
    instance.candidate.calculate_popularity_score()
    # Optional: Recalculate the recommendation_score for all jobs
    for job in Job.objects.all():
        instance.candidate.calculate_recommendation_score(job)
####################################################
@receiver(post_save, sender=Feedback)
def update_feedback_score_on_save(sender, instance, **kwargs):
    """
    Recalculate the feedback score when a Feedback instance is saved.
    """
    user_profile = UserProfile.objects.get(user=instance.user)
    user_profile.calculate_feedback_score()
    user_profile.calculate_recommendation_score(instance.job)

@receiver(post_delete, sender=Feedback)
def update_feedback_score_on_delete(sender, instance, **kwargs):
    """
    Recalculate the feedback score when a Feedback instance is deleted.
    """
    user_profile = UserProfile.objects.get(user=instance.user)
    user_profile.calculate_feedback_score()
    user_profile.calculate_recommendation_score(instance.job)






