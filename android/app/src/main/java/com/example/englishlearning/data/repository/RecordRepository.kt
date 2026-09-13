package com.example.englishlearning.data.repository

import com.example.englishlearning.data.remote.ApiService
import com.example.englishlearning.data.remote.apiCall
import com.example.englishlearning.data.remote.dto.RecordRequest
import com.example.englishlearning.data.remote.dto.RecordResponse

/**
 * Wraps `POST /api/app/records` and `GET /api/app/records`. The iOS POC exposes
 * these endpoints but its views do not call them; they are kept here so the
 * Android app can submit Exercise / Vocabulary / Reading results when needed.
 */
class RecordRepository(private val api: ApiService) {

    suspend fun submitRecord(
        chapterId: String?,
        type: String,
        score: Double?,
        detail: Map<String, Any?>? = null
    ): Result<RecordResponse> = apiCall {
        api.submitRecord(
            RecordRequest(
                chapterId = chapterId?.toIntOrNull(),
                type = type,
                score = score,
                detail = detail
            )
        )
    }

    suspend fun records(): Result<List<RecordResponse>> = apiCall { api.records() }
}
