# urls.py
from django.urls import path
from . import views
from .views import update_user_location, record_recruiter_view, record_shortlist, record_recruiter_contact, get_profile


urlpatterns = [
    path('request-password-reset/', views.request_password_reset, name='request_password_reset'),
    path('verify-reset-code/', views.verify_reset_code, name='verify_reset_code'),
    path('reset-password/', views.reset_password, name='reset_password'),
    path('login/',views.loginPage,name="login"),
    path('logout/',views.logoutUser,name="logout"),
    path('register/', views.registerPage, name='register'),
    path('register_company/' ,views.companyRegistration , name="companyRegistration"),
    path('profile/<int:user_id>/', views.get_profile, name='profile'),
    path('update-location/', update_user_location, name='update-location'),
    path('search-users/', views.search_users, name='search_users'),
    path('candidates/', views.get_candidates, name='get_candidates'),
    path('recruiter/view/', record_recruiter_view, name='recruiter-view'),
    path('recruiter/shortlist/', record_shortlist, name='recruiter-shortlist'),
    path('recruiter/contact/', record_recruiter_contact, name='recruiter-contact'),
    path('get_profile/<int:user_id>/', get_profile, name='get_profile'),
]


