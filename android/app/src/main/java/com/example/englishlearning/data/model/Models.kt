package com.example.englishlearning.data.model

/**
 * Domain models. These mirror the iOS `Models.swift` types and are what the UI
 * layer works with. DTOs are mapped into these in [com.example.englishlearning.data.remote.ApiMapper].
 */

data class User(
    val id: String,
    val name: String,
    val englishName: String,
    val grade: String,
    val school: String,
    val avatarColorHex: String
)

data class ChapterSummary(
    val id: String,
    val number: Int,
    val title: String,
    val subtitle: String,
    val icon: String,
    val colorHex: String
)

data class Chapter(
    val id: String,
    val number: Int,
    val title: String,
    val subtitle: String,
    val icon: String,
    val colorHex: String,
    val vocabulary: List<VocabularyItem>,
    val grammar: List<GrammarConcept>,
    val exercises: List<MCQuestion>,
    val reading: ReadingPassage
)

data class VocabularyItem(
    val id: String,
    val word: String,
    val phonetic: String,
    val partOfSpeech: String,
    val meaning: String,
    val definition: String,
    val example: String
)

data class GrammarConcept(
    val id: String,
    val title: String,
    val explanation: String,
    val rule: String,
    val examples: List<String>
)

data class MCQuestion(
    val id: String,
    val prompt: String,
    val options: List<String>,
    val correctIndex: Int,
    val explanation: String
)

data class ReadingPassage(
    val id: String,
    val title: String,
    val paragraphs: List<String>,
    val questions: List<MCQuestion>
)

data class HomeworkSession(
    val id: String,
    val title: String,
    val chapterTitle: String,
    val type: String,
    val assignedDate: String,
    val dueDate: String,
    val progress: Double,
    val score: Int?
)

data class Announcement(
    val id: String,
    val title: String,
    val date: String,
    val author: String,
    val body: String
)
