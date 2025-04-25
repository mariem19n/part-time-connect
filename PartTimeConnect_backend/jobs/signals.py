from django.db.models.signals import post_save, post_delete
from django.dispatch import receiver
from jobs.models import Job , JobApplication , RecruiterView, Shortlist, RecruiterContact, JobInteraction
from feedback.models import Feedback
from accounts.models import UserProfile
from django.db.models import F

@receiver(post_save, sender=Job)
def update_job_popularity_on_job_update(sender, instance, **kwargs):
    """
    Update the popularity score of a job whenever the job is updated.
    """
    instance.update_popularity_score()

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
###Recruiter-Focused Candidate Ranking Model################################################### Tracking interactions recruteur-candidat >>>Done
""" Ces trois signaux (update_profile_views, update_shortlists et update_contacts) mettent à jour respectivement les compteurs de vues,
de sélections et de contacts des candidats lorsqu'un recruteur interagit avec leur profil, tout en recalculant leurs scores de popularité
et de recommandation de manière optimisée pour éviter les boucles infinies, avec un suivi détaillé des opérations via des logs."""

from django.db import transaction, models

@receiver(post_save, sender=RecruiterView)
def update_profile_views(sender, instance, created, **kwargs):
    """
    Increment profile_views and update scores without causing infinite loops
    """
    print("\n===== Starting update_profile_views signal =====")
    
    if not created:  # Only process new views
        print("Skipping - not a new RecruiterView instance")
        return

    try:
        print(f"Updating view count for candidate ID: {instance.candidate.pk}")
        # 1. Update view count (direct SQL update to avoid save() signal)
        UserProfile.objects.filter(pk=instance.candidate.pk).update(
            profile_views=models.F('profile_views') + 1
        )
        
        print("Starting transaction...")
        # 2. Refresh and process
        with transaction.atomic():
            candidate = UserProfile.objects.get(pk=instance.candidate.pk)
            print(f"Retrieved candidate: {candidate.user.username}")
            
            # 3. Calculate scores without triggering save()
            print("Calculating popularity score...")
            candidate.calculate_popularity_score()
            
            # Update fields manually to avoid save()
            print("Updating scores fields...")
            candidate.save(update_fields=[
                'popularity_score',
                'engagement_score',
                'feedback_score',
                'recommendation_score'
            ])  # Removed update_modified parameter
            
            # 4. Process just one sample job (or batch if needed)
            sample_job = Job.objects.order_by('?').first()  # Random job sample
            if sample_job:
                print(f"Calculating recommendation for job: {sample_job.title}")
                candidate.calculate_recommendation_score(sample_job)
                candidate.save(update_fields=['recommendation_score'])
            else:
                print("No jobs found to calculate recommendation score")
                
        print("===== Successfully completed =====")
                
    except Exception as e:
        print(f"\n!!! ERROR in update_profile_views !!!")
        print(f"Type: {type(e).__name__}")
        print(f"Message: {str(e)}")
        print("Full traceback:")
        import traceback
        traceback.print_exc()
        print("===== Failed =====")

@receiver(post_save, sender=Shortlist)
def update_shortlists(sender, instance, created, **kwargs):
    """
    Increment shortlists and update scores without causing infinite loops
    """
    print("\n===== Starting update_shortlists signal =====")
    
    if not created:  # Only process new shortlists
        print("Skipping - not a new Shortlist instance")
        return

    try:
        print(f"Updating shortlist count for candidate ID: {instance.candidate.pk}")
        # 1. Update shortlist count (direct SQL update to avoid save() signal)
        UserProfile.objects.filter(pk=instance.candidate.pk).update(
            shortlists=models.F('shortlists') + 1
        )
        
        print("Starting transaction...")
        # 2. Refresh and process
        with transaction.atomic():
            candidate = UserProfile.objects.get(pk=instance.candidate.pk)
            print(f"Retrieved candidate: {candidate.user.username}")
            
            # 3. Calculate scores without triggering save()
            print("Calculating popularity score...")
            candidate.calculate_popularity_score()
            
            # Update fields manually to avoid save()
            print("Updating scores fields...")
            candidate.save(update_fields=[
                'popularity_score',
                'engagement_score',
                'feedback_score',
                'recommendation_score'
            ])
            
            # 4. Process just one sample job (or batch if needed)
            sample_job = Job.objects.order_by('?').first()  # Random job sample
            if sample_job:
                print(f"Calculating recommendation for job: {sample_job.title}")
                candidate.calculate_recommendation_score(sample_job)
                candidate.save(update_fields=['recommendation_score'])
            else:
                print("No jobs found to calculate recommendation score")
                
        print("===== Successfully completed =====")
                
    except Exception as e:
        print(f"\n!!! ERROR in update_shortlists !!!")
        print(f"Type: {type(e).__name__}")
        print(f"Message: {str(e)}")
        print("Full traceback:")
        import traceback
        traceback.print_exc()
        print("===== Failed =====")

@receiver(post_save, sender=RecruiterContact)
def update_contacts(sender, instance, created, **kwargs):
    """
    Increment contacts and update scores without causing infinite loops
    """
    print("\n===== Starting update_contacts signal =====")
    
    if not created:  # Only process new contacts
        print("Skipping - not a new RecruiterContact instance")
        return

    try:
        print(f"Updating contact count for candidate ID: {instance.candidate.pk}")
        # 1. Update contact count (direct SQL update to avoid save() signal)
        UserProfile.objects.filter(pk=instance.candidate.pk).update(
            contacts=models.F('contacts') + 1
        )
        
        print("Starting transaction...")
        # 2. Refresh and process
        with transaction.atomic():
            candidate = UserProfile.objects.get(pk=instance.candidate.pk)
            print(f"Retrieved candidate: {candidate.user.username}")
            
            # 3. Calculate scores without triggering save()
            print("Calculating popularity score...")
            candidate.calculate_popularity_score()
            
            # Update fields manually to avoid save()
            print("Updating scores fields...")
            candidate.save(update_fields=[
                'popularity_score',
                'engagement_score',
                'feedback_score',
                'recommendation_score'
            ])
            
            # 4. Process just one sample job (or batch if needed)
            sample_job = Job.objects.order_by('?').first()  # Random job sample
            if sample_job:
                print(f"Calculating recommendation for job: {sample_job.title}")
                candidate.calculate_recommendation_score(sample_job)
                candidate.save(update_fields=['recommendation_score'])
            else:
                print("No jobs found to calculate recommendation score")
                
        print("===== Successfully completed =====")
                
    except Exception as e:
        print(f"\n!!! ERROR in update_contacts !!!")
        print(f"Type: {type(e).__name__}")
        print(f"Message: {str(e)}")
        print("Full traceback:")
        import traceback
        traceback.print_exc()
        print("===== Failed =====")

###Candidat-Focused Job Offer Ranking Model################################################### Tracking interactions candidat->Job Offer >>>Done
"""Ce signal Django s’active après la création d’une interaction (VIEW, SAVE, ou APPLY) 
et met à jour les compteurs correspondants dans l’offre d’emploi, puis recalcule son score de popularité."""
@receiver(post_save, sender=JobInteraction)
def update_job_interactions(sender, instance, created, **kwargs):
    if not created:
        return

    try:
        # Update counts based on interaction type
        if instance.interaction_type == 'VIEW':
            Job.objects.filter(pk=instance.job_id).update(
                views_count=F('views_count') + 1
            )
        elif instance.interaction_type == 'SAVE':
            Job.objects.filter(pk=instance.job_id).update(
                saves_count=F('saves_count') + 1
            )
        elif instance.interaction_type == 'APPLY':
            Job.objects.filter(pk=instance.job_id).update(
                applications_count=F('applications_count') + 1
            )
        
        # Recalculate popularity score
        instance.job.update_popularity_score()
        
    except Exception as e:
        print(f"Error updating job interactions: {str(e)}")





