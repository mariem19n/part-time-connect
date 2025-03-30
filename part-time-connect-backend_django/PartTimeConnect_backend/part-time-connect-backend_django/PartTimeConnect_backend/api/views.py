
# api/views.py

from rest_framework.views import APIView
from rest_framework.response import Response
#from .models import User
#from .serializers import UserSerializer

#class UserList(APIView):
 #   def get(self, request):
  #      users = User.objects.all()  # Get all users from the database
   #     serializer = UserSerializer(users, many=True)  # Serialize the user data
    #    return Response(serializer.data)  # Return the serialized data as a JSON response

class SimpleAPI(APIView):
    def get(self, request):
        return Response({"message": "Django Rest Framework is working!"})