from datetime import datetime

from sqlalchemy import (JSON, Boolean, Column, Date, DateTime, Float, ForeignKey,
                        Integer, String, Text)
from sqlalchemy.orm import relationship

from .database import Base


def now():
    return datetime.utcnow()


class AcademicYear(Base):
    __tablename__ = "academic_years"

    id = Column(Integer, primary_key=True)
    name = Column(String, unique=True, nullable=False)
    start_date = Column(Date, nullable=True)
    end_date = Column(Date, nullable=True)
    is_current = Column(Boolean, default=False)
    created_at = Column(DateTime, default=now)

    forms = relationship("Form", back_populates="academic_year", cascade="all, delete-orphan")


class Form(Base):
    __tablename__ = "forms"

    id = Column(Integer, primary_key=True)
    academic_year_id = Column(Integer, ForeignKey("academic_years.id"), nullable=False)
    name = Column(String, nullable=False)
    level = Column(Integer, nullable=True)
    created_at = Column(DateTime, default=now)

    academic_year = relationship("AcademicYear", back_populates="forms")
    classes = relationship("Classroom", back_populates="form", cascade="all, delete-orphan")


class Classroom(Base):
    __tablename__ = "classrooms"

    id = Column(Integer, primary_key=True)
    form_id = Column(Integer, ForeignKey("forms.id"), nullable=False)
    name = Column(String, nullable=False)
    created_at = Column(DateTime, default=now)

    form = relationship("Form", back_populates="classes")
    students = relationship("Student", back_populates="classroom")


class Student(Base):
    __tablename__ = "students"

    id = Column(Integer, primary_key=True)
    classroom_id = Column(Integer, ForeignKey("classrooms.id"), nullable=True)
    student_number = Column(String, unique=True, nullable=True)
    english_name = Column(String, nullable=False)
    chinese_name = Column(String, nullable=True)
    gender = Column(String, nullable=True)  # "M" / "F"
    date_of_birth = Column(Date, nullable=True)
    guardian_name = Column(String, nullable=True)
    guardian_phone = Column(String, nullable=True)
    guardian_email = Column(String, nullable=True)
    username = Column(String, unique=True, nullable=False)
    password_hash = Column(String, nullable=False)
    status = Column(String, default="active")  # "active" / "disabled"
    created_at = Column(DateTime, default=now)

    classroom = relationship("Classroom", back_populates="students")
    records = relationship("PracticeRecord", back_populates="student", cascade="all, delete-orphan")


class Textbook(Base):
    __tablename__ = "textbooks"

    id = Column(Integer, primary_key=True)
    title = Column(String, nullable=False)
    subject = Column(String, nullable=True)
    level = Column(String, nullable=True)
    created_at = Column(DateTime, default=now)

    chapters = relationship("Chapter", back_populates="textbook", cascade="all, delete-orphan")


class Chapter(Base):
    __tablename__ = "chapters"

    id = Column(Integer, primary_key=True)
    textbook_id = Column(Integer, ForeignKey("textbooks.id"), nullable=False)
    number = Column(Integer, nullable=True)
    title = Column(String, nullable=False)
    subtitle = Column(String, nullable=True)
    icon = Column(String, default="book.fill")
    color_hex = Column(String, default="4F8EF7")
    vocabulary = Column(JSON, default=list)
    grammar = Column(JSON, default=list)
    exercises = Column(JSON, default=list)
    reading = Column(JSON, nullable=True)
    created_at = Column(DateTime, default=now)
    updated_at = Column(DateTime, default=now, onupdate=now)

    textbook = relationship("Textbook", back_populates="chapters")
    assignments = relationship("ChapterAssignment", back_populates="chapter", cascade="all, delete-orphan")


class ChapterAssignment(Base):
    __tablename__ = "chapter_assignments"

    id = Column(Integer, primary_key=True)
    chapter_id = Column(Integer, ForeignKey("chapters.id"), nullable=False)
    form_id = Column(Integer, ForeignKey("forms.id"), nullable=False)

    chapter = relationship("Chapter", back_populates="assignments")
    form = relationship("Form")


class Announcement(Base):
    __tablename__ = "announcements"

    id = Column(Integer, primary_key=True)
    title = Column(String, nullable=False)
    body = Column(Text, nullable=True)
    author = Column(String, nullable=True)
    created_at = Column(DateTime, default=now)


class Homework(Base):
    __tablename__ = "homework"

    id = Column(Integer, primary_key=True)
    title = Column(String, nullable=False)
    chapter_id = Column(Integer, ForeignKey("chapters.id"), nullable=True)
    classroom_id = Column(Integer, ForeignKey("classrooms.id"), nullable=True)
    due_date = Column(Date, nullable=True)
    created_at = Column(DateTime, default=now)


class PracticeRecord(Base):
    __tablename__ = "practice_records"

    id = Column(Integer, primary_key=True)
    student_id = Column(Integer, ForeignKey("students.id"), nullable=False)
    chapter_id = Column(Integer, ForeignKey("chapters.id"), nullable=True)
    type = Column(String, nullable=False)  # "vocabulary" / "exercise" / "reading"
    score = Column(Float, nullable=True)
    detail = Column(JSON, nullable=True)
    created_at = Column(DateTime, default=now)

    student = relationship("Student", back_populates="records")


class Admin(Base):
    __tablename__ = "admins"

    id = Column(Integer, primary_key=True)
    username = Column(String, unique=True, nullable=False)
    password_hash = Column(String, nullable=False)
    name = Column(String, nullable=True)
    created_at = Column(DateTime, default=now)
