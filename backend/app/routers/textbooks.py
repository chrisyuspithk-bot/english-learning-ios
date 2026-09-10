from fastapi import APIRouter, Depends, File, HTTPException, Query, UploadFile
from fastapi import Form as FormField
from sqlalchemy import func
from sqlalchemy.orm import Session

from ..database import get_db
from ..models import Chapter, ChapterAssignment, Form, Textbook
from ..schemas import ChapterAssignRequest, ChapterCreate, ChapterUpdate, TextbookCreate
from ..security import current_admin
from ..serialize import serialize
from ..services import rag

router = APIRouter(prefix="/api/admin", tags=["textbooks"])


def _get(db: Session, model, obj_id: int):
    obj = db.get(model, obj_id)
    if not obj:
        raise HTTPException(status_code=404, detail=f"{model.__name__} not found")
    return obj


def _textbook_dict(t, db):
    d = serialize(t)
    d["chapter_count"] = db.query(Chapter).filter(Chapter.textbook_id == t.id).count()
    d["form_name"] = db.get(Form, t.form_id).name if t.form_id else None
    return d


# --------------------------------------------------------------------------- #
# Textbooks
# --------------------------------------------------------------------------- #


@router.get("/textbooks")
def list_textbooks(_: dict = Depends(current_admin), db: Session = Depends(get_db)):
    rows = db.query(Textbook).order_by(Textbook.id.desc()).all()
    return [_textbook_dict(t, db) for t in rows]


@router.post("/textbooks")
def create_textbook(body: TextbookCreate, _: dict = Depends(current_admin), db: Session = Depends(get_db)):
    level = body.level
    if body.form_id:
        level = _get(db, Form, body.form_id).name
    t = Textbook(title=body.title, subject=body.subject, level=level, form_id=body.form_id)
    db.add(t)
    db.commit()
    db.refresh(t)
    return _textbook_dict(t, db)


@router.post("/textbooks/upload")
async def upload_textbook(
    file: UploadFile = File(...),
    title: str = FormField(""),
    subject: str = FormField(""),
    level: str = FormField(""),
    _: dict = Depends(current_admin),
    db: Session = Depends(get_db),
):
    """Upload a PDF/TXT/DOCX textbook. Runs RAG -> LLM to produce structured chapters."""
    content = await file.read()
    try:
        chapters = rag.process_file(file.filename, content)
    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc))

    textbook_title = title.strip() or file.filename.rsplit(".", 1)[0] or "Untitled textbook"
    textbook = Textbook(title=textbook_title, subject=subject or None, level=level or None)
    db.add(textbook)
    db.flush()

    for i, data in enumerate(chapters, start=1):
        reading = data.get("reading") or {}
        chapter = Chapter(
            textbook_id=textbook.id,
            number=data.get("number") or i,
            title=data.get("title") or f"Chapter {i}",
            subtitle=data.get("subtitle"),
            vocabulary=data.get("vocabulary") or [],
            grammar=data.get("grammar") or [],
            exercises=data.get("exercises") or [],
            reading=reading,
        )
        db.add(chapter)

    db.commit()
    db.refresh(textbook)
    result = _textbook_dict(textbook, db)
    result["chapters"] = [serialize(c) for c in textbook.chapters]
    return result


@router.delete("/textbooks/{textbook_id}")
def delete_textbook(textbook_id: int, _: dict = Depends(current_admin), db: Session = Depends(get_db)):
    t = _get(db, Textbook, textbook_id)
    db.delete(t)
    db.commit()
    return {"ok": True}


# --------------------------------------------------------------------------- #
# Chapters
# --------------------------------------------------------------------------- #


@router.get("/chapters")
def list_chapters(textbook_id: int = Query(None), _: dict = Depends(current_admin), db: Session = Depends(get_db)):
    q = db.query(Chapter)
    if textbook_id:
        q = q.filter(Chapter.textbook_id == textbook_id)
    rows = q.order_by(Chapter.number, Chapter.id).all()
    return [serialize(c) for c in rows]


@router.get("/chapters/{chapter_id}")
def get_chapter(chapter_id: int, _: dict = Depends(current_admin), db: Session = Depends(get_db)):
    chapter = _get(db, Chapter, chapter_id)
    d = serialize(chapter)
    form_ids = [a.form_id for a in chapter.assignments]
    d["assigned_form_ids"] = form_ids
    return d


@router.post("/chapters")
def create_chapter(body: ChapterCreate, _: dict = Depends(current_admin), db: Session = Depends(get_db)):
    _get(db, Textbook, body.textbook_id)
    chapter = Chapter(
        textbook_id=body.textbook_id,
        number=body.number,
        title=body.title,
        subtitle=body.subtitle,
        icon=body.icon,
        color_hex=body.color_hex,
        vocabulary=body.vocabulary,
        grammar=body.grammar,
        exercises=body.exercises,
        reading=body.reading,
    )
    db.add(chapter)
    db.commit()
    db.refresh(chapter)
    return serialize(chapter)


@router.post("/chapters/upload")
async def upload_chapter(
    file: UploadFile = File(...),
    textbook_id: int = FormField(...),
    number: int = FormField(0),
    title: str = FormField(""),
    _: dict = Depends(current_admin),
    db: Session = Depends(get_db),
):
    """Upload a single chapter file. RAG -> LLM -> one structured chapter."""
    _get(db, Textbook, textbook_id)
    content = await file.read()
    try:
        data = rag.process_chapter(file.filename, content)
    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc))

    if number <= 0:
        max_num = (
            db.query(func.max(Chapter.number))
            .filter(Chapter.textbook_id == textbook_id)
            .scalar()
            or 0
        )
        number = max_num + 1

    chapter = Chapter(
        textbook_id=textbook_id,
        number=number,
        title=(title.strip() or data.get("title") or f"Chapter {number}"),
        subtitle=data.get("subtitle"),
        vocabulary=data.get("vocabulary") or [],
        grammar=data.get("grammar") or [],
        exercises=data.get("exercises") or [],
        reading=data.get("reading") or {},
    )
    db.add(chapter)
    db.commit()
    db.refresh(chapter)
    return serialize(chapter)


@router.put("/chapters/{chapter_id}")
def update_chapter(chapter_id: int, body: ChapterUpdate, _: dict = Depends(current_admin), db: Session = Depends(get_db)):
    chapter = _get(db, Chapter, chapter_id)
    data = body.model_dump(exclude_unset=True)
    for k, v in data.items():
        setattr(chapter, k, v)
    db.commit()
    db.refresh(chapter)
    return serialize(chapter)


@router.delete("/chapters/{chapter_id}")
def delete_chapter(chapter_id: int, _: dict = Depends(current_admin), db: Session = Depends(get_db)):
    chapter = _get(db, Chapter, chapter_id)
    db.delete(chapter)
    db.commit()
    return {"ok": True}


@router.post("/chapters/{chapter_id}/assign")
def assign_chapter(chapter_id: int, body: ChapterAssignRequest, _: dict = Depends(current_admin), db: Session = Depends(get_db)):
    chapter = _get(db, Chapter, chapter_id)
    for f_id in body.form_ids:
        _get(db, Form, f_id)
    # replace existing assignments
    db.query(ChapterAssignment).filter(ChapterAssignment.chapter_id == chapter_id).delete()
    for f_id in body.form_ids:
        db.add(ChapterAssignment(chapter_id=chapter_id, form_id=f_id))
    db.commit()
    d = serialize(chapter)
    d["assigned_form_ids"] = body.form_ids
    return d


@router.get("/forms/{form_id}/chapters")
def form_chapters(form_id: int, _: dict = Depends(current_admin), db: Session = Depends(get_db)):
    _get(db, Form, form_id)
    rows = (
        db.query(Chapter)
        .join(ChapterAssignment, ChapterAssignment.chapter_id == Chapter.id)
        .filter(ChapterAssignment.form_id == form_id)
        .order_by(Chapter.number)
        .all()
    )
    return [serialize(c) for c in rows]
