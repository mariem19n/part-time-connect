import pandas as pd
from sklearn.metrics.pairwise import cosine_similarity
from .models import JobInteraction, Job

def get_recommendations_for_user(user_id, top_n=5):
    data = list(JobInteraction.objects.values('user_id', 'job_id', 'rating'))
    df = pd.DataFrame(data)

    if df.empty or user_id not in df['user_id'].values:
        return []

    user_job_matrix = df.pivot_table(index='user_id', columns='job_id', values='rating').fillna(0)

    similarity = cosine_similarity(user_job_matrix)
    similarity_df = pd.DataFrame(similarity, index=user_job_matrix.index, columns=user_job_matrix.index)

    similar_users = similarity_df[user_id].sort_values(ascending=False).drop(user_id).head(5)

    user_ratings = user_job_matrix.loc[user_id]
    unseen_jobs = user_ratings[user_ratings == 0].index

    scores = {}
    for job_id in unseen_jobs:
        score = 0
        sim_total = 0
        for other_user in similar_users.index:
            sim_score = similar_users[other_user]
            rating = user_job_matrix.loc[other_user, job_id]
            score += sim_score * rating
            sim_total += sim_score
        if sim_total > 0:
            scores[job_id] = score / sim_total

    recommended_job_ids = sorted(scores, key=scores.get, reverse=True)[:top_n]
    return Job.objects.filter(id__in=recommended_job_ids)
