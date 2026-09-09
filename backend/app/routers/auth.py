from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from ..database import get_db
from ..models import Admin, Student
from ..schemas import LoginRequest
from ..security import create_token, verify_password

router = APIRouter(prefix="/api/auth", tags=["auth"])


@router.post("/admin/login")
def admin_login(body: LoginRequest, db: Session = Depends(get_db)):
    admin = db.query(Admin).filter(Admin.username == body.username).first()
    if not admin or not verify_password(body.password, admin.password_hash):
        raise HTTPException(status_code=401, detail="Invalid username or password")
    token = create_token({"sub": admin.username, "role": "admin", "id": admin.id})
    return {"token": token, "user": {"username": admin.username, "name": admin.name, "role": "admin"}}


@router.post("/student/login")
def student_login(body: LoginRequest, db: Session = Depends(get_db)):
    student = db.query(Student).filter(Student.username == body.username).first()
    if not student or not verify_password(body.password, student.password_hash):
        raise HTTPException(status_code=401, detail="Invalid username or password")
    if student.status != "active":
        raise HTTPException(status_code=403, detail="Account is disabled")
    token = create_token({"sub": student.username, "role": "student", "id": student.id})
    return {
        "token": token,
        "user": {
            "id": student.id,
            "username": student.username,
            "english_name": student.english_name,
            "role": "student",
        },
    }
