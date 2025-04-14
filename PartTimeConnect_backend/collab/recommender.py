import pandas as pd
from sklearn.neighbors import NearestNeighbors
from .models import JobInteraction
from jobs.models import Job


def get_recommendations_for_user(user_id, top_n=5, n_neighbors=5):
    # Récupération des interactions
    data = JobInteraction.objects.all()

    # Construction du DataFrame avec calcul du score global par interaction
    df = pd.DataFrame([{
        'user_id': i.user_id,
        'job_id': i.job_id,
        'score': (
            (i.nb_views * 0.5) +
            (i.time_spent / 30) +
            (5 if i.interaction_type == 'apply' else 0) +
            (i.rating if i.rating else 0)
        )
    } for i in data])

    # Vérifier que l'utilisateur existe et qu'il y a des données
    if df.empty or user_id not in df['user_id'].values:
        return []

    # Création de la matrice user-job
    user_job_matrix = df.pivot_table(index='user_id', columns='job_id', values='score').fillna(0)

    # Définition du modèle kNN
    model = NearestNeighbors(metric='cosine', algorithm='brute')

    model.fit(user_job_matrix)

    # Identifier la position de l'utilisateur
    user_index = list(user_job_matrix.index).index(user_id)

    # Adapter dynamiquement n_neighbors
    n_neighbors = min(n_neighbors + 1, len(user_job_matrix))

    distances, indices = model.kneighbors([user_job_matrix.iloc[user_index]], n_neighbors=n_neighbors)

    # Liste des users les plus proches sauf lui-même
    similar_user_ids = [user_job_matrix.index[i] for i in indices.flatten() if user_job_matrix.index[i] != user_id]

    # Jobs non vus par l'utilisateur
    user_ratings = user_job_matrix.loc[user_id]
    unseen_jobs = user_ratings[user_ratings == 0].index

    # Calcul des scores des jobs à recommander
    scores = {}
    for job_id in unseen_jobs:
        score = 0
        sim_total = 0
        for other_user in similar_user_ids:
            neighbor_score = user_job_matrix.loc[other_user, job_id]
            if neighbor_score > 0:
                sim_score = 1  # pondération simple
                score += sim_score * neighbor_score
                sim_total += sim_score
        if sim_total > 0:
            scores[job_id] = score / sim_total

    # Trier les jobs par score décroissant
    recommended_job_ids = sorted(scores, key=scores.get, reverse=True)[:top_n]

    # Retourner les jobs recommandés
    return Job.objects.filter(id__in=recommended_job_ids)
