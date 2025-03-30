from django.db.models.signals import pre_save
from django.dispatch import receiver
from .models import Feedback

@receiver(pre_save, sender=Feedback)
def detect_fake_feedback_signal(sender, instance, **kwargs):
    """
    Automatically detect fake feedback before saving.
    """
    Feedback.detect_fake_feedback(instance)