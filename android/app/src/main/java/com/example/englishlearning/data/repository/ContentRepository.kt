package com.example.englishlearning.data.repository

import com.example.englishlearning.data.model.Announcement
import com.example.englishlearning.data.model.Chapter
import com.example.englishlearning.data.model.ChapterSummary
import com.example.englishlearning.data.model.HomeworkSession
import com.example.englishlearning.data.model.User
import com.example.englishlearning.data.remote.ApiMapper
import com.example.englishlearning.data.remote.ApiService
import com.example.englishlearning.data.remote.apiCall

data class DashboardPayload(
    val user: User,
    val chapters: List<ChapterSummary>,
    val homework: List<HomeworkSession>,
    val announcements: List<Announcement>
)

class ContentRepository(private val api: ApiService) {

    suspend fun dashboard(): Result<DashboardPayload> = apiCall {
        val response = api.dashboard()
        DashboardPayload(
            user = ApiMapper.user(response),
            chapters = ApiMapper.chapterSummaries(response.chapters),
            homework = ApiMapper.homework(response.homework),
            announcements = ApiMapper.announcements(response.announcements)
        )
    }

    suspend fun chapter(id: String): Result<Chapter> = apiCall {
        ApiMapper.chapter(api.chapter(id))
    }
}
