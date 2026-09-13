package com.example.englishlearning.data.remote

import com.example.englishlearning.data.model.Announcement
import com.example.englishlearning.data.model.Chapter
import com.example.englishlearning.data.model.ChapterSummary
import com.example.englishlearning.data.model.GrammarConcept
import com.example.englishlearning.data.model.HomeworkSession
import com.example.englishlearning.data.model.MCQuestion
import com.example.englishlearning.data.model.ReadingPassage
import com.example.englishlearning.data.model.User
import com.example.englishlearning.data.model.VocabularyItem
import com.example.englishlearning.data.remote.dto.ChapterDetailResponse
import com.example.englishlearning.data.remote.dto.ChapterSummaryDto
import com.example.englishlearning.data.remote.dto.DashboardResponse
import com.example.englishlearning.data.remote.dto.LoginUser

/** DTO -> domain mapping, mirroring the iOS `APIMapper`. */
object ApiMapper {

    fun user(login: LoginUser): User = User(
        id = login.id.toString(),
        name = "",
        englishName = login.englishName,
        grade = "",
        school = "",
        avatarColorHex = "4F8EF7"
    )

    fun user(dto: DashboardResponse): User = User(
        id = dto.student.id.toString(),
        name = dto.student.chineseName.orEmpty(),
        englishName = dto.student.englishName.orEmpty(),
        grade = dto.classroom?.formName.orEmpty(),
        school = "",
        avatarColorHex = "4F8EF7"
    )

    fun chapterSummaries(dtos: List<ChapterSummaryDto>?): List<ChapterSummary> =
        dtos.orEmpty().map {
            ChapterSummary(
                id = it.id.toString(),
                number = it.number ?: 0,
                title = it.title,
                subtitle = it.subtitle.orEmpty(),
                icon = it.icon ?: "book.fill",
                colorHex = it.colorHex ?: "4F8EF7"
            )
        }

    fun homework(dtos: List<com.example.englishlearning.data.remote.dto.HomeworkDto>?): List<HomeworkSession> =
        dtos.orEmpty().map {
            HomeworkSession(
                id = it.id.toString(),
                title = it.title,
                chapterTitle = it.chapterTitle.orEmpty(),
                type = "Homework",
                assignedDate = datePart(it.createdAt),
                dueDate = datePart(it.dueDate),
                progress = 0.0,
                score = null
            )
        }

    fun announcements(dtos: List<com.example.englishlearning.data.remote.dto.AnnouncementDto>?): List<Announcement> =
        dtos.orEmpty().map {
            Announcement(
                id = it.id.toString(),
                title = it.title,
                date = datePart(it.createdAt),
                author = it.author.orEmpty(),
                body = it.body.orEmpty()
            )
        }

    fun chapter(dto: ChapterDetailResponse): Chapter = Chapter(
        id = dto.id.toString(),
        number = dto.number ?: 0,
        title = dto.title,
        subtitle = dto.subtitle.orEmpty(),
        icon = dto.icon ?: "book.fill",
        colorHex = dto.colorHex ?: "4F8EF7",
        vocabulary = dto.vocabulary.orEmpty().mapIndexed { idx, v ->
            VocabularyItem(
                id = "${dto.id}-v$idx",
                word = v.word,
                phonetic = v.phonetic.orEmpty(),
                partOfSpeech = v.partOfSpeech.orEmpty(),
                meaning = v.meaning.orEmpty(),
                definition = v.definition.orEmpty(),
                example = v.example.orEmpty()
            )
        },
        grammar = dto.grammar.orEmpty().mapIndexed { idx, g ->
            GrammarConcept(
                id = "${dto.id}-g$idx",
                title = g.title,
                explanation = g.explanation.orEmpty(),
                rule = g.rule.orEmpty(),
                examples = g.examples.orEmpty()
            )
        },
        exercises = dto.exercises.orEmpty().mapIndexed { idx, e ->
            MCQuestion(
                id = "${dto.id}-e$idx",
                prompt = e.prompt,
                options = e.options,
                correctIndex = e.correctIndex,
                explanation = e.explanation.orEmpty()
            )
        },
        reading = ReadingPassage(
            id = "${dto.id}-r",
            title = dto.reading?.title ?: dto.title,
            paragraphs = dto.reading?.paragraphs.orEmpty(),
            questions = dto.reading?.questions.orEmpty().mapIndexed { idx, q ->
                MCQuestion(
                    id = "${dto.id}-rq$idx",
                    prompt = q.prompt,
                    options = q.options,
                    correctIndex = q.correctIndex,
                    explanation = q.explanation.orEmpty()
                )
            }
        )
    )

    private fun datePart(iso: String?): String =
        if (iso != null && iso.length >= 10) iso.take(10) else iso.orEmpty()
}
