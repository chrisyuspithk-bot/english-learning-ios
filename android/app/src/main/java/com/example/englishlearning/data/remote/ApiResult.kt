package com.example.englishlearning.data.remote

import com.google.gson.JsonParser
import retrofit2.HttpException
import java.io.IOException

/** A friendly, user-presentable error message. */
class ApiException(message: String) : Exception(message)

/**
 * Runs a Retrofit suspend call and converts transport/HTTP failures into a
 * [Result]. HTTP error bodies from the FastAPI backend carry a `detail` field,
 * which is surfaced to the user (matching the iOS `APIError` handling).
 */
suspend fun <T> apiCall(block: suspend () -> T): Result<T> = try {
    Result.success(block())
} catch (e: HttpException) {
    Result.failure(ApiException(parseError(e)))
} catch (e: IOException) {
    Result.failure(ApiException("Network error. Please check your connection."))
} catch (e: Exception) {
    Result.failure(ApiException(e.message ?: "Something went wrong."))
}

private fun parseError(e: HttpException): String = try {
    val body = e.response()?.errorBody()?.string()
    if (body.isNullOrBlank()) {
        "Request failed (HTTP ${e.code()})"
    } else {
        val obj = JsonParser.parseString(body).asJsonObject
        obj.get("detail")?.takeIf { !it.isJsonNull }?.asString
            ?: "Request failed (HTTP ${e.code()})"
    }
} catch (_: Exception) {
    "Request failed (HTTP ${e.code()})"
}
