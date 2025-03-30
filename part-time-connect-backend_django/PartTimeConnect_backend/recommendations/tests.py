import os
import django
from django.conf import settings

# Set up Django environment
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'PartTimeConnect_backend.settings')
django.setup()

from accounts.models import UserRegistration
from jobs.models import Job
from recommendations.services.recommender import RecommendationEngine

def test_recommendations():
    print("\n🔍 Starting Recommendation System Test...")
    
    # 1. Get test user (modify ID as needed)
    try:
        user = UserRegistration.objects.get(id=8)
        print(f"✅ Loaded user: {user.username}")
    except UserRegistration.DoesNotExist:
        print("❌ User not found")
        return

    # 2. Load jobs
    jobs = list(Job.objects.all()[:100])  # Test with first 100 jobs
    print(f"📊 Testing with {len(jobs)} jobs")

    # 3. Initialize engine
    engine = RecommendationEngine()
    
    # 4. Generate recommendations
    recommendations = engine.get_recommendations(user, jobs, top_k=5)
    
    # 5. Print results
    print("\n🎯 Recommendations:")
    for i, rec in enumerate(recommendations, 1):
        print(f"\n{i}. {rec['title']} (Score: {rec['score']:.2f})")
        print(f"   Company: {rec['company']}")
        print(f"   Summary: {rec['summary']}")
    
    print("\n✅ Test completed!")

if __name__ == "__main__":
    test_recommendations()