package com.example.englishlearning

import android.content.Context
import com.example.englishlearning.data.remote.ApiService
import com.example.englishlearning.data.remote.AuthInterceptor
import com.example.englishlearning.data.remote.RetrofitClient
import com.example.englishlearning.data.remote.TokenStore
import com.example.englishlearning.data.repository.AuthRepository
import com.example.englishlearning.data.repository.ContentRepository
import com.example.englishlearning.data.repository.RecordRepository
import com.example.englishlearning.speech.SpeechRecognizerManager
import com.example.englishlearning.speech.TtsManager

/** Simple manual dependency container (no DI framework needed for this size). */
class AppContainer(context: Context) {

    private val appContext = context.applicationContext

    val tokenStore = TokenStore()
    private val api: ApiService = RetrofitClient.create(AuthInterceptor(tokenStore))

    val authRepository = AuthRepository(api, tokenStore)
    val contentRepository = ContentRepository(api)
    val recordRepository = RecordRepository(api)

    val ttsManager = TtsManager(appContext)
    val speechManager = SpeechRecognizerManager(appContext)
}
