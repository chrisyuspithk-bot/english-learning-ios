package com.example.englishlearning.data.remote.dto

import com.google.gson.annotations.SerializedName

/**
 * REST DTOs. The backend mixes snake_case (SQLAlchemy column serialization)
 * with camelCase (chapter JSON stored as-is), so each field is annotated
 * explicitly instead of relying on a single global naming strategy.
 */

data class LoginRequest(
    @SerializedName("username") val username: String,
    @SerializedName("password") val password: String
)

data class LoginResponse(
    @SerializedName("token") val token: String,
    @SerializedName("user") val user: LoginUser
)

data class LoginUser(
    @SerializedName("id") val id: Int,
    @SerializedName("username") val username: String,
    @SerializedName("english_name") val englishName: String,
    @SerializedName("role") val role: String? = null
)

data class DashboardResponse(
    @SerializedName("student") val student: StudentDto,
    @SerializedName("class") val classroom: ClassDto?,
    @SerializedName("chapters") val chapters: List<ChapterSummaryDto>?,
    @SerializedName("homework") val homework: List<HomeworkDto>?,
    @SerializedName("announcements") val announcements: List<AnnouncementDto>?
)

data class StudentDto(
    @SerializedName("id") val id: Int,
    @SerializedName("english_name") val englishName: String?,
    @SerializedName("chinese_name") val chineseName: String?
)

data class ClassDto(
    @SerializedName("id") val id: Int,
    @SerializedName("form_id") val formId: Int?,
    @SerializedName("name") val name: String?,
    @SerializedName("form_name") val formName: String?
)

data class ChapterSummaryDto(
    @SerializedName("id") val id: Int,
    @SerializedName("number") val number: Int?,
    @SerializedName("title") val title: String,
    @SerializedName("subtitle") val subtitle: String?,
    @SerializedName("icon") val icon: String?,
    @SerializedName("colorHex") val colorHex: String?
)

data class HomeworkDto(
    @SerializedName("id") val id: Int,
    @SerializedName("title") val title: String,
    @SerializedName("chapter_id") val chapterId: Int?,
    @SerializedName("chapter_title") val chapterTitle: String?,
    @SerializedName("due_date") val dueDate: String?,
    @SerializedName("created_at") val createdAt: String?
)

data class AnnouncementDto(
    @SerializedName("id") val id: Int,
    @SerializedName("title") val title: String,
    @SerializedName("body") val body: String?,
    @SerializedName("author") val author: String?,
    @SerializedName("created_at") val createdAt: String?
)

data class ChapterDetailResponse(
    @SerializedName("id") val id: Int,
    @SerializedName("number") val number: Int?,
    @SerializedName("title") val title: String,
    @SerializedName("subtitle") val subtitle: String?,
    @SerializedName("icon") val icon: String?,
    @SerializedName("colorHex") val colorHex: String?,
    @SerializedName("vocabulary") val vocabulary: List<VocabularyDto>?,
    @SerializedName("grammar") val grammar: List<GrammarDto>?,
    @SerializedName("exercises") val exercises: List<ExerciseDto>?,
    @SerializedName("reading") val reading: ReadingDto?
)

data class VocabularyDto(
    @SerializedName("word") val word: String,
    @SerializedName("phonetic") val phonetic: String?,
    @SerializedName("partOfSpeech") val partOfSpeech: String?,
    @SerializedName("meaning") val meaning: String?,
    @SerializedName("definition") val definition: String?,
    @SerializedName("example") val example: String?
)

data class GrammarDto(
    @SerializedName("title") val title: String,
    @SerializedName("explanation") val explanation: String?,
    @SerializedName("rule") val rule: String?,
    @SerializedName("examples") val examples: List<String>?
)

data class ExerciseDto(
    @SerializedName("prompt") val prompt: String,
    @SerializedName("options") val options: List<String>,
    @SerializedName("correctIndex") val correctIndex: Int,
    @SerializedName("explanation") val explanation: String?
)

data class ReadingDto(
    @SerializedName("title") val title: String?,
    @SerializedName("paragraphs") val paragraphs: List<String>?,
    @SerializedName("questions") val questions: List<ExerciseDto>?
)

data class RecordRequest(
    @SerializedName("chapter_id") val chapterId: Int?,
    @SerializedName("type") val type: String,
    @SerializedName("score") val score: Double?,
    @SerializedName("detail") val detail: Map<String, Any?>? = null
)

data class RecordResponse(
    @SerializedName("id") val id: Int,
    @SerializedName("student_id") val studentId: Int?,
    @SerializedName("chapter_id") val chapterId: Int?,
    @SerializedName("type") val type: String,
    @SerializedName("score") val score: Double?,
    @SerializedName("detail") val detail: Map<String, Any?>?,
    @SerializedName("created_at") val createdAt: String?
)
