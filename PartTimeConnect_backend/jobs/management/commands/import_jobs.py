# jobs/management/commands/import_jobs.py
import csv
import os
import random
from django.core.management.base import BaseCommand
from django.contrib.auth.hashers import make_password
from accounts.models import CompanyRegistration
from jobs.models import Job

class Command(BaseCommand):
    help = 'Import job data from CSV'

    def handle(self, *args, **options):
        current_dir = os.path.dirname(os.path.abspath(__file__))
        csv_file = os.path.join(current_dir, 'pcd_data.csv')
        
        CONTRACT_TYPES = ['Full-Time', 'Part-Time', 'Freelance', 'Internship']
        REQUIREMENTS = [
            ['1+ years experience', 'Relevant degree'],
            ['2+ years experience', 'Portfolio required'],
            ['3+ years experience', 'Certification preferred'],
            ['5+ years experience', 'Management experience']
        ]
        BENEFITS = [
            ['Health insurance', 'Paid time off'],
            ['Flexible schedule', 'Remote work options'],
            ['Dental coverage', 'Vision coverage', '401(k) matching'],
            ['Stock options', 'Company events']
        ]
        RESPONSIBILITIES = [
            ['Manage team projects', 'Coordinate with stakeholders'],
            ['Develop new features', 'Maintain existing codebase'],
            ['Analyze data', 'Create reports'],
            ['Meet sales targets', 'Build client relationships']
        ]
        WORKING_HOURS = [
            "9am-5pm",
            "Flexible hours",
            "20-30 hours/week",
            "Shift work",
            "Weekend availability required"
        ]

        try:
            with open(csv_file, 'r', encoding='utf-8') as file:
                reader = csv.DictReader(file)
                companies_created = set()  # Track created companies
                
                for i, row in enumerate(reader):
                    # Generate unique email for each company
                    company_email = f"company_{i}@example.com"
                    
                    company, created = CompanyRegistration.objects.get_or_create(
                        username=row['company'],
                        defaults={
                            'email': company_email,
                            'password': make_password('defaultpassword'),
                            'jobtype': 'Various',
                            'company_description': f"Description for {row['company']}",
                            'user_type': 'JobProvider'
                        }
                    )
                    
                    if created:
                        companies_created.add(company.username)
                    
                    contract_type = random.choice(CONTRACT_TYPES)
                    duration = random.randint(3, 12) if contract_type != 'Full-Time' else random.randint(12, 60)
                    salary = random.randint(15, 50) * 1000 if contract_type == 'Full-Time' else random.randint(10, 30) * 100
                    
                    Job.objects.create(
                        company=company,
                        title=row['Job Title'],
                        description=row['description'],
                        location=row['location'],
                        contract_type=contract_type,
                        requirements=random.choice(REQUIREMENTS),
                        benefits=random.choice(BENEFITS),
                        responsibilities=random.choice(RESPONSIBILITIES),
                        duration=duration,
                        salary=salary,
                        working_hours=random.choice(WORKING_HOURS),
                        is_salary_negotiable=random.choice([True, False])
                    )
                    
            self.stdout.write(self.style.SUCCESS(
                f'Successfully imported job data. Created {len(companies_created)} companies.'
            ))
        except FileNotFoundError:
            self.stdout.write(self.style.ERROR(f'CSV file not found at: {csv_file}'))
        except Exception as e:
            self.stdout.write(self.style.ERROR(f'Error importing data: {str(e)}'))