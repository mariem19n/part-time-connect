from django.shortcuts import get_object_or_404
from django.http import JsonResponse
from .models import Feedback, Job

def create_feedback(request, job_id):
    job = get_object_or_404(Job, id=job_id)
    user = request.user

    # Create feedback
    feedback = Feedback.objects.create(
        job=job,
        user=user,
        rating=request.POST.get("rating"),
        review=request.POST.get("review"),
    )

    # Detect fake feedback
    Feedback.detect_fake_feedback(feedback)
    feedback.save()

    return JsonResponse({"message": "Feedback submitted", "is_fake": feedback.is_fake})