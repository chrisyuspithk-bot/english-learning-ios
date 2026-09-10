import Foundation

// MARK: - User

struct User: Identifiable, Codable {
    let id: String
    let name: String          // Chinese name
    let englishName: String
    let grade: String         // e.g. "Primary 5"
    let school: String
    let avatarColorHex: String
}

// MARK: - Textbook & Chapter

struct Textbook: Identifiable, Codable {
    let id: String
    let title: String
    let subject: String
    let grade: String
    let chapters: [Chapter]
}

struct Chapter: Identifiable, Codable {
    let id: String
    let number: Int
    let title: String
    let subtitle: String
    let icon: String          // SF Symbol name
    let colorHex: String
    let vocabulary: [VocabularyItem]
    let grammar: [GrammarConcept]
    let exercises: [MCQuestion]
    let reading: ReadingPassage
}

// MARK: - Vocabulary

struct VocabularyItem: Identifiable, Codable {
    let id: String
    let word: String
    let phonetic: String      // IPA, e.g. /ˈhel.θi/
    let partOfSpeech: String
    let meaning: String       // Chinese meaning
    let definition: String    // simple English definition
    let example: String
}

// MARK: - Grammar

struct GrammarConcept: Identifiable, Codable {
    let id: String
    let title: String
    let explanation: String
    let rule: String
    let examples: [String]
}

// MARK: - Multiple-choice question (shared by Exercise & Reading)

struct MCQuestion: Identifiable, Codable {
    let id: String
    let prompt: String
    let options: [String]
    let correctIndex: Int
    let explanation: String
}

// MARK: - Reading

struct ReadingPassage: Identifiable, Codable {
    let id: String
    let title: String
    let paragraphs: [String]
    let questions: [MCQuestion]
}

// MARK: - Homework & Announcement (dummy)

struct HomeworkSession: Identifiable, Codable {
    let id: String
    let title: String
    let chapterTitle: String
    let type: String          // e.g. "Reading", "Vocabulary"
    let assignedDate: String
    let dueDate: String
    let progress: Double      // 0...1
    let score: Int?           // latest score out of 100
}

struct Announcement: Identifiable, Codable {
    let id: String
    let title: String
    let date: String
    let author: String
    let body: String
}


// MARK: - Chapter summary (list view)

struct ChapterSummary: Identifiable {
    let id: String
    let number: Int
    let title: String
    let subtitle: String
    let icon: String
    let colorHex: String
}

// MARK: - Backend API DTOs (decode the REST responses)

struct LoginResponse: Decodable {
    let token: String
    let user: LoginUser
}

struct LoginUser: Decodable {
    let id: Int
    let username: String
    let englishName: String
}

struct DashboardResponse: Decodable {
    let student: StudentDTO
    let `class`: ClassDTO?
    let chapters: [ChapterSummaryDTO]
    let homework: [HomeworkDTO]
    let announcements: [AnnouncementDTO]
}

struct StudentDTO: Decodable {
    let id: Int
    let englishName: String
    let chineseName: String?
}

struct ClassDTO: Decodable {
    let id: Int
    let formId: Int
    let name: String
    let formName: String?
}

struct ChapterSummaryDTO: Decodable {
    let id: Int
    let number: Int?
    let title: String
    let subtitle: String?
    let icon: String?
    let colorHex: String?
}

struct HomeworkDTO: Decodable {
    let id: Int
    let title: String
    let chapterId: Int?
    let chapterTitle: String?
    let dueDate: String?
    let createdAt: String?
}

struct AnnouncementDTO: Decodable {
    let id: Int
    let title: String
    let body: String?
    let author: String?
    let createdAt: String?
}

struct ChapterDetailResponse: Decodable {
    let id: Int
    let number: Int?
    let title: String
    let subtitle: String?
    let icon: String?
    let colorHex: String?
    let vocabulary: [VocabularyDTO]
    let grammar: [GrammarDTO]
    let exercises: [ExerciseDTO]
    let reading: ReadingDTO
}

struct VocabularyDTO: Decodable {
    let word: String
    let phonetic: String?
    let partOfSpeech: String?
    let meaning: String?
    let definition: String?
    let example: String?
}

struct GrammarDTO: Decodable {
    let title: String
    let explanation: String?
    let rule: String?
    let examples: [String]?
}

struct ExerciseDTO: Decodable {
    let prompt: String
    let options: [String]
    let correctIndex: Int
    let explanation: String?
}

struct ReadingDTO: Decodable {
    let title: String?
    let paragraphs: [String]
    let questions: [ExerciseDTO]
}

// MARK: - DTO → view-model mapping

enum APIMapper {

    static func user(from login: LoginUser) -> User {
        User(id: "\(login.id)", name: "", englishName: login.englishName,
             grade: "", school: "", avatarColorHex: "4F8EF7")
    }

    static func user(from dto: DashboardResponse) -> User {
        User(id: "\(dto.student.id)",
             name: dto.student.chineseName ?? "",
             englishName: dto.student.englishName,
             grade: dto.`class`?.formName ?? "",
             school: "",
             avatarColorHex: "4F8EF7")
    }

    static func chapterSummaries(from dtos: [ChapterSummaryDTO]) -> [ChapterSummary] {
        dtos.map {
            ChapterSummary(id: "\($0.id)",
                           number: $0.number ?? 0,
                           title: $0.title,
                           subtitle: $0.subtitle ?? "",
                           icon: $0.icon ?? "book.fill",
                           colorHex: $0.colorHex ?? "4F8EF7")
        }
    }

    static func homework(from dtos: [HomeworkDTO]) -> [HomeworkSession] {
        dtos.map {
            HomeworkSession(id: "\($0.id)",
                            title: $0.title,
                            chapterTitle: $0.chapterTitle ?? "",
                            type: "Homework",
                            assignedDate: datePart($0.createdAt),
                            dueDate: datePart($0.dueDate),
                            progress: 0,
                            score: nil)
        }
    }

    static func announcements(from dtos: [AnnouncementDTO]) -> [Announcement] {
        dtos.map {
            Announcement(id: "\($0.id)",
                         title: $0.title,
                         date: datePart($0.createdAt),
                         author: $0.author ?? "",
                         body: $0.body ?? "")
        }
    }

    static func chapter(from dto: ChapterDetailResponse) -> Chapter {
        Chapter(
            id: "\(dto.id)",
            number: dto.number ?? 0,
            title: dto.title,
            subtitle: dto.subtitle ?? "",
            icon: dto.icon ?? "book.fill",
            colorHex: dto.colorHex ?? "4F8EF7",
            vocabulary: dto.vocabulary.enumerated().map { idx, v in
                VocabularyItem(id: "\(dto.id)-v\(idx)",
                               word: v.word,
                               phonetic: v.phonetic ?? "",
                               partOfSpeech: v.partOfSpeech ?? "",
                               meaning: v.meaning ?? "",
                               definition: v.definition ?? "",
                               example: v.example ?? "")
            },
            grammar: dto.grammar.enumerated().map { idx, g in
                GrammarConcept(id: "\(dto.id)-g\(idx)",
                               title: g.title,
                               explanation: g.explanation ?? "",
                               rule: g.rule ?? "",
                               examples: g.examples ?? [])
            },
            exercises: dto.exercises.enumerated().map { idx, e in
                MCQuestion(id: "\(dto.id)-e\(idx)",
                           prompt: e.prompt,
                           options: e.options,
                           correctIndex: e.correctIndex,
                           explanation: e.explanation ?? "")
            },
            reading: ReadingPassage(
                id: "\(dto.id)-r",
                title: dto.reading.title ?? dto.title,
                paragraphs: dto.reading.paragraphs,
                questions: dto.reading.questions.enumerated().map { idx, q in
                    MCQuestion(id: "\(dto.id)-rq\(idx)",
                               prompt: q.prompt,
                               options: q.options,
                               correctIndex: q.correctIndex,
                               explanation: q.explanation ?? "")
                }
            )
        )
    }

    private static func datePart(_ iso: String?) -> String {
        guard let iso = iso, iso.count >= 10 else { return iso ?? "" }
        return String(iso.prefix(10))
    }
}
