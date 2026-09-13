package com.example.englishlearning.data.repository

import com.example.englishlearning.data.model.User
import com.example.englishlearning.data.remote.ApiException
import com.example.englishlearning.data.remote.ApiMapper
import com.example.englishlearning.data.remote.ApiService
import com.example.englishlearning.data.remote.TokenStore
import com.example.englishlearning.data.remote.apiCall
import com.example.englishlearning.data.remote.dto.LoginRequest

class AuthRepository(
    private val api: ApiService,
    private val tokenStore: TokenStore
) {
    suspend fun login(username: String, password: String): Result<User> {
        val name = username.trim()
        if (name.isEmpty() || password.isEmpty()) {
            return Result.failure(ApiException("Please enter your username and password."))
        }
        return apiCall {
            val response = api.login(LoginRequest(username = name, password = password))
            tokenStore.token = response.token
            ApiMapper.user(response.user)
        }
    }

    fun logout() {
        tokenStore.token = null
    }
}
