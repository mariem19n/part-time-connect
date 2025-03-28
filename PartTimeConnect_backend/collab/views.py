#from django.http import JsonResponse
#from .recommender import get_recommendations_for_user

#def recommendations_api(request):
#    if not request.user.is_authenticated:
#        return JsonResponse({"error": "unauthorized"}, status=401)

#    recommended_jobs = get_recommendations_for_user(request.user.id)

    # Préparer les données pour JSON
 #   job_list = [
  #      {
   #         "id": job.id,
    #        "title": job.title,
    #        "location": job.location,
    #        "salary": float(job.salary),
     #   }
      #  for job in recommended_jobs
    #]

    #return JsonResponse({"recommended_jobs": job_list}) 

from rest_framework.decorators import api_view, permission_classes, authentication_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.authentication import TokenAuthentication
from rest_framework.response import Response
from .recommender import get_recommendations_for_user

@api_view(['GET'])
@authentication_classes([TokenAuthentication])
@permission_classes([IsAuthenticated])
def recommendations_api(request):
    user_id = request.user.id
    recommended_jobs = get_recommendations_for_user(user_id)

    job_list = [
        {
            "id": job.id,
            "title": job.title,
            "location": job.location,
            "salary": float(job.salary),
        }
        for job in recommended_jobs
    ]
    return Response({"recommended_jobs": job_list})