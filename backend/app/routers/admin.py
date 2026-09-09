import csv
import io
from datetime import datetime

from fastapi import APIRouter, Depends, File, HTTPException, Query, UploadFile
from sqlalchemy.orm import Session

from ..database import get_db
from ..models import (AcademicYear, Announcement, Classroom, Form, Homework,
                      Student)
from ..schemas import (AcademicYearCreate, AcademicYearUpdate, AnnouncementCreate,
                       ClassroomCreate, ClassroomUpdate, FormCreate, FormUpdate,
                       HomeworkCreate, StudentCreate, StudentUpdate)
from ..security import current_admin, hash_password
from ..serialize import serialize

router = APIRouter(prefix="/api/admin", tags=["admin"])

# --------------------------------------------------------------------------- #
# helpers
# --------------------------------------------------------------------------- #


def _get(db: Session, model, obj_id: int):
    obj = db.get(model, obj_id)
    if not obj:
        raise HTTPException(status_code=404, detail=f"{model.__name__} not found")
    return obj


def _ay_dict(ay, db):
    d = serialize(ay)
    d["form_count"] = db.query(Form).filter(Form.academic_year_id == ay.id).count()
    return d


def _form_dict(form, db):
    d = serialize(form)
    d["class_count"] = db.query(Classroom).filter(Classroom.form_id == form.id).count()
    return d


def _class_dict(cls, db):
    d = serialize(cls)
    d["student_count"] = db.query(Student).filter(Student.classroom_id == cls.id).count()
    return d


# --------------------------------------------------------------------------- #
# Academic years
# --------------------------------------------------------------------------- #


@router.get("/academic-years")
def list_academic_years(_: dict = Depends(current_admin), db: Session = Depends(get_db)):
    rows = db.query(AcademicYear).order_by(AcademicYear.id.desc()).all()
    return [_ay_dict(a, db) for a in rows]


@router.post("/academic-years")
def create_academic_year(body: AcademicYearCreate, _: dict = Depends(current_admin), db: Session = Depends(get_db)):
    if body.is_current:
        db.query(AcademicYear).filter(AcademicYear.is_current.is_(True)).update({"is_current": False})
    ay = AcademicYear(name=body.name, start_date=body.start_date, end_date=body.end_date, is_current=body.is_current)
    db.add(ay)
    db.commit()
    db.refresh(ay)
    return _ay_dict(ay, db)


@router.put("/academic-years/{ay_id}")
def update_academic_year(ay_id: int, body: AcademicYearUpdate, _: dict = Depends(current_admin), db: Session = Depends(get_db)):
    ay = _get(db, AcademicYear, ay_id)
    data = body.model_dump(exclude_unset=True)
    if data.get("is_current"):
        db.query(AcademicYear).filter(AcademicYear.id != ay_id).update({"is_current": False})
    for k, v in data.items():
        setattr(ay, k, v)
    db.commit()
    db.refresh(ay)
    return _ay_dict(ay, db)


@router.delete("/academic-years/{ay_id}")
def delete_academic_year(ay_id: int, _: dict = Depends(current_admin), db: Session = Depends(get_db)):
    ay = _get(db, AcademicYear, ay_id)
    db.delete(ay)
    db.commit()
    return {"ok": True}


# --------------------------------------------------------------------------- #
# Forms
# --------------------------------------------------------------------------- #


@router.get("/forms")
def list_forms(academic_year_id: int = Query(None), _: dict = Depends(current_admin), db: Session = Depends(get_db)):
    q = db.query(Form)
    if academic_year_id:
        q = q.filter(Form.academic_year_id == academic_year_id)
    rows = q.order_by(Form.level, Form.name).all()
    return [_form_dict(f, db) for f in rows]


@router.post("/forms")
def create_form(body: FormCreate, _: dict = Depends(current_admin), db: Session = Depends(get_db)):
    _get(db, AcademicYear, body.academic_year_id)
    form = Form(academic_year_id=body.academic_year_id, name=body.name, level=body.level)
    db.add(form)
    db.commit()
    db.refresh(form)
    return _form_dict(form, db)


@router.put("/forms/{form_id}")
def update_form(form_id: int, body: FormUpdate, _: dict = Depends(current_admin), db: Session = Depends(get_db)):
    form = _get(db, Form, form_id)
    data = body.model_dump(exclude_unset=True)
    for k, v in data.items():
        setattr(form, k, v)
    db.commit()
    db.refresh(form)
    return _form_dict(form, db)


@router.delete("/forms/{form_id}")
def delete_form(form_id: int, _: dict = Depends(current_admin), db: Session = Depends(get_db)):
    form = _get(db, Form, form_id)
    db.delete(form)
    db.commit()
    return {"ok": True}


# --------------------------------------------------------------------------- #
# Classes
# --------------------------------------------------------------------------- #


@router.get("/classes")
def list_classes(form_id: int = Query(None), _: dict = Depends(current_admin), db: Session = Depends(get_db)):
    q = db.query(Classroom)
    if form_id:
        q = q.filter(Classroom.form_id == form_id)
    rows = q.order_by(Classroom.name).all()
    return [_class_dict(c, db) for c in rows]


@router.post("/classes")
def create_class(body: ClassroomCreate, _: dict = Depends(current_admin), db: Session = Depends(get_db)):
    _get(db, Form, body.form_id)
    cls = Classroom(form_id=body.form_id, name=body.name)
    db.add(cls)
    db.commit()
    db.refresh(cls)
    return _class_dict(cls, db)


@router.post("/classes/bulk")
def bulk_create_classes(body: dict, _: dict = Depends(current_admin), db: Session = Depends(get_db)):
    """Create several classes at once: {form_id: int, names: [str, ...]}."""
    form_id = body.get("form_id")
    names = body.get("names") or []
    _get(db, Form, form_id)
    created = []
    for name in names:
        cls = Classroom(form_id=form_id, name=name.strip())
        db.add(cls)
        created.append(cls)
    db.commit()
    return [_class_dict(c, db) for c in created]


@router.put("/classes/{class_id}")
def update_class(class_id: int, body: ClassroomUpdate, _: dict = Depends(current_admin), db: Session = Depends(get_db)):
    cls = _get(db, Classroom, class_id)
    data = body.model_dump(exclude_unset=True)
    for k, v in data.items():
        setattr(cls, k, v)
    db.commit()
    db.refresh(cls)
    return _class_dict(cls, db)


@router.delete("/classes/{class_id}")
def delete_class(class_id: int, _: dict = Depends(current_admin), db: Session = Depends(get_db)):
    cls = _get(db, Classroom, class_id)
    db.delete(cls)
    db.commit()
    return {"ok": True}


# --------------------------------------------------------------------------- #
# Students
# --------------------------------------------------------------------------- #


def _student_dict(s):
    return serialize(s, exclude={"password_hash"})


@router.get("/students")
def list_students(
    classroom_id: int = Query(None),
    q: str = Query(None),
    _: dict = Depends(current_admin),
    db: Session = Depends(get_db),
):
    query = db.query(Student)
    if classroom_id:
        query = query.filter(Student.classroom_id == classroom_id)
    if q:
        like = f"%{q}%"
        query = query.filter(
            (Student.english_name.ilike(like))
            | (Student.chinese_name.ilike(like))
            | (Student.username.ilike(like))
            | (Student.student_number.ilike(like))
        )
    rows = query.order_by(Student.english_name).all()
    return [_student_dict(s) for s in rows]


@router.post("/students")
def create_student(body: StudentCreate, _: dict = Depends(current_admin), db: Session = Depends(get_db)):
    if body.classroom_id:
        _get(db, Classroom, body.classroom_id)
    if db.query(Student).filter(Student.username == body.username).first():
        raise HTTPException(status_code=400, detail="Username already exists")
    if body.student_number and db.query(Student).filter(Student.student_number == body.student_number).first():
        raise HTTPException(status_code=400, detail="Student number already exists")
    student = Student(
        classroom_id=body.classroom_id,
        student_number=body.student_number,
        english_name=body.english_name,
        chinese_name=body.chinese_name,
        gender=body.gender,
        date_of_birth=body.date_of_birth,
        guardian_name=body.guardian_name,
        guardian_phone=body.guardian_phone,
        guardian_email=body.guardian_email,
        username=body.username,
        password_hash=hash_password(body.password),
        status=body.status,
    )
    db.add(student)
    db.commit()
    db.refresh(student)
    return _student_dict(student)


@router.put("/students/{student_id}")
def update_student(student_id: int, body: StudentUpdate, _: dict = Depends(current_admin), db: Session = Depends(get_db)):
    student = _get(db, Student, student_id)
    data = body.model_dump(exclude_unset=True)
    if "classroom_id" in data and data["classroom_id"] is not None:
        _get(db, Classroom, data["classroom_id"])
    password = data.pop("password", None)
    if password:
        data["password_hash"] = hash_password(password)
    for k, v in data.items():
        setattr(student, k, v)
    db.commit()
    db.refresh(student)
    return _student_dict(student)


@router.delete("/students/{student_id}")
def delete_student(student_id: int, _: dict = Depends(current_admin), db: Session = Depends(get_db)):
    student = _get(db, Student, student_id)
    db.delete(student)
    db.commit()
    return {"ok": True}


@router.post("/students/batch-delete")
def batch_delete_students(body: dict, _: dict = Depends(current_admin), db: Session = Depends(get_db)):
    ids = body.get("ids") or []
    deleted = 0
    if ids:
        deleted = db.query(Student).filter(Student.id.in_(ids)).delete(synchronize_session=False)
        db.commit()
    return {"deleted": deleted}


@router.post("/students/{student_id}/toggle-status")
def toggle_student_status(student_id: int, _: dict = Depends(current_admin), db: Session = Depends(get_db)):
    student = _get(db, Student, student_id)
    student.status = "disabled" if student.status == "active" else "active"
    db.commit()
    db.refresh(student)
    return _student_dict(student)


@router.post("/students/import")
def import_students(
    classroom_id: int = Query(None),
    file: UploadFile = File(...),
    _: dict = Depends(current_admin),
    db: Session = Depends(get_db),
):
    """CSV with header row. Columns (case-insensitive):
    student_number, english_name, chinese_name, gender, date_of_birth,
    guardian_name, guardian_phone, guardian_email, username, password, class_name
    """
    if classroom_id:
        _get(db, Classroom, classroom_id)

    content = file.file.read().decode("utf-8-sig", errors="replace")
    reader = csv.DictReader(io.StringIO(content))
    created, errors = 0, []

    for i, row in enumerate(reader, start=2):
        def col(*names):
            for n in names:
                if n in row and row[n] not in (None, ""):
                    return row[n]
            return None

        english_name = col("english_name")
        username = col("username")
        password = col("password") or "changeme123"
        if not english_name or not username:
            errors.append({"row": i, "error": "Missing english_name or username"})
            continue

        if db.query(Student).filter(Student.username == username).first():
            errors.append({"row": i, "error": f"Username '{username}' already exists"})
            continue

        # resolve class: explicit class_name column wins, else classroom_id param
        target_class_id = classroom_id
        class_name = col("class_name")
        if class_name:
            cls = db.query(Classroom).filter(Classroom.name == class_name).first()
            if cls:
                target_class_id = cls.id

        dob_raw = col("date_of_birth")
        dob = None
        if dob_raw:
            for fmt in ("%Y-%m-%d", "%d/%m/%Y", "%Y/%m/%d"):
                try:
                    dob = datetime.strptime(dob_raw.strip(), fmt).date()
                    break
                except ValueError:
                    continue

        student = Student(
            classroom_id=target_class_id,
            student_number=col("student_number"),
            english_name=english_name,
            chinese_name=col("chinese_name"),
            gender=col("gender"),
            date_of_birth=dob,
            guardian_name=col("guardian_name"),
            guardian_phone=col("guardian_phone"),
            guardian_email=col("guardian_email"),
            username=username,
            password_hash=hash_password(password),
            status="active",
        )
        db.add(student)
        created += 1

    db.commit()
    return {"created": created, "errors": errors}


# --------------------------------------------------------------------------- #
# Announcements & homework
# --------------------------------------------------------------------------- #


@router.get("/announcements")
def list_announcements(_: dict = Depends(current_admin), db: Session = Depends(get_db)):
    rows = db.query(Announcement).order_by(Announcement.created_at.desc()).all()
    return [serialize(a) for a in rows]


@router.post("/announcements")
def create_announcement(body: AnnouncementCreate, _: dict = Depends(current_admin), db: Session = Depends(get_db)):
    a = Announcement(title=body.title, body=body.body, author=body.author)
    db.add(a)
    db.commit()
    db.refresh(a)
    return serialize(a)


@router.delete("/announcements/{ann_id}")
def delete_announcement(ann_id: int, _: dict = Depends(current_admin), db: Session = Depends(get_db)):
    a = _get(db, Announcement, ann_id)
    db.delete(a)
    db.commit()
    return {"ok": True}


@router.get("/homework")
def list_homework(_: dict = Depends(current_admin), db: Session = Depends(get_db)):
    rows = db.query(Homework).order_by(Homework.created_at.desc()).all()
    return [serialize(h) for h in rows]


@router.post("/homework")
def create_homework(body: HomeworkCreate, _: dict = Depends(current_admin), db: Session = Depends(get_db)):
    h = Homework(title=body.title, chapter_id=body.chapter_id, classroom_id=body.classroom_id, due_date=body.due_date)
    db.add(h)
    db.commit()
    db.refresh(h)
    return serialize(h)


@router.delete("/homework/{hw_id}")
def delete_homework(hw_id: int, _: dict = Depends(current_admin), db: Session = Depends(get_db)):
    h = _get(db, Homework, hw_id)
    db.delete(h)
    db.commit()
    return {"ok": True}
