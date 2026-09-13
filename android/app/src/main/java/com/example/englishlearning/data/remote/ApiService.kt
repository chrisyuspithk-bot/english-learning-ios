package com.example.englishlearning.data.remote

import com.example.englishlearning.data.remote.dto.ChapterDetailResponse
import com.example.englishlearning.data.remote.dto.DashboardResponse
import com.example.englishlearning.data.remote.dto.LoginRequest
import com.example.englishlearning.data.remote.dto.LoginResponse
import com.example.englishlearning.data.remote.dto.RecordRequest
import com.example.englishlearning.data.remote.dto.RecordResponse
import retrofit2.http.Body
import retrofit2.http.GET
import retrofit2.http.POST
import retrofit2.http.Path

/**
 * Mirrors the app-facing REST API exposed by the FastAPI backend:
 *   POST /api/auth/student/login
 *   GET  /api/app/dashboard
 *   GET  /api/app/chapters/{id}
 *   POST /api/app/records
 *   GET  /api/app/records
 */
interface ApiService {

    @POST("api/auth/student/login")
    suspend fun login(@Body body: LoginRequest): LoginResponse

    @GET("api/app/dashboard")
    suspend fun dashboard(): DashboardResponse

    @GET("api/app/chapters/{id}")
    suspend fun chapter(@Path("id") id: String): ChapterDetailResponse

    @POST("api/app/records")
    suspend fun submitRecord(@Body body: RecordRequest): RecordResponse

    @GET("api/app/records")
    suspend fun records(): List<RecordResponse>
}
