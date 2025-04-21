import os
import json
import django
from django.contrib.auth.hashers import make_password
from faker import Faker
import random
from datetime import datetime, timedelta

# Setup Django environment
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'PartTimeConnect.settings')
django.setup()

from accounts.models import UserRegistration, UserProfile, CompanyRegistration
from jobs.models import Job, JobApplication, JobInteraction, RecruiterView, Shortlist, RecruiterContact

fake = Faker()

# Expanded domains and skills with more options
DOMAINS = {
    'tech': ['Python', 'JavaScript', 'Java', 'C++', 'React', 'Django', 'AWS', 'SQL', 
             'Git', 'Docker', 'Kubernetes', 'Machine Learning', 'Data Science'],
    'healthcare': ['Nursing', 'Patient Care', 'Phlebotomy', 'EMT', 'Medical Coding',
                  'CPR Certified', 'First Aid', 'IV Therapy', 'Wound Care'],
    'finance': ['Accounting', 'Financial Analysis', 'Excel', 'QuickBooks', 'Risk Management',
               'Tax Preparation', 'Auditing', 'Financial Modeling', 'Bookkeeping'],
    'education': ['Teaching', 'Curriculum Design', 'E-Learning', 'Classroom Management',
                 'Lesson Planning', 'Educational Technology', 'Special Education'],
    'design': ['UI/UX', 'Graphic Design', 'Figma', 'Adobe CC', 'Illustration',
              'Typography', 'Branding', 'Web Design', 'Print Design'],
    'engineering': ['Civil Engineering', 'Mechanical Engineering', 'CAD', 'Project Management'],
    'marketing': ['Digital Marketing', 'SEO', 'Content Creation', 'Social Media'],
    'hospitality': ['Hotel Management', 'Culinary Arts', 'Event Planning']
}

COMPANIES = [
    {'name': 'TechSolutions Inc', 'domain': 'tech'},
    {'name': 'HealthCare Plus', 'domain': 'healthcare'},
    {'name': 'Global Finance', 'domain': 'finance'},
    {'name': 'EduFuture', 'domain': 'education'},
    {'name': 'DesignHub', 'domain': 'design'},
    {'name': 'BuildRight Engineering', 'domain': 'engineering'},
    {'name': 'MarketGrow', 'domain': 'marketing'},
    {'name': 'Grand Hotels', 'domain': 'hospitality'}
]

def clear_existing_data():
    """Safely clear existing test data"""
    print("Clearing existing test data...")
    # Delete in reverse order to respect foreign key constraints
    RecruiterContact.objects.all().delete()
    Shortlist.objects.all().delete()
    RecruiterView.objects.all().delete()
    JobInteraction.objects.all().delete()
    JobApplication.objects.all().delete()
    Job.objects.all().delete()
    UserProfile.objects.all().delete()
    UserRegistration.objects.filter(email__contains='@example.com').delete()
    CompanyRegistration.objects.filter(email__contains='@example.com').delete()
    print("Cleared existing test data")

def create_companies():
    """Create or update companies"""
    created = 0
    for company_data in COMPANIES:
        domain = company_data['domain']
        email = f"contact@{company_data['name'].replace(' ', '').lower()}.com"
        
        company, created_flag = CompanyRegistration.objects.get_or_create(
            email=email,
            defaults={
                'username': company_data['name'],
                'password': make_password('company123'),
                'jobtype': domain.capitalize(),
                'company_description': fake.paragraph(),
                'user_type': 'JobProvider'
            }
        )
        if created_flag:
            created += 1
    print(f"Created {created} new companies (total: {CompanyRegistration.objects.count()})")

def create_users(num_users=200):
    """Create users with complete profiles"""
    created_users = 0
    LANGUAGE_CHOICES = [
        'English', 'French', 'Spanish', 'German', 'Mandarin',
        'Arabic', 'Russian', 'Portuguese', 'Italian', 'Japanese'
    ]
    
    UNIVERSITIES = [
        "Harvard University", "Stanford University", "MIT", 
        "University of Cambridge", "ETH Zurich",
        "University of Tokyo", "Sorbonne University",
        "Technical University of Munich", "University of Toronto"
    ]
    
    for i in range(num_users):
        domain = random.choice(list(DOMAINS.keys()))
        username = f"{domain[:3]}_{fake.user_name()}_{i}"
        email = f"{username}@example.com"
        
        # Skip if user already exists
        if UserRegistration.objects.filter(email=email).exists():
            continue
            
        try:
            # Generate profile data first
            full_name = fake.name()
            phone = f"+1{fake.msisdn()[3:]}"  # US format numbers
            locations = [fake.city() for _ in range(random.randint(1, 3))]
            about_me = f"My name is {full_name}. {fake.text(max_nb_chars=200)}"
            education = [
                f"{random.choice(['BSc', 'MSc', 'PhD'])} in {domain.capitalize()} - {random.choice(UNIVERSITIES)}",
                f"{domain.capitalize()} Certification from {fake.company()}"
            ]
            languages = random.sample(LANGUAGE_CHOICES, random.randint(1, 3))
            
            # Create UserRegistration
            user = UserRegistration.objects.create(
                username=username,
                email=email,
                password=make_password('user123'),
                skills=', '.join(random.sample(DOMAINS[domain], min(3, len(DOMAINS[domain])))),
                user_type='JobSeeker'
            )
            
            # Create UserProfile - using get_or_create to be safe
            profile, created = UserProfile.objects.get_or_create(
                user=user,
                defaults={
                    'full_name': full_name,
                    'phone': phone,
                    'preferred_locations': locations,
                    'about_me': about_me,
                    'skills': random.sample(DOMAINS[domain], min(5, len(DOMAINS[domain]))),
                    'education_certifications': education,
                    'languages_spoken': languages,
                    'profile_views': random.randint(0, 100),
                    'shortlists': random.randint(0, 20),
                    'contacts': random.randint(0, 10),
                    'engagement_score': random.uniform(0, 1),
                    'popularity_score': random.uniform(0, 1),
                    'feedback_score': random.uniform(0, 5)
                }
            )
            
            if created:
                created_users += 1
                
                if created_users % 20 == 0:
                    print(f"Created {created_users} users so far...")
            else:
                print(f"Profile already exists for {username}")
                
        except Exception as e:
            print(f"Error creating user {username}: {str(e)}")
            continue
    
    print(f"Finished creating users. Successfully created {created_users} new users")


def create_jobs():
    """Create jobs for companies"""
    created_jobs = 0
    companies = CompanyRegistration.objects.all()
    
    for company in companies:
        domain = next((k for k, v in DOMAINS.items() if k in company.jobtype.lower()), 'tech')
        domain_skills = DOMAINS.get(domain, [])
        
        for _ in range(5):  # 5 jobs per company
            try:
                # Ensure we have enough skills to sample from
                req_skills = random.sample(domain_skills, min(4, len(domain_skills)))
                benefits = random.sample(
                    ['Health insurance', 'Flexible hours', 'Remote work', 
                     'Annual bonus', 'Stock options', 'Training budget'],
                    random.randint(1, 3)
                )
                
                Job.objects.create(
                    company=company,
                    title=f"{domain.capitalize()} {fake.job()}",
                    description=fake.text(),
                    location=random.choice(['Berlin', 'London', 'Paris', 'Remote']),
                    salary=random.randint(30000, 100000),
                    is_salary_negotiable=random.choice([True, False]),
                    working_hours=random.choice(['9-5', 'Flexible', 'Shift work']),
                    duration=random.randint(6, 24),
                    contract_type=random.choice(['Full-Time', 'Part-Time', 'Freelance']),
                    requirements=req_skills,
                    benefits=benefits,
                    responsibilities=[fake.sentence() for _ in range(5)]
                )
                created_jobs += 1
            except Exception as e:
                print(f"Error creating job for {company.username}: {str(e)}")
                continue
    
    print(f"Created {created_jobs} new jobs")

if __name__ == '__main__':
    print("=== Starting test data generation ===")
    clear_existing_data()
    create_companies()
    create_users(200)
    create_jobs()
    print("=== Test data generation completed ===")