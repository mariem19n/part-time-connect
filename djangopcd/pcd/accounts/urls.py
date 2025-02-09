# urls.py
from django.urls import path
from . import views


urlpatterns = [
    path('profile/<int:user_id>/', views.get_profile, name='profile'),
    path('request-password-reset/', views.request_password_reset, name='request_password_reset'),
    path('verify-reset-code/', views.verify_reset_code, name='verify_reset_code'),
    path('reset-password/', views.reset_password, name='reset_password'),

    #path('api/profile/<int:user_id>/', get_profile, name='profile'),


    path('login/',views.loginPage,name="login"),
    path('logout/',views.logoutUser,name="logout"),
    path('register/', views.registerPage, name='register'),
    path('register_company/' ,views.companyRegistration , name="companyRegistration"),
    #path('updateProfile/', views.updateProfile, name='updateProfile'),
    path("set_company_description", views.set_company_description, name="set_company_description"),
    path('edit_company_description/<int:company_id>/', views.edit_company_description, name='edit_company_description'),
    path('update_company_name/<int:company_id>/', views.update_company_name, name='update_company_name'),
    path('update_user_name/<int:user_id>/', views.update_user_name, name="update_user_name"),
    path('update_skills/<int:user_id>/', views.update_user_skills, name="update_skills"),
    path('update-profile-picture/<int:user_id>/', views.update_profile_picture, name='update_profile_picture'),
    
]
