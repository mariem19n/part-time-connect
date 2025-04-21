from django.core.management.base import BaseCommand
from django.contrib.auth.hashers import make_password
from django.db import transaction, IntegrityError
from faker import Faker
import random
import json
from datetime import datetime, timedelta
from accounts.models import UserRegistration, UserProfile
from jobs.models import Job
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity
from django.core.exceptions import ValidationError

class Command(BaseCommand):
    help = 'Create 1000 complete test user profiles with all fields populated'

    def handle(self, *args, **options):
        # First delete all existing test users to start fresh
        self.stdout.write("Deleting existing test users...")
        with transaction.atomic():
            UserProfile.objects.filter(user__email__contains="@example.com").delete()
            UserRegistration.objects.filter(email__contains="@example.com").delete()
        
        fake = Faker('fr_FR')
        skills_pool = [
            'Python', 'Django', 'JavaScript', 'React', 'Vue.js',
            'SQL', 'PostgreSQL', 'MongoDB', 'Git', 'Docker',
            'Machine Learning', 'Data Analysis', 'UI/UX Design',
            'Project Management', 'Marketing Digital', 'SEO',
            'Comptabilité', 'Ressources Humaines', 'Vente'
        ]
        
        locations = [
            'Paris', 'Lyon', 'Marseille', 'Toulouse', 'Nantes',
            'Bordeaux', 'Lille', 'Rennes', 'Strasbourg', 'Nice'
        ]
        
        languages = ['Français', 'Anglais', 'Espagnol', 'Allemand', 'Arabe']
        job_titles = [
            'Développeur Full-Stack', 'Data Scientist', 'Chef de Projet',
            'Graphiste', 'Comptable', 'Commercial', 'RH', 'Marketing Digital',
            'Community Manager', 'Ingénieur Système'
        ]

        for i in range(1, 1001):
            try:
                with transaction.atomic():
                    # Generate unique username and email
                    username = f"user_{i}_{fake.user_name()}"
                    email = f"user_{i}@example.com"

                    # Check if user already exists (shouldn't happen after delete, but just in case)
                    if UserRegistration.objects.filter(email=email).exists():
                        continue

                    

                    # Create user
                    user = UserRegistration.objects.create(
                        email=email,
                        username=username,
                        password=make_password('testpass123'),
                        skills=', '.join(random.sample(skills_pool, random.randint(2, 5))),
                        user_type='JobSeeker'
                    )

                    # Generate engagement metrics
                    engagement = self.generate_engagement_metrics()
                    # Generate education and portfolio data
                    education = self.generate_education(fake) or []
                    portfolio = self.generate_portfolio(fake, job_titles) or []
                    languages_spoken = random.sample(languages, random.randint(1, 3)) if languages else []
                    
                    print("\n=== DEBUG DATA ===")
                    print("Education:", education)  # or self.generate_education(fake)
                    print("Portfolio:", portfolio)  # or self.generate_portfolio(fake, job_titles)
                    print("Languages:", languages_spoken)
                    print("Engagement:", engagement)
                    print("Skills:", random.sample(skills_pool, random.randint(3, 6)) if skills_pool else [])
                    print("=================\n")
                    
                    profile = UserProfile.objects.filter(user=user).first()

                    # Prepare all data first
                    profile_data = {
                        'full_name': fake.name(),
                        'phone': fake.phone_number(),
                        'preferred_locations': random.sample(locations, random.randint(1, 3)) if locations else [],
                        'about_me': fake.text(max_nb_chars=200),
                        'skills': random.sample(skills_pool, random.randint(3, 6)) if skills_pool else [],
                        'education_certifications': education,
                        'languages_spoken': languages_spoken,
                        'portfolio': portfolio,
                        'profile_views': engagement.get('profile_views', 0),
                        'shortlists': engagement.get('shortlists', 0),
                        'contacts': engagement.get('contacts', 0),
                    }

                    if not profile:
                        print("Creating new profile...")
                        profile = UserProfile.objects.create(user=user, **profile_data)
                    else:
                        print("Updating existing profile...")
                        for field, value in profile_data.items():
                            setattr(profile, field, value)
                        profile.save()

                    try:
                        if profile:
                            print("Generating scores...")
                            self.generate_scores(profile)
                    except Exception as e:
                        print(f"Error generating scores for user {user.email}: {str(e)}")
                    db_profile = UserProfile.objects.get(pk=profile.pk)
                    print("\n=== SAVED PROFILE ===")
                    print("Education:", db_profile.education_certifications)
                    print("Portfolio:", db_profile.portfolio)
                    print("Languages:", db_profile.languages_spoken)
                    print("Scores:", {
                        'popularity': db_profile.popularity_score,
                        'feedback': db_profile.feedback_score,
                        'engagement': db_profile.engagement_score,
                        'recommendation': db_profile.recommendation_score
                    })
                    print("====================\n")

                if i % 100 == 0:
                    self.stdout.write(f"Created {i} complete user profiles...")

            except Exception as e:
                self.stdout.write(self.style.ERROR(f"Error creating user {i}: {str(e)}"))
                import traceback
                traceback.print_exc()

        self.stdout.write(self.style.SUCCESS("Successfully created 1000 complete user profiles"))

    # Rest of your methods remain exactly the same...
    def generate_engagement_metrics(self):
        """Generate realistic correlated engagement metrics"""
        # Base popularity follows power law distribution
        base_popularity = random.paretovariate(1.2)
        
        # Generate profile views (50-5000 range, skewed distribution)
        views = int(50 + (5000 * (1 - 1/base_popularity)))
        
        # Shortlists are 5-25% of views
        shortlists = int(views * random.uniform(0.05, 0.25))
        
        # Contacts are 10-40% of shortlists
        contacts = int(shortlists * random.uniform(0.10, 0.40))
        
        return {
            'profile_views': min(views, 10000),  # Cap at 10,000 views
            'shortlists': min(shortlists, 500),  # Cap at 500 shortlists
            'contacts': min(contacts, 200),      # Cap at 200 contacts
        }

    def generate_education(self, fake):
        degrees = [
            "BAC+2 BTS Informatique",
                    "BAC+3 Licence Pro",
                    "BAC+5 Master",
                    "BAC+8 Doctorat",
                    "Bootcamp Coding"
                ]
        return [{
            'degree': random.choice(degrees),
            'institution': fake.company(),
            'year': random.randint(2000, 2023),
            'description': fake.sentence()
        } for _ in range(random.randint(1, 3))]

    def generate_portfolio(self, fake, job_titles):
        return [{
            'title': f"Projet {job}",
            'description': fake.text(max_nb_chars=100),
            'year': random.randint(2018, 2023),
            'url': fake.url(),
            'technologies': random.sample(['Python', 'JavaScript', 'HTML/CSS', 'React', 'Django'],
                                    random.randint(1, 3))
        } for job in random.sample(job_titles, random.randint(1, 4))]

    def generate_scores(self, profile):
        """Generate all scores based on engagement metrics"""
        try:
            # Ensure we have valid engagement metrics, defaulting to 1 if values are zero
            profile_views = max(profile.profile_views, 1)  # Avoid division by zero
            shortlists = max(profile.shortlists, 1)
            contacts = max(profile.contacts, 1)

            # Popularity score (0-1 scale)
            profile.popularity_score = min(
                0.3 * (profile_views / 1000) +  # 30% weight for views
                0.5 * (shortlists / 100) +     # 50% weight for shortlists
                0.2 * (contacts / 50),          # 20% weight for contacts
                1.0  # Cap at 1.0
            )

            # Feedback score (based on popularity with some random variability)
            profile.feedback_score = min(
                profile.popularity_score * 0.8 + random.uniform(0, 0.3),
                1.0
            )

            # Engagement score (combining popularity and random variability)
            profile.engagement_score = min(
                0.6 * (profile.popularity_score) +  # 60% weight for popularity
                0.4 * random.uniform(0.2, 0.9),    # 40% random factor
                1.0
            )

            # Recommendation score (based on popularity, feedback, and engagement)
            profile.recommendation_score = min(
                (profile.popularity_score * 0.4) +
                (profile.feedback_score * 0.3) +
                (profile.engagement_score * 0.3),
                1.0
            )

            # Save the updated profile
            profile.save()
            print(f"Scores generated for {profile.user.email}: {profile.popularity_score}, {profile.feedback_score}, {profile.engagement_score}, {profile.recommendation_score}")

        except Exception as e:
            print(f"Error generating scores: {str(e)}")


