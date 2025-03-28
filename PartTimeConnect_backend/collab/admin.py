
from django.contrib import admin
from .models import Job, JobInteraction

@admin.register(Job)
class JobAdmin(admin.ModelAdmin):
    list_display = ('title', 'location', 'salary')
    search_fields = ('title', 'location')

@admin.register(JobInteraction)
class JobInteractionAdmin(admin.ModelAdmin):
    list_display = ('user', 'job', 'rating', 'timestamp')
    list_filter = ('rating', 'timestamp')
    search_fields = ('user__username', 'job__title')
