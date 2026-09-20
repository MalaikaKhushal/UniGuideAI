from pathlib import Path

from langchain_core.documents import Document
from langchain_text_splitters import RecursiveCharacterTextSplitter
from langchain_chroma import Chroma
from langchain_huggingface import HuggingFaceEmbeddings


# ============================================================
# 1. Project ke folders locate karna
# ============================================================

BASE_DIR = Path(__file__).resolve().parent.parent

DOCUMENTS_DIR = BASE_DIR / "data" / "documents"

CHROMA_DIR = BASE_DIR / ".chroma"


# ============================================================
# 2. Saari Markdown files read karna
# ============================================================

documents = []

for file_path in DOCUMENTS_DIR.glob("*.md"):

    print(f"Reading: {file_path.name}")

    text = file_path.read_text(encoding="utf-8")

    # Har document ke saath uska filename bhi save kar rahe hain
    # taake baad mein answer ke source ka pata chal sake.
    documents.append(
        Document(
            page_content=text,
            metadata={
                "source": file_path.name,
                "path": str(file_path)
            }
        )
    )


print(f"\nTotal documents loaded: {len(documents)}")


# ============================================================
# 3. Documents ko small chunks mein divide karna
# ============================================================

text_splitter = RecursiveCharacterTextSplitter(
    chunk_size=1000,
    chunk_overlap=150
)

chunks = text_splitter.split_documents(documents)

print(f"Total chunks created: {len(chunks)}")


# ============================================================
# 4. Embedding model load karna
# ============================================================

print("\nLoading embedding model...")

embeddings = HuggingFaceEmbeddings(
    model_name="sentence-transformers/all-MiniLM-L6-v2"
)


# ============================================================
# 5. Chroma vector database banana
# ============================================================

print("\nCreating Chroma vector database...")

vector_store = Chroma.from_documents(
    documents=chunks,
    embedding=embeddings,
    persist_directory=str(CHROMA_DIR),
    collection_name="uniguide_comsats"
)


print("\n====================================")
print("RAG KNOWLEDGE BASE CREATED SUCCESSFULLY")
print("====================================")
print(f"Documents: {len(documents)}")
print(f"Chunks: {len(chunks)}")
print(f"Database: {CHROMA_DIR}")