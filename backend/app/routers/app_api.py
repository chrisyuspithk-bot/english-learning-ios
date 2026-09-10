from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from ..database import get_db
from ..models import (Announcement, Chapter, ChapterAssignment, Classroom,
                      Form, Homework, PracticeRecord, Student)
from ..schemas import RecordCreate
from ..security import current_user
from ..serialize import serialize

router = APIRouter(prefix="/api/app", tags=["app"])


def _student(payload: dict, db: Session) -> Student:
    if payload.get("role") != "student":
        raise HTTPException(status_code=403, detail="Student access required")
    student = db.get(Student, payload.get("id"))
    if not student:
        raise HTTPException(status_code=404, detail="Student not found")
    return student


@router.get("/dashboard")
def dashboard(payload: dict = Depends(current_user), db: Session = Depends(get_db)):
    student = _student(payload, db)

    form_id = None
    classroom_id = student.classroom_id
    classroom = db.get(Classroom, classroom_id) if classroom_id else None
    if classroom:
        form_id = classroom.form_id

    chapters = []
    if form_id:
        rows = (
            db.query(Chapter)
            .join(ChapterAssignment, ChapterAssignment.chapter_id == Chapter.id)
            .filter(ChapterAssignment.form_id == form_id)
            .order_by(Chapter.number)
            .all()
        )
        chapters = [
            {
                "id": c.id,
                "number": c.number,
                "title": c.title,
                "subtitle": c.subtitle,
                "icon": c.icon,
                "colorHex": c.color_hex,
            }
            for c in rows
        ]

    homework = []
    if classroom_id:
        hw = (
            db.query(Homework)
            .filter(Homework.classroom_id == classroom_id)
            .order_by(Homework.created_at.desc())
            .all()
        )
        for h in hw:
            d = serialize(h)
            chapter = db.get(Chapter, h.chapter_id) if h.chapter_id else None
            d["chapter_title"] = chapter.title if chapter else None
            homework.append(d)

    class_data = serialize(classroom) if classroom else None
    if class_data:
        form = db.get(Form, classroom.form_id)
        class_data["form_name"] = form.name if form else None

    announcements = (
        db.query(Announcement).order_by(Announcement.created_at.desc()).all()
    )

    return {
        "student": serialize(student, exclude={"password_hash"}),
        "class": class_data,
        "chapters": chapters,
        "homework": homework,
        "announcements": [serialize(a) for a in announcements],
    }


@router.get("/chapters/{chapter_id}")
def get_chapter(chapter_id: int, payload: dict = Depends(current_user), db: Session = Depends(get_db)):
    _student(payload, db)
    chapter = db.get(Chapter, chapter_id)
    if not chapter:
        raise HTTPException(status_code=404, detail="Chapter not found")
    return {
        "id": chapter.id,
        "number": chapter.number,
        "title": chapter.title,
        "subtitle": chapter.subtitle,
        "icon": chapter.icon,
        "colorHex": chapter.color_hex,
        "vocabulary": chapter.vocabulary or [],
        "grammar": chapter.grammar or [],
        "exercises": chapter.exercises or [],
        "reading": chapter.reading or {},
    }


@router.post("/records")
def submit_record(body: RecordCreate, payload: dict = Depends(current_user), db: Session = Depends(get_db)):
    student = _student(payload, db)
    record = PracticeRecord(
        student_id=student.id,
        chapter_id=body.chapter_id,
        type=body.type,
        score=body.score,
        detail=body.detail,
    )
    db.add(record)
    db.commit()
    db.refresh(record)
    return serialize(record)


@router.get("/records")
def my_records(payload: dict = Depends(current_user), db: Session = Depends(get_db)):
    student = _student(payload, db)
    rows = (
        db.query(PracticeRecord)
        .filter(PracticeRecord.student_id == student.id)
        .order_by(PracticeRecord.created_at.desc())
        .all()
    )
    return [serialize(r) for r in rows]
