import os
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent  # backend/
DATA_DIR = BASE_DIR / "data"
DATA_DIR.mkdir(exist_ok=True)

DATABASE_URL = os.getenv("DATABASE_URL", f"sqlite:///{DATA_DIR / 'portal.db'}")

JWT_SECRET = os.getenv("JWT_SECRET", "dev-secret-change-me-in-production")
JWT_ALGORITHM = "HS256"
JWT_EXPIRES_MINUTES = int(os.getenv("JWT_EXPIRES_MINUTES", str(60 * 24)))

# LLM configuration (OpenAI-compatible). DeepSeek / OpenAI / any compatible provider.
LLM_API_KEY = os.getenv("LLM_API_KEY") or os.getenv("DEEPSEEK_API_KEY") or os.getenv("OPENAI_API_KEY")
if os.getenv("DEEPSEEK_API_KEY"):
    LLM_BASE_URL = os.getenv("LLM_BASE_URL", "https://api.deepseek.com")
    LLM_MODEL = os.getenv("LLM_MODEL", "deepseek-chat")
else:
    LLM_BASE_URL = os.getenv("LLM_BASE_URL", "https://api.openai.com/v1")
    LLM_MODEL = os.getenv("LLM_MODEL", "gpt-4o-mini")

# Maximum characters sent to the LLM per chunk.
RAG_CHUNK_CHARS = int(os.getenv("RAG_CHUNK_CHARS", "12000"))
