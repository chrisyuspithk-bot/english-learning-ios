# English Learning Platform

A full-stack English learning system for Hong Kong primary schools, in three parts:

| Part | Path | What it is |
|------|------|------------|
| iOS app | `EnglishLearningApp/` | SwiftUI POC (iOS 13+) — Apple Speech STT + Piper TTS |
| Portal backend | `backend/` | FastAPI REST API + RAG/LLM textbook processing |
| Admin portal | `frontend/` | Responsive React (Vite) web app |

## Goals

- **Goal A** — Admin CRUD: academic years → forms → classes → students (import CSV, disable, batch delete). ✅
- **Goal B** — Textbook upload (PDF / TXT / DOCX) → RAG → LLM → structured chapters (vocabulary / grammar / exercises / reading). ✅
- **Goal C** — Verified end-to-end (backend endpoints + portal UI tested). ✅
- **Goal D** — REST API for the app (login, dashboard, chapter download, submit records). ✅
- **Goal E** — Bind the iOS app to the API (see notes below).

---

## Quick start

### 1. Backend + portal

```bash
cd backend
pip install -r requirements.txt

# Set your LLM key (any OpenAI-compatible provider):
export LLM_API_KEY=sk-...                 # or OPENAI_API_KEY / DEEPSEEK_API_KEY
export LLM_BASE_URL=https://api.deepseek.com   # optional
export LLM_MODEL=deepseek-chat                 # optional

python -m uvicorn app.main:app --host 0.0.0.0 --port 8000
```

### 2. Build the admin portal (so the backend can serve it)

```bash
cd frontend
npm install
npm run build
```

Now open **http://localhost:8000/** — the portal is served by the backend.

- Admin login: `admin` / `admin123`
- Sample student: `amy` / `student123`
- Interactive API docs: **http://localhost:8000/docs**

### Frontend dev mode (optional)

```bash
cd frontend
npm run dev   # http://localhost:5173 (proxies /api → :8000)
```

---

## Data model (Goal A — the "simpler way")

```
Academic Year ("2026-2027")
   └── Form ("Primary 5")              ← grade / level
          └── Class ("5A", "5B")       ← a class within a form
                 └── Student           ← essential info below
```

Student fields (primary-school context): English name, Chinese name, gender,
date of birth, guardian name/phone/email, student number, username + password,
status (active/disabled), and class assignment.

To reduce admin effort: **bulk import students from CSV**, **bulk-create classes**
(e.g. `5A, 5B, 5C`), and batch delete. The CSV import accepts optional
`academic_year`, `form_name`, `form_level`, and `class_name` columns and
auto-creates missing academic years, forms, and classes.

---

## Textbook pipeline (Goal B)

Teachers upload **one chapter at a time**. For each chapter, upload a PDF / TXT / DOCX:

1. Extracts raw text (`pypdf` / `python-docx` / plain text).
2. Sends the chapter text to the LLM (OpenAI-compatible) with a strict JSON schema.
3. Stores a structured chapter — vocabulary, grammar, MC exercises, and a reading
   passage with 5 comprehension questions — which can be viewed/edited in the portal
   (structured editor, not raw JSON) and downloaded by the app.

The chapter JSON shape matches the iOS app's content model exactly.

---

## REST API summary (Goals A + D)

**Auth**
- `POST /api/auth/admin/login`
- `POST /api/auth/student/login`

**Admin (Goal A)**
- `GET/POST /api/admin/academic-years`, `PUT/DELETE /api/admin/academic-years/{id}`
- `GET/POST /api/admin/forms`, `PUT/DELETE /api/admin/forms/{id}`
- `GET/POST /api/admin/classes`, `POST /api/admin/classes/bulk`, `PUT/DELETE /api/admin/classes/{id}`
- `GET/POST /api/admin/students`, `PUT/DELETE /api/admin/students/{id}`,
  `POST /api/admin/students/{id}/toggle-status`, `POST /api/admin/students/batch-delete`,
  `POST /api/admin/students/import` (CSV)
- `GET/POST /api/admin/announcements`, `DELETE /api/admin/announcements/{id}`
- `GET/POST /api/admin/homework`, `DELETE /api/admin/homework/{id}`

**Textbooks (Goal B)**
- `GET/POST /api/admin/textbooks` (POST accepts optional `form_id` to bind a textbook to a Form), `DELETE /api/admin/textbooks/{id}`
- `POST /api/admin/chapters/upload` (multipart: `file`, `textbook_id`, optional `number`/`title`) — one chapter per upload
- `GET/POST /api/admin/chapters`, `GET/PUT/DELETE /api/admin/chapters/{id}`
- `POST /api/admin/chapters/{id}/assign` (body `{form_ids: [..]}`)
- `GET /api/admin/forms/{form_id}/chapters`

**App-facing (Goal D)**
- `GET /api/app/dashboard` — student + assigned chapters + homework + announcements
- `GET /api/app/chapters/{id}` — full chapter content
- `POST /api/app/records`, `GET /api/app/records` — submit / list practice records

All admin endpoints require `Authorization: Bearer <token>`.

---

## Goal E — binding the iOS app

The iOS app currently uses bundled sample data. To bind it to the API:

1. Point the app's base URL at your backend and call `/api/auth/student/login`,
   then `/api/app/dashboard` and `/api/app/chapters/{id}`.
2. Map backend IDs (integers) to the app's `Codable` models (the app's sample
   models use `String` ids — either switch them to `Int`, or assign ids client-side
   by index). The field names already line up (`vocabulary`, `grammar`, `exercises`,
   `reading`, `colorHex`, etc.).
3. Submit results via `POST /api/app/records` (type: `vocabulary` / `exercise` / `reading`).

---

## Directory structure

```
english-learning-ios/
├── EnglishLearningApp/        # iOS SwiftUI app
├── backend/
│   ├── app/
│   │   ├── main.py            # FastAPI app + static portal serving
│   │   ├── models.py          # SQLAlchemy models
│   │   ├── schemas.py         # Pydantic request schemas
│   │   ├── security.py        # JWT + password hashing
│   │   ├── seed.py            # sample data + default admin
│   │   ├── routers/           # auth / admin / textbooks / app_api
│   │   └── services/          # llm.py + rag.py (textbook pipeline)
│   ├── requirements.txt
│   └── data/                  # SQLite DB (gitignored)
└── frontend/                  # React + Vite admin portal
    └── src/ (App.jsx, api.js, styles.css)
```

> Default credentials are for local testing only — change `JWT_SECRET` and the
> admin password before deploying.
