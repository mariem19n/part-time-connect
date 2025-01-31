# accounts/urls.py
from django.urls import path , include
from . import views

urlpatterns = [
    path('register/', views.registerPage, name='register'),
    path('login/',views.loginPage,name="login"),
    path('logout/',views.logoutUser,name="logout"),
    path('register_company/' ,views.register_company , name="register_company"),
    # path('api/', include('api.urls')),
    path('updateProfile/', views.updateProfile, name='updateProfile'),
]

