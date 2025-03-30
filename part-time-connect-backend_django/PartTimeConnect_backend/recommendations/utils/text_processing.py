import nltk
from nltk.corpus import stopwords
from nltk.stem import SnowballStemmer
import string
import re

nltk.download('stopwords')

def preprocess_text(text):
    stemmer = SnowballStemmer("english")
    stop_words = set(stopwords.words("english"))
    
    # Lowercase
    text = text.lower()
    # Remove punctuation
    text = re.sub(f'[{string.punctuation}]', '', text)
    # Tokenize
    tokens = nltk.word_tokenize(text)
    # Remove stopwords and stem
    processed = [stemmer.stem(w) for w in tokens if w not in stop_words]
    
    return ' '.join(processed)