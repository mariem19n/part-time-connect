from rest_framework.decorators import api_view, authentication_classes, permission_classes
from rest_framework.response import Response
from django.core.cache import cache
from rest_framework.authentication import TokenAuthentication
from rest_framework.permissions import IsAuthenticated


@api_view(['GET'])
@authentication_classes([TokenAuthentication])
@permission_classes([IsAuthenticated])
def job_seeker_recommendations(request):
    """For job seekers - returns popular jobs"""
    if not request.user.is_authenticated:
        return Response(status=401)
    
    # Get cached or fresh recommendations
    cache_key = f'job_recs_{request.user.id}'
    recommendations = cache.get(cache_key)
    
    if not recommendations:
        from jobs.models import Job
        recommendations = Job.objects.order_by('-popularity_score')[:10]
        cache.set(cache_key, recommendations, timeout=3600)  # Cache for 1 hour
    
    # Simple serialization
    data = [{
        'id': job.id,
        'title': job.title,
        'company': job.company.username,
        'popularity_score': job.popularity_score
    } for job in recommendations]
    
    return Response({'preview_items': data[:10], 'all_items': data})

@api_view(['GET'])
@authentication_classes([TokenAuthentication])
@permission_classes([IsAuthenticated])
def recruiter_recommendations(request, job_id=None):
    """For recruiters - returns recommended candidates"""
    if not request.user.is_authenticated:
        return Response(status=401)
    
    from accounts.models import UserProfile
    candidates = UserProfile.objects.order_by('-recommendation_score')
    
    if job_id:
        candidates = candidates.filter(skills__overlap=Job.objects.get(id=job_id).requirements)
    
    data = [{
        'id': profile.user.id,
        'name': profile.full_name,
        'skills': profile.skills,
        'score': profile.recommendation_score
    } for profile in candidates[:10]]
    
    return Response({'preview_items': data[:10], 'all_items': data})