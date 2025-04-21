from django.contrib import admin
from django.urls import path, include  # Make sure 'include' is imported
from django.conf import settings
from django.conf.urls.static import static

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/', include('api.urls')),
    path('api/', include('accounts.urls')),
    path("api/jobs/", include("jobs.urls")),
    path('rec/', include('popularity_recommendation.urls')),
    path('chat/', include('chat.urls')),

] + static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
