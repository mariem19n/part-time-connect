import pandas as pd
from sklearn.neighbors import NearestNeighbors
from .models import JobInteraction, Job


def get_recommendations_for_user(user_id, top_n=5, n_neighbors=5):
    data = list(JobInteraction.objects.values('user_id', 'job_id', 'rating'))
    df = pd.DataFrame(data)


    if df.empty or user_id not in df['user_id'].values:
        return []


    # Build user-job matrix
    user_job_matrix = df.pivot_table(index='user_id', columns='job_id', values='rating').fillna(0)


    # Fit k-NN model
    model = NearestNeighbors(metric='cosine', algorithm='brute')
    model.fit(user_job_matrix)


    # Get index of the user in the matrix
    user_index = list(user_job_matrix.index).index(user_id)


    # Find nearest neighbors (excluding the user itself)
    distances, indices = model.kneighbors([user_job_matrix.iloc[user_index]], n_neighbors=n_neighbors + 1)


    similar_user_ids = [
        user_job_matrix.index[i]
        for i in indices.flatten()
        if user_job_matrix.index[i] != user_id
    ]


    # Get jobs the user hasn't seen
    user_ratings = user_job_matrix.loc[user_id]
    unseen_jobs = user_ratings[user_ratings == 0].index


    # Compute weighted average rating for each unseen job
    scores = {}
    for job_id in unseen_jobs:
        score = 0
        sim_total = 0
        for neighbor_id in similar_user_ids:
            neighbor_rating = user_job_matrix.loc[neighbor_id, job_id]
            if neighbor_rating > 0:
                # similarity = 1 - distance
                sim_score = 1 - cosine_distance(user_job_matrix.loc[user_id], user_job_matrix.loc[neighbor_id])
                score += sim_score * neighbor_rating
                sim_total += sim_score
        if sim_total > 0:
            scores[job_id] = score / sim_total


    recommended_job_ids = sorted(scores, key=scores.get, reverse=True)[:top_n]
    return Job.objects.filter(id__in=recommended_job_ids)




# helper function to calculate cosine distance manually
from sklearn.metrics.pairwise import cosine_distances
def cosine_distance(u, v):
    return cosine_distances([u], [v])[0][0]



