from pathlib import Path
import os
import re

from fastapi.middleware.cors import CORSMiddleware
from fastapi import FastAPI
from pydantic import BaseModel
from dotenv import load_dotenv
from openai import OpenAI

from langchain_chroma import Chroma
from langchain_huggingface import HuggingFaceEmbeddings


# ============================================================
# PROJECT PATH
# ============================================================

BASE_DIR = Path(__file__).resolve().parent.parent
CHROMA_DIR = BASE_DIR / ".chroma"

load_dotenv(BASE_DIR / ".env")


# ============================================================
# OPENAI
# ============================================================

api_key = os.getenv("OPENAI_API_KEY")

if not api_key:
    raise ValueError("OPENAI_API_KEY not found in .env")

client = OpenAI(api_key=api_key)


# ============================================================
# EMBEDDINGS + VECTOR DATABASE
# ============================================================

embeddings = HuggingFaceEmbeddings(
    model_name="sentence-transformers/all-MiniLM-L6-v2"
)

vector_store = Chroma(
    collection_name="uniguide_comsats",
    persist_directory=str(CHROMA_DIR),
    embedding_function=embeddings
)


# ============================================================
# FASTAPI
# ============================================================

app = FastAPI(
    title="UniGuide AI",
    description="AI-powered COMSATS Abbottabad Information Assistant",
    version="1.0.0"
)


# ============================================================
# CORS
# Allows the Flutter frontend to communicate with FastAPI.
# ============================================================

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ============================================================
# REQUEST MODEL
# ============================================================

class QuestionRequest(BaseModel):
    question: str
    history: list[dict] = []


# ============================================================
# KEYWORD FUNCTION
# ============================================================

stop_words = {
    "what", "is", "the", "a", "an", "of", "for", "to",
    "how", "can", "i", "in", "at", "on", "and", "or",
    "my", "me", "please", "tell", "about", "do", "does",
    "hai", "hay", "he", "ki", "ka", "ke", "kya", "kia",
    "mein", "main", "mujhy", "mujhe", "batao", "btao",
    "par", "se", "ko", "ye", "ya"
}


def get_keywords(text):

    words = re.findall(
        r"[a-zA-Z0-9]+",
        text.lower()
    )

    return {
        word
        for word in words
        if len(word) > 2 and word not in stop_words
    }


# ============================================================
# RAG FUNCTION
# ============================================================

def answer_question(question, history=None):

    # --------------------------------------------------------
    # Make sure history is always a list.
    # --------------------------------------------------------

    if history is None:
        history = []

    # --------------------------------------------------------
    # Retrieve possible relevant chunks
    # --------------------------------------------------------

    results = vector_store.similarity_search(
        question,
        k=10
    )

    question_keywords = get_keywords(question)

    scored_results = []

    for document in results:

        source = document.metadata.get(
            "source",
            "Unknown source"
        )

        content = document.page_content.lower()

        document_keywords = get_keywords(content)

        keyword_overlap = len(
            question_keywords.intersection(
                document_keywords
            )
        )

        source_bonus = 0

        source_lower = source.lower()

        for keyword in question_keywords:

            if keyword in source_lower:
                source_bonus += 3

        final_score = (
            keyword_overlap +
            source_bonus
        )

        scored_results.append(
            (
                final_score,
                document
            )
        )

    # Highest relevance first
    scored_results.sort(
        key=lambda item: item[0],
        reverse=True
    )

    # Keep useful results
    selected_results = [
        document
        for score, document in scored_results[:5]
        if score > 0
    ]

    if not selected_results:
        selected_results = results[:3]

    # --------------------------------------------------------
    # Build context
    # --------------------------------------------------------

    context_parts = []

    for document in selected_results:

        source = document.metadata.get(
            "source",
            "Unknown source"
        )

        context_parts.append(
            f"""
SOURCE FILE: {source}

CONTENT:
{document.page_content}
"""
        )

    context = "\n-----------------------------\n".join(
        context_parts
    )

    # --------------------------------------------------------
    # Build conversation history
    # --------------------------------------------------------

    conversation_text = ""

    for message in history[-6:]:

        role = message.get("role", "")
        content = message.get("content", "")

        if role and content:

            conversation_text += (
                f"{role.upper()}: {content}\n"
            )

    # --------------------------------------------------------
    # AI instructions
    # --------------------------------------------------------

    system_prompt = """
You are UniGuide AI, the official, intelligent, and courteous student assistant for COMSATS University Islamabad (CUI), Abbottabad Campus.

Your mission is to provide accurate, well-structured, and helpful academic guidance to students.

============================================================
STRICT PRIVACY & SOURCE RULES
============================================================
1. NEVER mention file names (such as "02_faqs.md", "07_student_affairs.md", etc.), file extensions (".md"), system files, or internal database terms.
2. NEVER write "Source: filename", "Sources used:", or state "in files mein information nahi di gayi". The frontend already displays the official CUI reference card at the bottom.
3. NEVER fabricate university facts, fees, or dates.
4. Do NOT confuse categories (e.g. BS tuition fee is NOT hostel fee; scholarship aid is NOT registration fee).

============================================================
ELEGANT HANDLING OF UNVERIFIED OR MISSING DETAILS
============================================================
If a student asks about a university topic whose exact current session rules, circulars, or detailed steps are not explicitly in your verified records (e.g. specific FYP timelines, departmental thesis forms, internal course outlines):
- DO NOT say "I don't know", "Provided information mein available nahi hai", or "Files mein nahi mila".
- Instead, handle it gracefully and elegantly:
  1. Provide helpful general academic guidance or standard university structure related to their question.
  2. Politely and professionally guide the student to the exact department body or portal (e.g. Department FYP Committee, Academic Coordinator, HoD Office, or the official CUI Abbottabad web portal).
  3. Keep the tone reassuring, encouraging, and respectful.

============================================================
BEAUTIFUL MARKDOWN FORMATTING
============================================================
Ensure every response is visually engaging and easy to read:
- Headings: Use '### ' for main sections when structuring detailed answers.
- Highlights: Use **bold** text to highlight key fees, deadlines, eligibility criteria, and important keywords.
- Tables: Use standard Markdown tables whenever presenting fee breakdowns, comparisons, eligibility percentages, or schedules.
- Bullet Points: Use clean bullet points ('- ') and numbered steps ('1. ') for processes and lists.

============================================================
LANGUAGE & TONE
============================================================
- Respond naturally in the language of the student (English, Urdu, or Roman Urdu).
- If the student asks in Roman Urdu, reply in fluent, courteous, professional Roman Urdu.
- Maintain a welcoming, polite, and official academic tone.
"""

    # --------------------------------------------------------
    # User prompt
    # --------------------------------------------------------

    user_prompt = f"""
PREVIOUS CONVERSATION:

{conversation_text}

-----------------------------

CURRENT STUDENT QUESTION:

{question}

-----------------------------

VERIFIED COMSATS KNOWLEDGE:

{context}
"""

    # --------------------------------------------------------
    # OpenAI
    # --------------------------------------------------------

    response = client.responses.create(
        model="gpt-5.6-luna",
        instructions=system_prompt,
        input=user_prompt
    )

    answer = response.output_text.strip()

    # --------------------------------------------------------
    # Sources
    # --------------------------------------------------------

    sources = []

    for document in selected_results:

        source = document.metadata.get(
            "source",
            "Unknown source"
        )

        if source not in sources:
            sources.append(source)

    return {
        "answer": answer,
        "sources": sources
    }


# ============================================================
# HOME
# ============================================================

@app.get("/")
def home():

    return {
        "message": "Welcome to UniGuide AI!",
        "status": "API is running"
    }


# ============================================================
# HEALTH CHECK
# ============================================================

@app.get("/health")
def health_check():

    return {
        "status": "healthy",
        "rag": "connected"
    }


# ============================================================
# ASK ENDPOINT
# ============================================================

@app.post("/ask")
def ask_question(request: QuestionRequest):

    result = answer_question(
        request.question,
        request.history
    )

    return result