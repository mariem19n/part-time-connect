from django.core.management.base import BaseCommand
from jobs.models import Job
import random

class Command(BaseCommand):
    help = 'Update job statistics with random values and calculate popularity scores'

    def add_arguments(self, parser):
        parser.add_argument(
            '--max-applications',
            type=int,
            default=100,
            help='Maximum number of applications to generate (default: 100)'
        )
        parser.add_argument(
            '--max-views',
            type=int,
            default=500,
            help='Maximum number of views to generate (default: 500)'
        )
        parser.add_argument(
            '--max-saves',
            type=int,
            default=50,
            help='Maximum number of saves to generate (default: 50)'
        )

    def handle(self, *args, **options):
        max_apps = options['max_applications']
        max_views = options['max_views']
        max_saves = options['max_saves']

        jobs = Job.objects.all()
        total_jobs = jobs.count()

        self.stdout.write(f"Updating statistics for {total_jobs} jobs...")

        for i, job in enumerate(jobs, 1):
            job.applications_count = random.randint(0, max_apps)
            job.views_count = random.randint(0, max_views)
            job.saves_count = random.randint(0, max_saves)
            job.save()
            job.update_popularity_score()  # Let the model calculate the score
            
            if i % 100 == 0:  # Print progress every 100 jobs
                self.stdout.write(f"Processed {i}/{total_jobs} jobs...")

        self.stdout.write(
            self.style.SUCCESS(f'Successfully updated statistics for {total_jobs} jobs')
        )