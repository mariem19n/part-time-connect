import faiss
import numpy as np
import json
import re
import logging
import torch
import PyPDF2
import io
from typing import List, Dict, Optional, Tuple
from sentence_transformers import SentenceTransformer
from transformers import pipeline, AutoTokenizer, AutoModelForTokenClassification
from django.conf import settings
from jobs.models import Job
import os
from transformers import AutoConfig  # Nouvel import ajouté

logger = logging.getLogger(__name__)

class ResumeParser:
    """PDF text extraction with enhanced entity recognition for projects and experience"""
    def __init__(self):
        self.min_word_length = 3
        self.stop_words = {
            'a', 'an', 'the', 'and', 'or', 'but', 'is', 'are', 'be', 'to',
            'of', 'in', 'for', 'on', 'that', 'by', 'this', 'with', 'you', 'it'
        }
        
        # Initialize NER model with proper configuration
        self.ner_model = self._initialize_ner_model()

    def _initialize_ner_model(self):
        """Properly initialize the NER model with error handling"""
        try:
            from transformers import AutoTokenizer, AutoModelForTokenClassification, pipeline
            import torch
            
            # Load model with correct configuration
            model_name = "hiendang7613/xlmr-lstm-crf-resume-ner"
            tokenizer = AutoTokenizer.from_pretrained(model_name)
            
            # Load model with custom configuration to match the trained weights
            config = AutoConfig.from_pretrained(
                model_name,
                num_labels=40,
                hidden_size=512  # Important: matches the model's expected size
            )
            
            model = AutoModelForTokenClassification.from_pretrained(
                model_name,
                config=config,
                ignore_mismatched_sizes=True
            )
            
            # Create pipeline with proper settings
            return pipeline(
                "token-classification",
                model=model,
                tokenizer=tokenizer,
                aggregation_strategy="simple",
                device=0 if torch.cuda.is_available() else -1
            )
        except Exception as e:
            print(f"Failed to initialize NER model: {str(e)}")
            return None

    def extract_entities(self, text: str) -> dict:
        """Enhanced entity extraction with text preprocessing"""
        if not self.ner_model:
            return {}
            
        try:
            # Preprocess text for better NER performance
            text = self._preprocess_for_ner(text)
            
            # Process in chunks if text is long
            chunk_size = 1000
            chunks = [text[i:i+chunk_size] for i in range(0, len(text), chunk_size)]
            
            entities = []
            for chunk in chunks:
                results = self.ner_model(chunk)
                entities.extend(results)
                
            # Organize entities by type
            organized = {
                "ORG": [],
                "DATE": [],
                "ROLE": [],
                "SKILL": [],
                "LOC": []
            }
            
            for entity in entities:
                entity_type = entity["entity_group"]
                word = entity["word"].strip()
                
                if entity_type in organized and word not in organized[entity_type]:
                    organized[entity_type].append(word)
                    
            return organized
            
        except Exception as e:
            print(f"Entity extraction failed: {str(e)}")
            return {}

    def _preprocess_for_ner(self, text: str) -> str:
        """Clean and format text for better NER performance"""
        # Fix common resume formatting issues
        text = re.sub(r'([a-z])([A-Z])', r'\1 \2', text)  # Add space between camelCase
        text = re.sub(r'(\d)([A-Za-z])', r'\1 \2', text)  # Separate numbers and letters
        text = re.sub(r'([A-Za-z])(\d)', r'\1 \2', text)
        
        # Normalize date formats
        text = re.sub(r'(\d{2})[/\-\.](\d{2})[/\-\.](\d{4})', r'\1/\2/\3', text)
        text = re.sub(r'(\d{4})[/\-\.](\d{2})[/\-\.](\d{2})', r'\1/\2/\3', text)
        
        return text

    def extract_sections(self, text: str) -> Dict[str, str]:
        """Improved section extraction using NER and patterns"""
        sections = {}
        
        # First try pattern-based extraction
        sections.update(self._extract_with_patterns(text))
        
        # Enhance with NER if available
        if self.ner_model:
            entities = self.extract_entities(text)
            
            # Find experience sections containing organizations and dates
            if not sections.get("experience"):
                exp_paragraphs = self._find_paragraphs_with_entities(
                    text, 
                    entities["ORG"], 
                    entities["DATE"]
                )
                if exp_paragraphs:
                    sections["experience"] = "\n\n".join(exp_paragraphs)
            
            # Find project sections containing skills and dates
            if not sections.get("projects"):
                proj_paragraphs = self._find_paragraphs_with_entities(
                    text,
                    entities["SKILL"],
                    entities["DATE"]
                )
                if proj_paragraphs:
                    sections["projects"] = "\n\n".join(proj_paragraphs)
                    
        return sections

    def _find_paragraphs_with_entities(self, text: str, entities1: list, entities2: list) -> list:
        """Find paragraphs containing both types of entities"""
        paragraphs = re.split(r'\n\s*\n', text)
        relevant = []
        
        for para in paragraphs:
            has_entity1 = any(e.lower() in para.lower() for e in entities1)
            has_entity2 = any(e.lower() in para.lower() for e in entities2)
            
            if has_entity1 and has_entity2:
                relevant.append(para)
                
        return relevant

    # ... (keep your existing PDF extraction and other methods) ...
    
    def _extract_by_date_patterns(self, text: str, sections: Dict[str, str]):
        """Extract sections based on date patterns and formatting"""
        # Common date patterns in resumes (MM/YYYY, Month YYYY, YYYY-Present, etc.)
        date_patterns = [
            r'\b(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)[a-z]* \d{4}\s*-\s*(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)[a-z]* \d{4}',
            r'\b(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)[a-z]* \d{4}\s*-\s*(present|current|now)',
            r'\b\d{1,2}/\d{4}\s*-\s*\d{1,2}/\d{4}',
            r'\b\d{1,2}/\d{4}\s*-\s*(present|current|now)',
            r'\b\d{4}\s*-\s*\d{4}',
            r'\b\d{4}\s*-\s*(present|current|now)'
        ]
        
        # Split text into paragraphs
        paragraphs = re.split(r'\n\s*\n', text)
        exp_paragraphs = []
        proj_paragraphs = []
        
        for paragraph in paragraphs:
            # Look for date patterns that suggest work experience
            has_date = any(re.search(pattern, paragraph, re.IGNORECASE) for pattern in date_patterns)
            
            if has_date:
                # Check for project-related keywords
                project_keywords = ['project', 'developed', 'created', 'built', 'designed', 'implemented']
                if any(keyword in paragraph.lower() for keyword in project_keywords):
                    proj_paragraphs.append(paragraph)
                # Check for experience-related keywords
                exp_keywords = ['company', 'position', 'role', 'responsible', 'manager', 'team', 'client']
                if any(keyword in paragraph.lower() for keyword in exp_keywords):
                    exp_paragraphs.append(paragraph)
                # If no specific keywords, default to experience if it has dates
                elif not any(keyword in paragraph.lower() for keyword in project_keywords):
                    exp_paragraphs.append(paragraph)
        
        # Add extracted content if not already found
        if exp_paragraphs and not sections.get("experience"):
            sections["experience"] = "\n\n".join(exp_paragraphs)
        
        if proj_paragraphs and not sections.get("projects"):
            sections["projects"] = "\n\n".join(proj_paragraphs)
    
    def _extract_by_content_patterns(self, text: str, sections: Dict[str, str]):
        """Extract sections based on content patterns like bullet points and keywords"""
        # Look for bullet point lists which are common in resumes
        bullet_patterns = [
            r'(?:\n|\s)[-•*]\s+[A-Z]',  # Common bullet points starting with capital letter
            r'(?:\n|\s)[\d]+\.\s+[A-Z]'  # Numbered lists starting with capital letter
        ]
        
        # Project-related keyword patterns
        project_indicators = [
            r'\b(?:developed|created|built|designed|implemented|architected)\b.*?\b(?:app|application|system|website|platform|tool|solution)\b',
            r'\bproject\b.*?\b(?:goal|objective|aim|purpose)\b',
            r'\b(?:github|gitlab|repository|repo)\b'
        ]
        
        # Experience-related keyword patterns
        experience_indicators = [
            r'\b(?:responsible for|managed|led|supervised|coordinated)\b',
            r'\b(?:company|organization|firm|employer|client)\b',
            r'\b(?:team|department|group|division)\b',
            r'\b(?:position|role|job|title)\b'
        ]
        
        # Try to identify content by analyzing bullet point blocks
        bullet_blocks = []
        for pattern in bullet_patterns:
            # Find all matches of bullet points
            bullet_matches = list(re.finditer(pattern, text, re.MULTILINE))
            
            # Group bullet points into blocks
            for i in range(len(bullet_matches)):
                start_pos = bullet_matches[i].start()
                end_pos = len(text)
                if i < len(bullet_matches) - 1:
                    end_pos = bullet_matches[i + 1].start()
                bullet_blocks.append(text[start_pos:end_pos])
        
        # Categorize bullet blocks as experience or projects
        exp_blocks = []
        proj_blocks = []
        
        for block in bullet_blocks:
            is_project = any(re.search(pattern, block, re.IGNORECASE) for pattern in project_indicators)
            is_experience = any(re.search(pattern, block, re.IGNORECASE) for pattern in experience_indicators)
            
            if is_project and not is_experience:
                proj_blocks.append(block)
            elif is_experience or not is_project:  # Default to experience if not clearly a project
                exp_blocks.append(block)
        
        # Add extracted content if not already found
        if exp_blocks and not sections.get("experience"):
            sections["experience"] = "\n\n".join(exp_blocks)
        
        if proj_blocks and not sections.get("projects"):
            sections["projects"] = "\n\n".join(proj_blocks)
    
    def _enhance_with_ner(self, text: str, sections: Dict[str, str]):
        """Use NER to identify organizations, dates, and job titles to enhance extraction"""
        try:
            # Process chunks to avoid token limits
            chunk_size = 500
            chunks = [text[i:i+chunk_size] for i in range(0, len(text), chunk_size)]
            
            all_entities = []
            for chunk in chunks:
                entities = self.ner_model(chunk)
                all_entities.extend(entities)
            
            # Extract company names, dates, and job titles
            organizations = []
            dates = []
            roles = []  # For potential job titles (PERSON can sometimes capture job titles)
            
            for entity in all_entities:
                if entity["entity_group"] == "ORG":
                    organizations.append(entity["word"])
                elif entity["entity_group"] == "DATE":
                    dates.append(entity["word"])
                elif entity["entity_group"] == "PER":
                    # Only consider short mentions as potential job titles (not full names)
                    if len(entity["word"].split()) <= 2:
                        roles.append(entity["word"])
            
            # Find paragraphs containing these entities
            paragraphs = re.split(r'\n\s*\n', text)
            
            if not sections.get("experience"):
                exp_paragraphs = []
                for paragraph in paragraphs:
                    # Experience typically has organization and date
                    has_org = any(org.lower() in paragraph.lower() for org in organizations)
                    has_date = any(date.lower() in paragraph.lower() for date in dates)
                    if has_org and has_date:
                        exp_paragraphs.append(paragraph)
                
                if exp_paragraphs:
                    sections["experience"] = "\n\n".join(exp_paragraphs)
            
            if not sections.get("projects"):
                # Projects typically have technical terms but might not have organizations
                proj_paragraphs = []
                tech_terms = ['developed', 'created', 'built', 'designed', 'project', 'implementation']
                
                for paragraph in paragraphs:
                    has_tech = any(term.lower() in paragraph.lower() for term in tech_terms)
                    has_date = any(date.lower() in paragraph.lower() for date in dates)
                    not_in_exp = paragraph not in sections.get("experience", "")
                    
                    if has_tech and has_date and not_in_exp:
                        proj_paragraphs.append(paragraph)
                
                if proj_paragraphs:
                    sections["projects"] = "\n\n".join(proj_paragraphs)
            
        except Exception as e:
            logger.warning(f"NER enhancement failed: {str(e)}")

class HybridSearchEngine:
    """Hybrid search combining semantic and keyword matching"""
    def __init__(self, embedding_model):
        self.embedding_model = embedding_model
        self.index = None
        self.documents = []
        self.keywords_index = {}  # For keyword search component
    
    def index_documents(self, documents: List[Dict[str, str]], job_ids: List[int]):
        """Create both semantic and keyword indices"""
        if not documents:
            return
            
        # Generate embeddings for semantic search
        text_documents = [doc["text"] for doc in documents]
        embeddings = self.embedding_model.encode(text_documents, convert_to_tensor=True)
        embeddings = embeddings.cpu().numpy().astype('float32')
        
        # Create FAISS index
        dimension = embeddings.shape[1]
        self.index = faiss.IndexFlatL2(dimension)
        self.index.add(embeddings)
        
        # Store documents
        self.documents = documents
        
        # Build keyword index
        self._build_keyword_index(documents, job_ids)
    
    def _build_keyword_index(self, documents: List[Dict[str, str]], job_ids: List[int]):
        """Build inverted index for keyword search"""
        self.keywords_index = {}
        
        for i, (doc, job_id) in enumerate(zip(documents, job_ids)):
            # Extract keywords (unique terms)
            text = doc["text"].lower()
            # Remove punctuation and split into words
            words = re.sub(r'[^\w\s]', ' ', text).split()
            # Remove duplicates and short words
            unique_words = set([w for w in words if len(w) > 3])
            
            # Add to inverted index
            for word in unique_words:
                if word not in self.keywords_index:
                    self.keywords_index[word] = []
                self.keywords_index[word].append((i, job_id))
    
    def search(self, query: str, top_k: int = 5) -> List[Tuple[int, float]]:
        """Perform hybrid search combining semantic and keyword results"""
        if not self.index or not self.documents:
            return []
        
        # Semantic search
        query_embedding = self.embedding_model.encode([query], convert_to_tensor=True)
        query_embedding = query_embedding.cpu().numpy().astype('float32')
        
        # Search index
        distances, indices = self.index.search(query_embedding, top_k)
        semantic_results = [(idx, float(1 - dist/2)) for idx, dist in zip(indices[0], distances[0])]
        
        # Keyword search
        keyword_results = self._keyword_search(query, top_k)
        
        # Combine results (simple approach - could be improved)
        combined_results = {}
        
        # Add semantic results with weight 0.7
        for idx, score in semantic_results:
            if idx < len(self.documents):
                combined_results[idx] = score * 0.7
        
        # Add keyword results with weight 0.3
        for idx, score in keyword_results:
            if idx in combined_results:
                combined_results[idx] += score * 0.3
            else:
                combined_results[idx] = score * 0.3
        
        # Sort by score
        sorted_results = sorted(combined_results.items(), key=lambda x: x[1], reverse=True)
        return sorted_results[:top_k]
    
    def _keyword_search(self, query: str, top_k: int) -> List[Tuple[int, float]]:
        """Perform keyword search"""
        # Clean and tokenize query
        query = query.lower()
        query_words = re.sub(r'[^\w\s]', ' ', query).split()
        query_words = [w for w in query_words if len(w) > 3]
        
        # Count matches for each document
        doc_matches = {}
        
        for word in query_words:
            if word in self.keywords_index:
                for doc_idx, _ in self.keywords_index[word]:
                    if doc_idx not in doc_matches:
                        doc_matches[doc_idx] = 0
                    doc_matches[doc_idx] += 1
        
        # Calculate scores based on match count and query length
        results = []
        query_len = max(1, len(query_words))
        
        for doc_idx, match_count in doc_matches.items():
            score = match_count / query_len
            results.append((doc_idx, score))
        
        # Sort by score
        results.sort(key=lambda x: x[1], reverse=True)
        return results[:top_k]


class RecommendationEngine:
    def __init__(self):
        self.device = 'cuda' if self._has_gpu() else 'cpu'
        self.embedding_model = None
        self.llm = None
        self.tokenizer = None
        self.resume_parser = ResumeParser()
        self.search_engine = None
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
        """Initialize with Inference API"""
        try:
            from huggingface_hub import InferenceClient
        
            hf_token = os.getenv('HF_API_TOKEN')
            if not hf_token:
                raise ValueError("HF_API_TOKEN environment variable not set")
        
            self.embedding_model = SentenceTransformer(
                'sentence-transformers/all-mpnet-base-v2',
                device=self.device
            )  
        
            # Initialize client for Inference API
            self.hf_client = InferenceClient(
                model="mistralai/Mistral-7B-Instruct-v0.1",
                token=hf_token
            )
        
            self.search_engine = HybridSearchEngine(self.embedding_model)
        
        except Exception as e:
            logger.error(f"Model initialization failed: {str(e)}")
            raise

    def _process_resumes(self, user_profile) -> Dict[str, str]:
        """Process resume content from user profile, extracting specific sections"""
        if not user_profile.resumes:
            return {"experience": "", "projects": ""}
            
        try:
            resume_paths = json.loads(user_profile.resumes)
            # resume_paths = [path.replace('resumes/', 'media/resumes/') for path in resume_paths]
            extracted_sections = {"experience": [], "projects": []}
            
            for rel_path in resume_paths:
                abs_path = os.path.join(settings.MEDIA_ROOT, rel_path.replace('\\', '/'))

                if not os.path.exists(abs_path):
                    logger.warning(f"Resume file not found at: {abs_path}")
                    continue  # Skip this resume
                try:
                    with open(abs_path, 'rb') as f:
                        raw_text = self.resume_parser.extract_text_from_pdf(f.read())
                        sections = self.resume_parser.extract_sections(raw_text)
                        
                        if "experience" in sections:
                            extracted_sections["experience"].append(
                                self.resume_parser.clean_text(sections["experience"])
                            )
                        
                        if "projects" in sections:
                            extracted_sections["projects"].append(
                                self.resume_parser.clean_text(sections["projects"])
                            )
                            
                except (IOError, json.JSONDecodeError) as e:
                    logger.warning(f"Resume read error: {str(e)}")
            
            # Combine and truncate sections
            result = {
                "experience": " ".join(extracted_sections["experience"])[:1500],
                "projects": " ".join(extracted_sections["projects"])[:1500]
            }
            
            return result
            
        except json.JSONDecodeError:
            return {"experience": "", "projects": ""}

    def create_user_text(self, user_profile) -> str:
        """Generate comprehensive user profile text with focused sections"""
        parts = []
        
        if user_profile.skills:
            skills = user_profile.skills.split(',')[:20]
            parts.append(f"Skills: {', '.join(skills)}")
        
        resume_sections = self._process_resumes(user_profile)
        
        if resume_sections["experience"]:
            parts.append(f"Experience: {resume_sections['experience']}")
            
        if resume_sections["projects"]:
            parts.append(f"Projects: {resume_sections['projects']}")
            
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
        """Build hybrid search index"""
        job_documents = []
        job_ids = []
        
        for job in jobs:
            job_text = self.create_job_text(job)
            job_documents.append({"text": job_text})
            job_ids.append(job.id)
        
        # Index documents using hybrid search
        self.search_engine.index_documents(job_documents, job_ids)
        self.job_ids = job_ids

    def get_recommendations(self, user_profile, jobs: List[Job], top_k: int = 5) -> List[Dict]:
        """Generate personalized job recommendations using hybrid search"""
        if not jobs:
            return []
            
        # Rebuild index if jobs changed
        current_ids = {j.id for j in jobs}
        if not self.search_engine.index or set(self.job_ids) != current_ids:
            self.build_index(jobs)
            
        # Process user profile
        user_text = self.create_user_text(user_profile)
        
        # Perform hybrid search
        search_results = self.search_engine.search(user_text, top_k)
        
        # Compile results
        results = []
        for idx, score in search_results:
            try:
                job_id = self.job_ids[idx]
                job = next(j for j in jobs if j.id == job_id)
                
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
        """Generate LLM-powered match explanation with specific focus"""
        prompt = f"""
            [INST] Analyze candidate-job match with these guidelines:

            Analysis Framework:
            1. **Core Skills Match**: Compare exact technical skills, tools, and methodologies
            2. **Industry Alignment**: Verify domain expertise and sector-specific knowledge
            3. **Experience Level**: Compare years, role seniority, and relevant achievements
            4. **Location Compatibility**: Check onsite/hybrid/remote alignment and relocation potential
            5. **Career Progression**: Analyze if role represents appropriate growth opportunity

            Output Format Requirements:
            - Begin with overall match percentage estimate (e.g., "Overall Match: ~75%")
            - Use specific evidence from both profiles
            - For each category:
                ✅ Strong Match: [concrete example from both profiles]
                ⚠️ Potential Concern: [specific discrepancy with context]
                ❌ Mismatch: [fundamental incompatibility with explanation]
            - Conclude with hiring recommendation

            Examples:
            Good Match:
            "Overall Match: ~85%
            - ✅ Strong Match: Candidate's 5 years with React matches job's frontend requirements
            - ✅ Strong Match: Both have fintech industry experience (Candidate: 3 years at PayPal)
            - ⚠️ Potential Concern: Job requires Python but candidate only lists basic knowledge"

            Poor Match:
            "Overall Match: ~40%
            - ❌ Mismatch: Job requires onsite in NYC but candidate seeks remote work
            - ❌ Mismatch: Senior Director role requires 10+ years, candidate has 6
            - � Potential Concern: Partial skill match (5/8 required technologies)"

            Candidate Profile:
            {user_text[:500]}

            Job Details:
            {job_text[:500]}

            Provide detailed analysis following exactly the above format.
            [/INST]
            """

        response = self.hf_client.text_generation(
            prompt,
            max_new_tokens=400,
            temperature=0.5,    
            do_sample=False     
        )
        return response


# class ResumeParser:
#     """PDF text extraction with enhanced entity recognition for projects and experience"""
#     def __init__(self):
#         self.min_word_length = 3
#         self.stop_words = {
#             'a', 'an', 'the', 'and', 'or', 'but', 'is', 'are', 'be', 'to',
#             'of', 'in', 'for', 'on', 'that', 'by', 'this', 'with', 'you', 'it',
#             'as', 'at', 'from', 'have', 'not', 'they', 'we', 'your', 'can', 'will'
#         }
#         # Initialize NER model for extracting entities
#         try:
#             self.ner_model = pipeline(
#                 "token-classification", 
#                 model="dslim/bert-base-NER", 
#                 aggregation_strategy="simple"
#             )
#         except Exception as e:
#             logger.error(f"NER model initialization failed: {str(e)}")
#             self.ner_model = None

#     def extract_text_from_pdf(self, pdf_content: bytes) -> str:
#         try:
#             reader = PyPDF2.PdfReader(io.BytesIO(pdf_content))
#             text = []
#             for page in reader.pages:
#                 page_text = page.extract_text()
#                 if page_text:
#                     # Preserve line breaks for section detection
#                     text.append(page_text)
#             return '\n'.join(text)
#         except Exception as e:
#             logger.error(f"PDF extraction failed: {str(e)}")
#         return ""

#     def clean_text(self, text: str) -> str:
#         """Basic text cleaning without NLTK"""
#         text = re.sub(r'[^\w\s]', ' ', text.lower())
#         text = re.sub(r'\s+', ' ', text).strip()
#         words = [
#             word for word in text.split()
#             if len(word) >= self.min_word_length and word not in self.stop_words
#         ]
#         return ' '.join(words)
    
#     def extract_sections(self, text: str) -> Dict[str, str]:
#         """Extract experience and project sections from resume text with improved techniques"""
#         sections = {}
        
#         # Expanded patterns for section headers
#         experience_patterns = [
#             r'(?i)(?:\n|\s|^)(work experience|professional experience|employment|experience)(?:\n|\s|:)',
#             r'(?i)(?:\n|\s|^)(career history|work history|employment history)(?:\n|\s|:)',
#             r'(?i)(?:\n|\s|^)(professional background|job history)(?:\n|\s|:)'
#         ]
        
#         project_patterns = [
#             r'(?i)(?:\n|\s|^)(projects|project experience|key projects|personal projects)(?:\n|\s|:)',
#             r'(?i)(?:\n|\s|^)(academic projects|professional projects|technical projects)(?:\n|\s|:)',
#             r'(?i)(?:\n|\s|^)(portfolio|case studies|applications developed)(?:\n|\s|:)'
#         ]
        
#         # More comprehensive list of other sections for better boundary detection
#         other_sections = [
#             r'(?i)(?:\n|\s|^)(education|academic background|qualifications)(?:\n|\s|:)',
#             r'(?i)(?:\n|\s|^)(skills|technical skills|core competencies|technologies)(?:\n|\s|:)',
#             r'(?i)(?:\n|\s|^)(certifications|awards|achievements|honors)(?:\n|\s|:)',
#             r'(?i)(?:\n|\s|^)(languages|interests|hobbies|activities)(?:\n|\s|:)',
#             r'(?i)(?:\n|\s|^)(references|publications|volunteer|about me|summary|profile)(?:\n|\s|:)',
#             r'(?i)(?:\n|\s|^)(contact information|personal details|additional information)(?:\n|\s|:)'
#         ]
        
#         # Identify the start of each section
#         section_markers = []
        
#         # Add experience patterns with section type
#         for pattern in experience_patterns:
#             for match in re.finditer(pattern, text):
#                 section_markers.append((match.start(), "experience"))
                
#         # Add project patterns with section type
#         for pattern in project_patterns:
#             for match in re.finditer(pattern, text):
#                 section_markers.append((match.start(), "projects"))
        
#         # Add other sections for boundary detection
#         for pattern in other_sections:
#             for match in re.finditer(pattern, text):
#                 section_markers.append((match.start(), "other"))
        
#         # Sort markers by position
#         section_markers.sort(key=lambda x: x[0])
        
#         # Extract content between markers
#         for i, (start_pos, section_type) in enumerate(section_markers):
#             if section_type in ["experience", "projects"]:
#                 end_pos = len(text)
#                 if i < len(section_markers) - 1:
#                     end_pos = section_markers[i + 1][0]
                
#                 section_text = text[start_pos:end_pos].strip()
#                 # Remove the header from the content
#                 section_text = re.sub(r'^.*?(?:\n|\:)', '', section_text, 1).strip()
                
#                 sections[section_type] = section_text
        
#         # Fall back to alternative extraction methods if sections not found
#         if not sections.get("experience") or not sections.get("projects"):
#             # Try date-based paragraph analysis first
#             self._extract_by_date_patterns(text, sections)
            
#             # Then try NER if sections still missing
#             if self.ner_model and (not sections.get("experience") or not sections.get("projects")):
#                 self._enhance_with_ner(text, sections)
            
#             # Finally try bullet point and keyword analysis if still missing
#             if not sections.get("experience") or not sections.get("projects"):
#                 self._extract_by_content_patterns(text, sections)
        
#         return sections
    
#     def _extract_by_date_patterns(self, text: str, sections: Dict[str, str]):
#         """Extract sections based on date patterns and formatting"""
#         # Common date patterns in resumes (MM/YYYY, Month YYYY, YYYY-Present, etc.)
#         date_patterns = [
#             r'\b(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)[a-z]* \d{4}\s*-\s*(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)[a-z]* \d{4}',
#             r'\b(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)[a-z]* \d{4}\s*-\s*(present|current|now)',
#             r'\b\d{1,2}/\d{4}\s*-\s*\d{1,2}/\d{4}',
#             r'\b\d{1,2}/\d{4}\s*-\s*(present|current|now)',
#             r'\b\d{4}\s*-\s*\d{4}',
#             r'\b\d{4}\s*-\s*(present|current|now)'
#         ]
        
#         # Split text into paragraphs
#         paragraphs = re.split(r'\n\s*\n', text)
#         exp_paragraphs = []
#         proj_paragraphs = []
        
#         for paragraph in paragraphs:
#             # Look for date patterns that suggest work experience
#             has_date = any(re.search(pattern, paragraph, re.IGNORECASE) for pattern in date_patterns)
            
#             if has_date:
#                 # Check for project-related keywords
#                 project_keywords = ['project', 'developed', 'created', 'built', 'designed', 'implemented']
#                 if any(keyword in paragraph.lower() for keyword in project_keywords):
#                     proj_paragraphs.append(paragraph)
#                 # Check for experience-related keywords
#                 exp_keywords = ['company', 'position', 'role', 'responsible', 'manager', 'team', 'client']
#                 if any(keyword in paragraph.lower() for keyword in exp_keywords):
#                     exp_paragraphs.append(paragraph)
#                 # If no specific keywords, default to experience if it has dates
#                 elif not any(keyword in paragraph.lower() for keyword in project_keywords):
#                     exp_paragraphs.append(paragraph)
        
#         # Add extracted content if not already found
#         if exp_paragraphs and not sections.get("experience"):
#             sections["experience"] = "\n\n".join(exp_paragraphs)
        
#         if proj_paragraphs and not sections.get("projects"):
#             sections["projects"] = "\n\n".join(proj_paragraphs)
    
#     def _extract_by_content_patterns(self, text: str, sections: Dict[str, str]):
#         """Extract sections based on content patterns like bullet points and keywords"""
#         # Look for bullet point lists which are common in resumes
#         bullet_patterns = [
#             r'(?:\n|\s)[-•*]\s+[A-Z]',  # Common bullet points starting with capital letter
#             r'(?:\n|\s)[\d]+\.\s+[A-Z]'  # Numbered lists starting with capital letter
#         ]
        
#         # Project-related keyword patterns
#         project_indicators = [
#             r'\b(?:developed|created|built|designed|implemented|architected)\b.*?\b(?:app|application|system|website|platform|tool|solution)\b',
#             r'\bproject\b.*?\b(?:goal|objective|aim|purpose)\b',
#             r'\b(?:github|gitlab|repository|repo)\b'
#         ]
        
#         # Experience-related keyword patterns
#         experience_indicators = [
#             r'\b(?:responsible for|managed|led|supervised|coordinated)\b',
#             r'\b(?:company|organization|firm|employer|client)\b',
#             r'\b(?:team|department|group|division)\b',
#             r'\b(?:position|role|job|title)\b'
#         ]
        
#         # Try to identify content by analyzing bullet point blocks
#         bullet_blocks = []
#         for pattern in bullet_patterns:
#             # Find all matches of bullet points
#             bullet_matches = list(re.finditer(pattern, text, re.MULTILINE))
            
#             # Group bullet points into blocks
#             for i in range(len(bullet_matches)):
#                 start_pos = bullet_matches[i].start()
#                 end_pos = len(text)
#                 if i < len(bullet_matches) - 1:
#                     end_pos = bullet_matches[i + 1].start()
#                 bullet_blocks.append(text[start_pos:end_pos])
        
#         # Categorize bullet blocks as experience or projects
#         exp_blocks = []
#         proj_blocks = []
        
#         for block in bullet_blocks:
#             is_project = any(re.search(pattern, block, re.IGNORECASE) for pattern in project_indicators)
#             is_experience = any(re.search(pattern, block, re.IGNORECASE) for pattern in experience_indicators)
            
#             if is_project and not is_experience:
#                 proj_blocks.append(block)
#             elif is_experience or not is_project:  # Default to experience if not clearly a project
#                 exp_blocks.append(block)
        
#         # Add extracted content if not already found
#         if exp_blocks and not sections.get("experience"):
#             sections["experience"] = "\n\n".join(exp_blocks)
        
#         if proj_blocks and not sections.get("projects"):
#             sections["projects"] = "\n\n".join(proj_blocks)
    
#     def _enhance_with_ner(self, text: str, sections: Dict[str, str]):
#         """Use NER to identify organizations, dates, and job titles to enhance extraction"""
#         try:
#             # Process chunks to avoid token limits
#             chunk_size = 500
#             chunks = [text[i:i+chunk_size] for i in range(0, len(text), chunk_size)]
            
#             all_entities = []
#             for chunk in chunks:
#                 entities = self.ner_model(chunk)
#                 all_entities.extend(entities)
            
#             # Extract company names, dates, and job titles
#             organizations = []
#             dates = []
#             roles = []  # For potential job titles (PERSON can sometimes capture job titles)
            
#             for entity in all_entities:
#                 if entity["entity_group"] == "ORG":
#                     organizations.append(entity["word"])
#                 elif entity["entity_group"] == "DATE":
#                     dates.append(entity["word"])
#                 elif entity["entity_group"] == "PER":
#                     # Only consider short mentions as potential job titles (not full names)
#                     if len(entity["word"].split()) <= 2:
#                         roles.append(entity["word"])
            
#             # Find paragraphs containing these entities
#             paragraphs = re.split(r'\n\s*\n', text)
            
#             if not sections.get("experience"):
#                 exp_paragraphs = []
#                 for paragraph in paragraphs:
#                     # Experience typically has organization and date
#                     has_org = any(org.lower() in paragraph.lower() for org in organizations)
#                     has_date = any(date.lower() in paragraph.lower() for date in dates)
#                     if has_org and has_date:
#                         exp_paragraphs.append(paragraph)
                
#                 if exp_paragraphs:
#                     sections["experience"] = "\n\n".join(exp_paragraphs)
            
#             if not sections.get("projects"):
#                 # Projects typically have technical terms but might not have organizations
#                 proj_paragraphs = []
#                 tech_terms = ['developed', 'created', 'built', 'designed', 'project', 'implementation']
                
#                 for paragraph in paragraphs:
#                     has_tech = any(term.lower() in paragraph.lower() for term in tech_terms)
#                     has_date = any(date.lower() in paragraph.lower() for date in dates)
#                     not_in_exp = paragraph not in sections.get("experience", "")
                    
#                     if has_tech and has_date and not_in_exp:
#                         proj_paragraphs.append(paragraph)
                
#                 if proj_paragraphs:
#                     sections["projects"] = "\n\n".join(proj_paragraphs)
            
#         except Exception as e:
#             logger.warning(f"NER enhancement failed: {str(e)}")

# class HybridSearchEngine:
#     """Hybrid search combining semantic and keyword matching"""
#     def __init__(self, embedding_model):
#         self.embedding_model = embedding_model
#         self.index = None
#         self.documents = []
#         self.keywords_index = {}  # For keyword search component
    
#     def index_documents(self, documents: List[Dict[str, str]], job_ids: List[int]):
#         """Create both semantic and keyword indices"""
#         if not documents:
#             return
            
#         # Generate embeddings for semantic search
#         text_documents = [doc["text"] for doc in documents]
#         embeddings = self.embedding_model.encode(text_documents, convert_to_tensor=True)
#         embeddings = embeddings.cpu().numpy().astype('float32')
        
#         # Create FAISS index
#         dimension = embeddings.shape[1]
#         self.index = faiss.IndexFlatL2(dimension)
#         self.index.add(embeddings)
        
#         # Store documents
#         self.documents = documents
        
#         # Build keyword index
#         self._build_keyword_index(documents, job_ids)
    
#     def _build_keyword_index(self, documents: List[Dict[str, str]], job_ids: List[int]):
#         """Build inverted index for keyword search"""
#         self.keywords_index = {}
        
#         for i, (doc, job_id) in enumerate(zip(documents, job_ids)):
#             # Extract keywords (unique terms)
#             text = doc["text"].lower()
#             # Remove punctuation and split into words
#             words = re.sub(r'[^\w\s]', ' ', text).split()
#             # Remove duplicates and short words
#             unique_words = set([w for w in words if len(w) > 3])
            
#             # Add to inverted index
#             for word in unique_words:
#                 if word not in self.keywords_index:
#                     self.keywords_index[word] = []
#                 self.keywords_index[word].append((i, job_id))
    
#     def search(self, query: str, top_k: int = 5) -> List[Tuple[int, float]]:
#         """Perform hybrid search combining semantic and keyword results"""
#         if not self.index or not self.documents:
#             return []
        
#         # Semantic search
#         query_embedding = self.embedding_model.encode([query], convert_to_tensor=True)
#         query_embedding = query_embedding.cpu().numpy().astype('float32')
        
#         # Search index
#         distances, indices = self.index.search(query_embedding, top_k)
#         semantic_results = [(idx, float(1 - dist/2)) for idx, dist in zip(indices[0], distances[0])]
        
#         # Keyword search
#         keyword_results = self._keyword_search(query, top_k)
        
#         # Combine results (simple approach - could be improved)
#         combined_results = {}
        
#         # Add semantic results with weight 0.7
#         for idx, score in semantic_results:
#             if idx < len(self.documents):
#                 combined_results[idx] = score * 0.7
        
#         # Add keyword results with weight 0.3
#         for idx, score in keyword_results:
#             if idx in combined_results:
#                 combined_results[idx] += score * 0.3
#             else:
#                 combined_results[idx] = score * 0.3
        
#         # Sort by score
#         sorted_results = sorted(combined_results.items(), key=lambda x: x[1], reverse=True)
#         return sorted_results[:top_k]
    
#     def _keyword_search(self, query: str, top_k: int) -> List[Tuple[int, float]]:
#         """Perform keyword search"""
#         # Clean and tokenize query
#         query = query.lower()
#         query_words = re.sub(r'[^\w\s]', ' ', query).split()
#         query_words = [w for w in query_words if len(w) > 3]
        
#         # Count matches for each document
#         doc_matches = {}
        
#         for word in query_words:
#             if word in self.keywords_index:
#                 for doc_idx, _ in self.keywords_index[word]:
#                     if doc_idx not in doc_matches:
#                         doc_matches[doc_idx] = 0
#                     doc_matches[doc_idx] += 1
        
#         # Calculate scores based on match count and query length
#         results = []
#         query_len = max(1, len(query_words))
        
#         for doc_idx, match_count in doc_matches.items():
#             score = match_count / query_len
#             results.append((doc_idx, score))
        
#         # Sort by score
#         results.sort(key=lambda x: x[1], reverse=True)
#         return results[:top_k]


# class RecommendationEngine:
#     def __init__(self):
#         self.device = 'cuda' if self._has_gpu() else 'cpu'
#         self.embedding_model = None
#         self.llm = None
#         self.tokenizer = None
#         self.resume_parser = ResumeParser()
#         self.search_engine = None
#         self.job_ids = []
#         self._initialize_models()

#     def _has_gpu(self) -> bool:
#         """Check GPU availability safely"""
#         if not getattr(settings, 'USE_GPU', False):
#             return False
#         try:
#             return torch.cuda.is_available()
#         except RuntimeError:
#             return False

#     def _initialize_models(self):
#         """Initialize models with proper configuration"""
#         try:
#             # Initialize embedding model
#             self.embedding_model = SentenceTransformer(
#                 'sentence-transformers/all-mpnet-base-v2',
#                 device=self.device
#             )
            
#             # Initialize text-to-text generation pipeline for T5
#             self.llm = pipeline(
#                 "text2text-generation",
#                 model="google/flan-t5-base",
#                 device=0 if self.device == 'cuda' else -1,
#                 max_length=150,
#                 temperature=0.7
#             )
            
#             self.tokenizer = AutoTokenizer.from_pretrained("google/flan-t5-base")
            
#             # Initialize search engine
#             self.search_engine = HybridSearchEngine(self.embedding_model)
            
#         except Exception as e:
#             logger.error(f"Model initialization failed: {str(e)}")
#             raise

#     def _process_resumes(self, user_profile) -> Dict[str, str]:
#         """Process resume content from user profile, extracting specific sections"""
#         if not user_profile.resumes:
#             return {"experience": "", "projects": ""}
            
#         try:
#             resume_paths = json.loads(user_profile.resumes)
#             # resume_paths = [path.replace('resumes/', 'media/resumes/') for path in resume_paths]
#             extracted_sections = {"experience": [], "projects": []}
            
#             for rel_path in resume_paths:
#                 abs_path = os.path.join(settings.MEDIA_ROOT, rel_path.replace('\\', '/'))

#                 if not os.path.exists(abs_path):
#                     logger.warning(f"Resume file not found at: {abs_path}")
#                     continue  # Skip this resume
#                 try:
#                     with open(abs_path, 'rb') as f:
#                         raw_text = self.resume_parser.extract_text_from_pdf(f.read())
#                         sections = self.resume_parser.extract_sections(raw_text)
                        
#                         if "experience" in sections:
#                             extracted_sections["experience"].append(
#                                 self.resume_parser.clean_text(sections["experience"])
#                             )
                        
#                         if "projects" in sections:
#                             extracted_sections["projects"].append(
#                                 self.resume_parser.clean_text(sections["projects"])
#                             )
                            
#                 except (IOError, json.JSONDecodeError) as e:
#                     logger.warning(f"Resume read error: {str(e)}")
            
#             # Combine and truncate sections
#             result = {
#                 "experience": " ".join(extracted_sections["experience"])[:1500],
#                 "projects": " ".join(extracted_sections["projects"])[:1500]
#             }
            
#             return result
            
#         except json.JSONDecodeError:
#             return {"experience": "", "projects": ""}

#     def create_user_text(self, user_profile) -> str:
#         """Generate comprehensive user profile text with focused sections"""
#         parts = []
        
#         if user_profile.skills:
#             skills = user_profile.skills.split(',')[:20]
#             parts.append(f"Skills: {', '.join(skills)}")
        
#         resume_sections = self._process_resumes(user_profile)
        
#         if resume_sections["experience"]:
#             parts.append(f"Experience: {resume_sections['experience']}")
            
#         if resume_sections["projects"]:
#             parts.append(f"Projects: {resume_sections['projects']}")
            
#         return '\n'.join(parts) or "No profile information"

#     def create_job_text(self, job) -> str:
#         """Generate standardized job description text"""
#         components = [
#             f"Title: {job.title}",
#             f"Company: {job.company.username}",
#             f"Location: {job.location}",
#             f"Type: {job.contract_type}",
#             f"Requirements: {', '.join(job.requirements[:10]) if job.requirements else 'None'}",
#             f"Description: {job.description[:1000]}"
#         ]
#         return '\n'.join(components)

#     def build_index(self, jobs: List[Job]) -> None:
#         """Build hybrid search index"""
#         job_documents = []
#         job_ids = []
        
#         for job in jobs:
#             job_text = self.create_job_text(job)
#             job_documents.append({"text": job_text})
#             job_ids.append(job.id)
        
#         # Index documents using hybrid search
#         self.search_engine.index_documents(job_documents, job_ids)
#         self.job_ids = job_ids

#     def get_recommendations(self, user_profile, jobs: List[Job], top_k: int = 5) -> List[Dict]:
#         """Generate personalized job recommendations using hybrid search"""
#         if not jobs:
#             return []
            
#         # Rebuild index if jobs changed
#         current_ids = {j.id for j in jobs}
#         if not self.search_engine.index or set(self.job_ids) != current_ids:
#             self.build_index(jobs)
            
#         # Process user profile
#         user_text = self.create_user_text(user_profile)
        
#         # Perform hybrid search
#         search_results = self.search_engine.search(user_text, top_k)
        
#         # Compile results
#         results = []
#         for idx, score in search_results:
#             try:
#                 job_id = self.job_ids[idx]
#                 job = next(j for j in jobs if j.id == job_id)
                
#                 results.append({
#                     'job_id': job.id,
#                     'score': float(score),
#                     'title': job.title,
#                     'company': job.company.username,
#                     'summary': self._generate_summary(user_text, self.create_job_text(job))
#                 })
#             except (StopIteration, IndexError):
#                 continue
                
#         return sorted(results, key=lambda x: x['score'], reverse=True)[:top_k]

#     def _generate_summary(self, user_text: str, job_text: str) -> str:
#         """Generate LLM-powered match explanation with specific focus"""
#         prompt = f"""
#             [INST] Analyze candidate-job match focusing on these aspects:
#             1. **Core Skills Match**: Compare the candidate's technical skills with job requirements
#             2. **Industry Alignment**: Verify if candidate background matches job industry
#             3. **Experience Level**: Compare years and type of experience
#             4. **Location Compatibility**: Check if locations are compatible
#             5. **Career Progression**: Does this job align with candidate's career path?

#             Candidate Profile:
#             {user_text[:500]}

#             Job Details:
#             {job_text[:500]}

#             Provide specific matches or mismatches. If no clear match, state why.
#             Format as:
#             - ✅ Strong Match: [specific reason]
#             - ⚠️ Potential Concern: [specific reason]
#             - ❌ Mismatch: [specific reason]
#             [/INST]
#             """
        
#         try:
#             # Tokenize and truncate if necessary
#             inputs = self.tokenizer(
#                 prompt,
#                 return_tensors='pt',
#                 max_length=512,
#                 truncation=True
#             )
            
#             # Generate summary
#             output = self.llm(
#                 prompt,
#                 max_length=150,
#                 num_return_sequences=1,
#                 temperature=None
#             )
#             return output[0]['generated_text'].strip()
            
#         except Exception as e:
#             logger.error(f"Summary generation failed: {str(e)}")
#             return "Match details unavailable"