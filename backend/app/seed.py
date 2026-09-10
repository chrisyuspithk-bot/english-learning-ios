from datetime import date

from .database import SessionLocal
from .models import (AcademicYear, Admin, Announcement, Chapter,
                     ChapterAssignment, Classroom, Form, Homework, Student,
                     Textbook)
from .security import hash_password


def _seed_sample(db):
    ay = AcademicYear(name="2026-2027", start_date=date(2026, 9, 1), end_date=date(2027, 6, 30), is_current=True)
    db.add(ay)
    db.flush()

    forms = {}
    for level in range(1, 7):
        forms[level] = Form(academic_year_id=ay.id, name=f"Primary {level}", level=level)
    db.add_all(forms.values())
    db.flush()

    p5 = forms[5]

    # one class per form, plus an extra class under Primary 5
    class_by_form = {level: Classroom(form_id=form.id, name=f"{level}A") for level, form in forms.items()}
    c5a = class_by_form[5]
    c5b = Classroom(form_id=p5.id, name="5B")
    db.add_all(list(class_by_form.values()) + [c5b])
    db.flush()

    db.add_all([
        Student(classroom_id=c5a.id, student_number="S5001", english_name="Amy Chan",
                chinese_name="陳小美", gender="F", date_of_birth=date(2015, 3, 12),
                guardian_name="Mr Chan", guardian_phone="98765432", guardian_email="parent@example.com",
                username="amy", password_hash=hash_password("student123"), status="active"),
        Student(classroom_id=c5a.id, student_number="S5002", english_name="Ben Lee",
                chinese_name="李志明", gender="M", date_of_birth=date(2015, 7, 4),
                guardian_name="Mrs Lee", guardian_phone="91234567", guardian_email="lee@example.com",
                username="ben", password_hash=hash_password("student123"), status="active"),
    ])

    textbook = Textbook(title="Primary 5 English", subject="English", level="Primary 5")
    db.add(textbook)
    db.flush()

    chapter = Chapter(
        textbook_id=textbook.id,
        number=1,
        title="Healthy Living",
        subtitle="Eating well and staying active",
        icon="leaf.fill",
        color_hex="4F8EF7",
        vocabulary=[
            {"word": "healthy", "phonetic": "/ˈhel.θi/", "partOfSpeech": "adjective",
             "meaning": "健康的", "definition": "good for your body and mind",
             "example": "Eating fruit is a healthy habit."},
            {"word": "exercise", "phonetic": "/ˈek.sə.saɪz/", "partOfSpeech": "noun",
             "meaning": "運動", "definition": "activity that keeps your body fit",
             "example": "Running is good exercise."},
            {"word": "vegetable", "phonetic": "/ˈvedʒ.tə.bəl/", "partOfSpeech": "noun",
             "meaning": "蔬菜", "definition": "a plant that you can eat",
             "example": "Broccoli is a green vegetable."},
            {"word": "energy", "phonetic": "/ˈen.ə.dʒi/", "partOfSpeech": "noun",
             "meaning": "能量", "definition": "the power to be active and do things",
             "example": "Breakfast gives us energy in the morning."},
            {"word": "balance", "phonetic": "/ˈbæl.əns/", "partOfSpeech": "noun",
             "meaning": "平衡", "definition": "having the right amount of different things",
             "example": "We need a balance of work and play."},
            {"word": "habit", "phonetic": "/ˈhæb.ɪt/", "partOfSpeech": "noun",
             "meaning": "習慣", "definition": "something you do often without thinking",
             "example": "Brushing your teeth is a good habit."},
        ],
        grammar=[
            {"title": "Imperatives for giving advice", "explanation": "We use the base form of the verb to tell someone what to do.",
             "rule": "Use the base verb with no subject for commands and advice.",
             "examples": ["Eat more vegetables.", "Drink plenty of water.", "Do not skip breakfast."]},
            {"title": "Countable and uncountable nouns", "explanation": "Countable nouns can be counted; uncountable nouns cannot.",
             "rule": "Use 'a/an' with countable nouns and 'some' with uncountable nouns.",
             "examples": ["an apple (countable)", "some water (uncountable)"]},
        ],
        exercises=[
            {"prompt": "Which sentence is correct?", "options": ["Eat more vegetables.", "Eating more vegetables.", "To eat more vegetables."], "correctIndex": 0, "explanation": "Imperatives use the base form of the verb."},
            {"prompt": "Choose the uncountable noun.", "options": ["apple", "water", "carrot", "egg"], "correctIndex": 1, "explanation": "'Water' cannot be counted with a number."},
            {"prompt": "Which word means 'good for your body and mind'?", "options": ["healthy", "energy", "habit", "balance"], "correctIndex": 0, "explanation": "'Healthy' describes something good for you."},
        ],
        reading={
            "title": "A Healthy Day",
            "paragraphs": [
                "Tom is a Primary 5 student. Every morning he wakes up at seven o'clock and eats a healthy breakfast with eggs, bread and milk.",
                "After school, Tom plays football with his friends for one hour. He also eats fruit and vegetables at lunch and dinner.",
                "Tom knows that good habits keep his body strong. He sleeps early so he has enough energy for the next day."
            ],
            "questions": [
                {"prompt": "What time does Tom wake up?", "options": ["Six o'clock", "Seven o'clock", "Eight o'clock", "Nine o'clock"], "correctIndex": 1, "explanation": "The passage says he wakes up at seven o'clock."},
                {"prompt": "What does Tom eat for breakfast?", "options": ["Rice and fish", "Eggs, bread and milk", "Noodles only", "Nothing"], "correctIndex": 1, "explanation": "He eats eggs, bread and milk."},
                {"prompt": "What sport does Tom play after school?", "options": ["Basketball", "Swimming", "Football", "Running"], "correctIndex": 2, "explanation": "He plays football with his friends."},
                {"prompt": "Why does Tom sleep early?", "options": ["To have energy", "To watch TV", "To play games", "He is not tired"], "correctIndex": 0, "explanation": "He sleeps early so he has enough energy."},
                {"prompt": "What is the main idea of the passage?", "options": ["Tom hates school", "Good habits keep us healthy", "Football is hard", "Breakfast is not important"], "correctIndex": 1, "explanation": "The passage is about how good habits keep us healthy."},
            ],
        },
    )
    db.add(chapter)
    db.flush()
    db.add(ChapterAssignment(chapter_id=chapter.id, form_id=p5.id))

    db.add(Announcement(title="Welcome back to school!",
                        body="Please remember to bring your reading books tomorrow.",
                        author="Miss Wong"))
    db.add(Homework(title="Read 'A Healthy Day' and answer the questions",
                    chapter_id=chapter.id, classroom_id=c5a.id, due_date=date(2026, 9, 20)))

    db.commit()


def seed_if_empty():
    db = SessionLocal()
    try:
        if db.query(Admin).count() == 0:
            db.add(Admin(username="admin", password_hash=hash_password("admin123"), name="Administrator"))
            db.commit()
        if db.query(AcademicYear).count() == 0:
            _seed_sample(db)
    finally:
        db.close()
