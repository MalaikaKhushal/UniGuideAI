from pathlib import Path
import os
import re

from dotenv import load_dotenv
from openai import OpenAI

from langchain_chroma import Chroma
from langchain_huggingface import HuggingFaceEmbeddings


# ============================================================
# 1. PROJECT PATHS
# ============================================================

BASE_DIR = Path(__file__).resolve().parent.parent

CHROMA_DIR = BASE_DIR / ".chroma"

load_dotenv(BASE_DIR / ".env")


# ============================================================
# 2. OPENAI
# ============================================================

api_key = os.getenv("OPENAI_API_KEY")

if not api_key:
    raise ValueError(
        "OPENAI_API_KEY not found. Check your .env file."
    )

client = OpenAI(api_key=api_key)


# ============================================================
# 3. EMBEDDINGS + CHROMA
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
# 4. QUESTION
# ============================================================

question = input("\nStudent Question: ").strip()


# ============================================================
# 5. RETRIEVE MORE RESULTS
# ============================================================

# Pehle 10 possible relevant chunks nikalte hain.
# Baad mein hum irrelevant chunks filter karenge.
results = vector_store.similarity_search(
    question,
    k=10
)


# ============================================================
# 6. QUESTION KEYWORDS
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
    words = re.findall(r"[a-zA-Z0-9]+", text.lower())

    return {
        word
        for word in words
        if len(word) > 2 and word not in stop_words
    }


question_keywords = get_keywords(question)


# ============================================================
# 7. SCORE RETRIEVED DOCUMENTS
# ============================================================

scored_results = []

for document in results:

    source = document.metadata.get(
        "source",
        "Unknown source"
    )

    content = document.page_content.lower()

    # Document ke words
    document_keywords = get_keywords(content)

    # Question aur document ke common keywords
    keyword_overlap = len(
        question_keywords.intersection(document_keywords)
    )

    # Question mein jo important terms hain
    # unko source filename mein bhi check karna
    source_lower = source.lower()

    source_bonus = 0

    for keyword in question_keywords:
        if keyword in source_lower:
            source_bonus += 3

    final_score = keyword_overlap + source_bonus

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


# ============================================================
# 8. KEEP ONLY USEFUL RESULTS
# ============================================================

# Maximum 5 highly relevant chunks.
selected_results = [
    document
    for score, document in scored_results[:5]
    if score > 0
]


# Agar keyword filtering se kuch nahi mila,
# semantic search ke top 3 results use kar lenge.
if not selected_results:
    selected_results = results[:3]


# ============================================================
# 9. BUILD VERIFIED CONTEXT
# ============================================================

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


# ============================================================
# 10. STRONG SYSTEM PROMPT
# ============================================================

system_prompt = """
You are UniGuide AI, the official, intelligent, and courteous student assistant for COMSATS University Islamabad (CUI), Abbottabad Campus.

Your mission is to provide accurate, well-structured, and helpful academic guidance to students.

============================================================
STRICT PRIVACY & SOURCE RULES
============================================================
1. NEVER mention file names (such as "02_faqs.md", "07_student_affairs.md", etc.), file extensions (".md"), system files, or internal database terms.
2. NEVER write "Source: filename", "Sources used:", or state "in files mein information nahi di gayi".
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


# ============================================================
# 11. USER PROMPT
# ============================================================

user_prompt = f"""
STUDENT QUESTION:

{question}


VERIFIED COMSATS KNOWLEDGE:

{context}


Answer the student's question using the rules above.
"""


# ============================================================
# 12. GPT RESPONSE
# ============================================================

response = client.responses.create(
    model="gpt-5.6-luna",
    instructions=system_prompt,
    input=user_prompt
)


answer = response.output_text.strip()


# ============================================================
# 13. DISPLAY
# ============================================================

print("\n")
print("=" * 65)
print("UNIGUIDE AI")
print("=" * 65)

print("\nANSWER:")
print(answer)

print("\nRETRIEVED SOURCES:")

seen_sources = set()

for document in selected_results:

    source = document.metadata.get(
        "source",
        "Unknown source"
    )

    if source not in seen_sources:

        print(f"- {source}")

        seen_sources.add(source)

print("\n" + "=" * 65)