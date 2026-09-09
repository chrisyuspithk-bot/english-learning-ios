from datetime import date
from typing import List, Optional

from pydantic import BaseModel


class LoginRequest(BaseModel):
    username: str
    password: str


class AcademicYearCreate(BaseModel):
    name: str
    start_date: Optional[date] = None
    end_date: Optional[date] = None
    is_current: bool = False


class AcademicYearUpdate(BaseModel):
    name: Optional[str] = None
    start_date: Optional[date] = None
    end_date: Optional[date] = None
    is_current: Optional[bool] = None


class FormCreate(BaseModel):
    academic_year_id: int
    name: str
    level: Optional[int] = None


class FormUpdate(BaseModel):
    academic_year_id: Optional[int] = None
    name: Optional[str] = None
    level: Optional[int] = None


class ClassroomCreate(BaseModel):
    form_id: int
    name: str


class ClassroomUpdate(BaseModel):
    form_id: Optional[int] = None
    name: Optional[str] = None


class StudentCreate(BaseModel):
    classroom_id: Optional[int] = None
    student_number: Optional[str] = None
    english_name: str
    chinese_name: Optional[str] = None
    gender: Optional[str] = None
    date_of_birth: Optional[date] = None
    guardian_name: Optional[str] = None
    guardian_phone: Optional[str] = None
    guardian_email: Optional[str] = None
    username: str
    password: str
    status: str = "active"


class StudentUpdate(BaseModel):
    classroom_id: Optional[int] = None
    student_number: Optional[str] = None
    english_name: Optional[str] = None
    chinese_name: Optional[str] = None
    gender: Optional[str] = None
    date_of_birth: Optional[date] = None
    guardian_name: Optional[str] = None
    guardian_phone: Optional[str] = None
    guardian_email: Optional[str] = None
    username: Optional[str] = None
    password: Optional[str] = None
    status: Optional[str] = None


class TextbookCreate(BaseModel):
    title: str
    subject: Optional[str] = None
    level: Optional[str] = None


class ChapterCreate(BaseModel):
    textbook_id: int
    number: Optional[int] = None
    title: str
    subtitle: Optional[str] = None
    icon: Optional[str] = "book.fill"
    color_hex: Optional[str] = "4F8EF7"
    vocabulary: List[dict] = []
    grammar: List[dict] = []
    exercises: List[dict] = []
    reading: Optional[dict] = None


class ChapterUpdate(BaseModel):
    number: Optional[int] = None
    title: Optional[str] = None
    subtitle: Optional[str] = None
    icon: Optional[str] = None
    color_hex: Optional[str] = None
    vocabulary: Optional[List[dict]] = None
    grammar: Optional[List[dict]] = None
    exercises: Optional[List[dict]] = None
    reading: Optional[dict] = None


class ChapterAssignRequest(BaseModel):
    form_ids: List[int]


class AnnouncementCreate(BaseModel):
    title: str
    body: Optional[str] = None
    author: Optional[str] = None


class HomeworkCreate(BaseModel):
    title: str
    chapter_id: Optional[int] = None
    classroom_id: Optional[int] = None
    due_date: Optional[date] = None


class RecordCreate(BaseModel):
    chapter_id: Optional[int] = None
    type: str
    score: Optional[float] = None
    detail: Optional[dict] = None
