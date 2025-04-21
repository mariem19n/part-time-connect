#from django.urls import path
#from .views import recommendations_api

#urlpatterns = [
#    path('recommendations/', recommendations_api, name='recommendations'),
#]


from django.urls import path
from .views import recommend_jobs

urlpatterns = [
    path('recommend/<int:user_id>/', recommend_jobs, name='recommend_jobs'),
]
