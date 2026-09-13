package com.example.englishlearning.speech

import android.content.Context
import android.speech.tts.TextToSpeech
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import java.util.Locale

/**
 * Thin wrapper over Android's native [TextToSpeech]. It plays the same role as
 * the iOS `SystemTTSProvider` (the fallback `AVSpeechSynthesizer` path); a
 * Piper adapter could be swapped in here the same way `PiperTTSProvider` is.
 */
class TtsManager(context: Context) {

    private var tts: TextToSpeech? = null

    private val _ready = MutableStateFlow(false)
    val ready: StateFlow<Boolean> = _ready.asStateFlow()

    init {
        tts = TextToSpeech(context.applicationContext) { status ->
            if (status == TextToSpeech.SUCCESS) {
                val result = tts?.setLanguage(Locale.US)
                _ready.value =
                    result != TextToSpeech.LANG_MISSING_DATA &&
                    result != TextToSpeech.LANG_NOT_SUPPORTED
            }
        }
    }

    /**
     * @param rate iOS-style rate (0..1, where 0.5 is normal). It is scaled to
     * Android's `setSpeechRate` range so the iOS call sites (0.35..0.45) feel
     * the same — slightly slower than the default voice.
     */
    fun speak(text: String, rate: Float = 0.45f) {
        val engine = tts ?: return
        if (text.isBlank()) return
        engine.stop()
        engine.setSpeechRate((rate * 2f).coerceIn(0.2f, 2f))
        engine.setPitch(1f)
        engine.speak(text, TextToSpeech.QUEUE_FLUSH, null, "tts-${System.nanoTime()}")
    }

    fun stop() {
        tts?.stop()
    }

    fun shutdown() {
        tts?.stop()
        tts?.shutdown()
        tts = null
    }
}
