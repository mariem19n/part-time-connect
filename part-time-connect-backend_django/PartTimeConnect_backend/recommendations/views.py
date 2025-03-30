from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from .services.recommender import RecommendationEngine

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_recommendations(request):
    user_profile = request.user.userprofile
    all_jobs = Job.objects.filter(is_active=True)  # Import your Job model
    engine = RecommendationEngine()
    recommendations = engine.get_recommendations(user_profile, all_jobs)
    return Response(recommendations)