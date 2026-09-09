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
