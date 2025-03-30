from django.db.models.signals import post_save
from django.dispatch import receiver
from jobs.models import Job
from .services.recommender import RecommendationEngine
from .models import JobEmbedding

@receiver(post_save, sender=Job)
def update_job_embeddings(sender, instance, **kwargs):
    engine = RecommendationEngine()
    job_text = engine.create_job_text(instance)
    embedding = engine.embedding_model.encode([job_text])[0]
    
    JobEmbedding.objects.update_or_create(
        job=instance,
        defaults={'embedding': pickle.dumps(embedding)}
    )