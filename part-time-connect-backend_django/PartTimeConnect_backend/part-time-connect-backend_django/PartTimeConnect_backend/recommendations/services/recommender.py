import faiss
import numpy as np
import json
import re
import logging
import torch
import PyPDF2
import io
from typing import List, Dict, Optional
from sentence_transformers import SentenceTransformer
from transformers import pipeline, AutoTokenizer
from django.conf import settings
from jobs.models import Job

logger = logging.getLogger(__name__)

class ResumeParser:
    """PDF text extraction with basic text processing"""
    def __init__(self):
        self.min_word_length = 3
        self.stop_words = {
            'a', 'an', 'the', 'and', 'or', 'but', 'is', 'are', 'be', 'to',
            'of', 'in', 'for', 'on', 'that', 'by', 'this', 'with', 'you', 'it',
            'as', 'at', 'from', 'have', 'not', 'they', 'we', 'your', 'can', 'will'
        }

    def extract_text_from_pdf(self, pdf_content: bytes) -> str:
        try:
            reader = PyPDF2.PdfReader(io.BytesIO(pdf_content))
            text = []
            for page in reader.pages:
                page_text = page.extract_text()
                if page_text:
                # Preserve line breaks and bullet points
                    text.append(page_text.replace('\n', ' ').replace('•', '-'))
            return ' '.join(text)
        except Exception as e:
            logger.error(f"PDF extraction failed: {str(e)}")
        return ""

    def clean_text(self, text: str) -> str:
        """Basic text cleaning without NLTK"""
        text = re.sub(r'[^\w\s]', '', text.lower())
        text = re.sub(r'\s+', ' ', text).strip()
        words = [
            word for word in text.split()
            if len(word) >= self.min_word_length and word not in self.stop_words
        ]
        return ' '.join(words)

class RecommendationEngine:
    def __init__(self):
        self.device = 'cuda' if self._has_gpu() else 'cpu'
        self.embedding_model = None
        self.llm = None
        self.tokenizer = None
        self.resume_parser = ResumeParser()
        self.index = None
        self.job_ids = []
        self._initialize_models()

    def _has_gpu(self) -> bool:
        """Check GPU availability safely"""
        if not getattr(settings, 'USE_GPU', False):
            return False
        try:
            return torch.cuda.is_available()
        except RuntimeError:
            return False

    def _initialize_models(self):
        """Initialize models with proper configuration"""
        try:
            # Initialize embedding model
            self.embedding_model = SentenceTransformer(
                'sentence-transformers/all-mpnet-base-v2',
                device=self.device
            )
            
            # Initialize text-to-text generation pipeline for T5
            self.llm = pipeline(
                "text2text-generation",
                model="google/flan-t5-base",
                device=0 if self.device == 'cuda' else -1,
                max_length=150,
                temperature=0.7
            )
            
            self.tokenizer = AutoTokenizer.from_pretrained("google/flan-t5-base")
            
        except Exception as e:
            logger.error(f"Model initialization failed: {str(e)}")
            raise

    def _process_resumes(self, user_profile) -> str:
        """Process resume content from user profile"""
        if not user_profile.resumes:
            return ""
            
        try:
            resume_paths = json.loads(user_profile.resumes)
            content = []
            for path in resume_paths:
                try:
                    with open(path, 'rb') as f:
                        raw_text = self.resume_parser.extract_text_from_pdf(f.read())
                        content.append(self.resume_parser.clean_text(raw_text))
                except (IOError, json.JSONDecodeError) as e:
                    logger.warning(f"Resume read error: {str(e)}")
            return ' '.join(content)[:2000]  # Truncate long resumes
        except json.JSONDecodeError:
            return ""

    def create_user_text(self, user_profile) -> str:
        """Generate comprehensive user profile text"""
        parts = []
        
        if user_profile.skills:
            skills = user_profile.skills.split(',')[:20]
            parts.append(f"Skills: {', '.join(skills)}")
        
        resume_content = self._process_resumes(user_profile)
        if resume_content:
            parts.append(f"cv informations: {resume_content}")
            
        return '\n'.join(parts) or "No profile information"

    def create_job_text(self, job) -> str:
        """Generate standardized job description text"""
        components = [
            f"Title: {job.title}",
            f"Company: {job.company.username}",
            f"Location: {job.location}",
            f"Type: {job.contract_type}",
            f"Requirements: {', '.join(job.requirements[:10]) if job.requirements else 'None'}",
            f"Description: {job.description[:1000]}"
        ]
        return '\n'.join(components)

    def build_index(self, jobs: List[Job]) -> None:
        """Build and update FAISS index"""
        job_texts = [self.create_job_text(job) for job in jobs]
        
        # Generate embeddings and convert to numpy array
        embeddings = self.embedding_model.encode(job_texts, convert_to_tensor=True)
        embeddings = embeddings.cpu().numpy().astype('float32')
        
        # Create/update FAISS index
        dimension = embeddings.shape[1]
        self.index = faiss.IndexFlatL2(dimension)
        self.index.add(embeddings)
        self.job_ids = [job.id for job in jobs]

    def get_recommendations(self, user_profile, jobs: List[Job], top_k: int = 5) -> List[Dict]:
        """Generate personalized job recommendations"""
        if not jobs:
            return []
            
        # Rebuild index if jobs changed
        current_ids = {j.id for j in jobs}
        if not self.index or set(self.job_ids) != current_ids:
            self.build_index(jobs)
            
        # Process user profile
        user_text = self.create_user_text(user_profile)
        user_embedding = self.embedding_model.encode([user_text], convert_to_tensor=True)
        user_embedding = user_embedding.cpu().numpy().astype('float32')
        
        # Search index
        actual_k = min(top_k, len(jobs))
        distances, indices = self.index.search(user_embedding, actual_k)
        
        # Compile results
        results = []
        for idx, score in zip(indices[0], 1 - distances[0]/2):
            try:
                job = next(j for j in jobs if j.id == self.job_ids[idx])
                results.append({
                    'job_id': job.id,
                    'score': float(score),
                    'title': job.title,
                    'company': job.company.username,
                    'summary': self._generate_summary(user_text, self.create_job_text(job))
                })
            except (StopIteration, IndexError):
                continue
                
        return sorted(results, key=lambda x: x['score'], reverse=True)[:top_k]

    def _generate_summary(self, user_text: str, job_text: str) -> str:
        """Generate LLM-powered match explanation"""
        prompt = f"""
        [INST] Analyze candidate-job match focusing on:
        1. Technical Skills Match (Be specific: Python vs Django vs Pandas)
        2. Experience Alignment (Years, Industry, Achievements)
        3. Culture/Logistics Fit (Remote, Benefits, Growth)
    
        Candidate: {user_text[:400]}
        Job: {job_text[:400]}
    
        Use markdown bullet points. No generic statements. 
        If no match, state "No clear match found". [/INST]
        """

    # Rest of the generation code...
        
        try:
            # Tokenize and truncate if necessary
            inputs = self.tokenizer(
                prompt,
                return_tensors='pt',
                max_length=512,
                truncation=True
            )
            
            # Generate summary
            output = self.llm(
                prompt,
                max_length=150,
                num_return_sequences=1,
                temperature=0.5
            )
            return output[0]['generated_text'].strip()
            
        except Exception as e:
            logger.error(f"Summary generation failed: {str(e)}")
            return "Match details unavailable"
    