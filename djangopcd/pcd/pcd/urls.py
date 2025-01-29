"""
URL configuration for pcd project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/5.1/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path, include
from accounts import views
from django.http import HttpResponse
from django.views.generic.base import RedirectView
from django.urls import path, include 

def home(request):
    return HttpResponse("Bienvenue sur la page d'accueil !")

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/', include('accounts.urls')),
    path('', home, name='home'), #ken theb tzthal fl page home 
    # path('', RedirectView.as_view(url='/login/', permanent=False), name='root'), ken theb tethal lpage f login toul
    # path('register/', views.registerPage , name='register'),
    # path('login/',views.loginPage,name="login"),
    # path('logout/',views.logoutUser,name="logout"),
    path('api/', include('api.urls')),
    # path('update-profile/', views.updateProfile, name='update-profile'),

]
