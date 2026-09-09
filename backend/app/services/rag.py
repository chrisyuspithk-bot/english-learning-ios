import json
import re
from typing import List

from ..config import RAG_CHUNK_CHARS
from .llm import complete

CHAPTER_HEADING_RE = re.compile(
    r"^(?:Unit|Chapter|Lesson|Module)\s*[0-9]+[.:\-]?\s*.*$",
    re.IGNORECASE | re.MULTILINE,
)

SYSTEM_PROMPT = (
    "You are an English textbook content processor for Hong Kong primary school students. "
    "Extract structured learning content from the provided textbook text. "
    "Respond with strictly valid JSON only — no markdown fences, no commentary."
)

CHAPTER_SCHEMA_HINT = """Output a single JSON object with exactly this shape:

{
  "title": "short chapter title",
  "subtitle": "optional subtitle or null",
  "vocabulary": [
    {"word": "...", "phonetic": "...", "partOfSpeech": "noun/verb/adjective...",
     "meaning": "simple meaning", "definition": "simple English definition",
     "example": "example sentence"}
  ],
  "grammar": [
    {"title": "grammar point", "explanation": "simple explanation",
     "rule": "key rule in one sentence", "examples": ["example sentence", "example sentence"]}
  ],
  "exercises": [
    {"prompt": "question text", "options": ["A", "B", "C", "D"], "correctIndex": 0, "explanation": "why it is correct"}
  ],
  "reading": {
    "title": "passage title",
    "paragraphs": ["paragraph 1", "paragraph 2"],
    "questions": [
      {"prompt": "comprehension question", "options": ["A", "B", "C", "D"], "correctIndex": 0, "explanation": "why"}
    ]
  }
}

Rules:
- Extract 6-10 vocabulary items with simple English definitions and one example each.
- Extract 2-4 grammar points with 2-3 example sentences each.
- Generate 3-5 multiple-choice exercises with 4 options each.
- Always include a reading passage (write a short age-appropriate passage if the text does not contain one) with exactly 5 comprehension questions.
- "correctIndex" must be a valid index into "options" (0 to 3).
- Use simple English suitable for Primary 5 students.
"""


def extract_text(filename: str, content: bytes) -> str:
    ext = filename.lower().rsplit(".", 1)[-1] if "." in filename else ""
    if ext == "pdf":
        import io
        from pypdf import PdfReader
        reader = PdfReader(io.BytesIO(content))
        return "\n\n".join((page.extract_text() or "") for page in reader.pages)
    if ext in ("docx", "doc"):
        import io
        import docx
        document = docx.Document(io.BytesIO(content))
        return "\n\n".join(p.text for p in document.paragraphs)
    if ext in ("txt", "md", "text"):
        return content.decode("utf-8", errors="replace")
    raise ValueError(f"Unsupported file type: .{ext}")


def split_chapters(text: str) -> List[str]:
    text = text.strip()
    if not text:
        return []
    matches = list(CHAPTER_HEADING_RE.finditer(text))
    if not matches:
        return [text[:RAG_CHUNK_CHARS]]

    chunks: List[str] = []
    for i, match in enumerate(matches):
        start = match.start()
        end = matches[i + 1].start() if i + 1 < len(matches) else len(text)
        chunks.append(text[start:end].strip())

    if matches[0].start() > 0:
        front = text[: matches[0].start()].strip()
        if front:
            chunks[0] = front + "\n\n" + chunks[0]

    return [c[:RAG_CHUNK_CHARS] for c in chunks if c.strip()]


def _parse_json(raw: str) -> dict:
    raw = raw.strip()
    if raw.startswith("```"):
        raw = re.sub(r"^```(?:json)?\s*", "", raw)
        raw = re.sub(r"\s*```$", "", raw)
    return json.loads(raw)


def extract_chapter(text: str) -> dict:
    user = f"Textbook text:\n\n{text}\n\nExtract the content as JSON following the schema."
    raw = complete(SYSTEM_PROMPT + "\n\n" + CHAPTER_SCHEMA_HINT, user)
    data = _parse_json(raw)
    if not isinstance(data, dict):
        raise ValueError("LLM did not return a JSON object")
    data.setdefault("title", "Untitled chapter")
    data.setdefault("subtitle", None)
    data.setdefault("vocabulary", [])
    data.setdefault("grammar", [])
    data.setdefault("exercises", [])
    if not data.get("reading"):
        data["reading"] = {"title": data.get("title", ""), "paragraphs": [], "questions": []}
    return data


def process_file(filename: str, content: bytes) -> List[dict]:
    """Extract text from an uploaded file and turn it into structured chapters."""
    text = extract_text(filename, content)
    return [extract_chapter(chunk) for chunk in split_chapters(text)]
