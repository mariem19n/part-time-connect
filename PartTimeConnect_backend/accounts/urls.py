# urls.py
from django.urls import path
from . import views

urlpatterns = [
    path('request-password-reset/', views.request_password_reset, name='request_password_reset'),
    path('verify-reset-code/', views.verify_reset_code, name='verify_reset_code'),
    path('reset-password/', views.reset_password, name='reset_password'),


    path('login/',views.loginPage,name="login"),
    path('logout/',views.logoutUser,name="logout"),
    path('register/', views.registerPage, name='register'),
    path('register_company/' ,views.companyRegistration , name="companyRegistration"),
    #path('updateProfile/', views.updateProfile, name='updateProfile'),
]


