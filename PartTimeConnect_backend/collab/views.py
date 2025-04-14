from rest_framework.decorators import api_view, authentication_classes, permission_classes
from rest_framework.response import Response
from rest_framework import status
from rest_framework.authentication import TokenAuthentication
from rest_framework.permissions import IsAuthenticated

from django.shortcuts import get_object_or_404
from django.contrib.auth.models import User
from jobs.models import Job
from .recommender import get_recommendations_for_user


@api_view(['GET'])
@authentication_classes([TokenAuthentication])
@permission_classes([IsAuthenticated])
def recommend_jobs(request, user_id):
    user = get_object_or_404(User, id=user_id)

    recommended_jobs = get_recommendations_for_user(user_id, top_n=5)

    jobs_data = [
        {
            "id": job.id,
            "title": job.title,
            "location": job.location,
            "salary": job.salary,
        }
        for job in recommended_jobs
    ]

    return Response({"recommended_jobs": jobs_data}, status=status.HTTP_200_OK)
