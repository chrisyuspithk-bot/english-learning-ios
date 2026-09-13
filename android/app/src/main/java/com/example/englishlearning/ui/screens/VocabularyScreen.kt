package com.example.englishlearning.ui.screens

import android.Manifest
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Mic
import androidx.compose.material.icons.filled.Stop
import androidx.compose.material.icons.filled.VolumeUp
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Dialog
import androidx.compose.material3.DialogProperties
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.example.englishlearning.AppContainer
import com.example.englishlearning.data.model.Chapter
import com.example.englishlearning.data.model.VocabularyItem
import com.example.englishlearning.speech.PronunciationScorer
import com.example.englishlearning.ui.components.AppCard
import com.example.englishlearning.ui.theme.DangerRed
import com.example.englishlearning.ui.theme.PrimaryBlue
import com.example.englishlearning.ui.theme.SuccessGreen
import com.example.englishlearning.ui.theme.WarningOrange
import com.example.englishlearning.ui.theme.colorFromHex
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

@Composable
fun VocabularyScreen(container: AppContainer, chapter: Chapter) {
    var practiceItem by remember { mutableStateOf<VocabularyItem?>(null) }
    val accent = colorFromHex(chapter.colorHex)

    LazyColumn(
        modifier = Modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background),
        contentPadding = PaddingValues(vertical = 16.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        item {
            Text(
                "Tap a word to practise your pronunciation 🎤",
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                modifier = Modifier.padding(horizontal = 16.dp)
            )
        }

        items(chapter.vocabulary) { item ->
            VocabularyCard(
                item = item,
                accent = accent,
                onListen = { container.ttsManager.speak(item.word, rate = 0.4f) },
                onPractise = { practiceItem = item }
            )
        }
    }

    practiceItem?.let { item ->
        VocabularyPracticeDialog(
            item = item,
            container = container,
            onDismiss = {
                container.speechManager.stop()
                practiceItem = null
            }
        )
    }
}

@Composable
private fun VocabularyCard(
    item: VocabularyItem,
    accent: Color,
    onListen: () -> Unit,
    onPractise: () -> Unit
) {
    AppCard(accent = accent, modifier = Modifier.padding(horizontal = 16.dp)) {
        Row(verticalAlignment = Alignment.Top) {
            Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
                Text(item.word, fontSize = 20.sp, fontWeight = FontWeight.Bold)
                Text(
                    item.phonetic,
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
            Spacer(Modifier.weight(1f))
            Text(
                item.partOfSpeech,
                style = MaterialTheme.typography.labelSmall,
                fontWeight = FontWeight.SemiBold,
                color = accent,
                modifier = Modifier
                    .background(accent.copy(alpha = 0.15f), RoundedCornerShape(6.dp))
                    .padding(horizontal = 8.dp, vertical = 4.dp)
            )
        }

        Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            Button(
                onClick = onListen,
                colors = ButtonDefaults.buttonColors(
                    containerColor = PrimaryBlue.copy(alpha = 0.12f),
                    contentColor = PrimaryBlue
                ),
                contentPadding = PaddingValues(horizontal = 14.dp, vertical = 8.dp)
            ) {
                Icon(Icons.Filled.VolumeUp, contentDescription = null, modifier = Modifier.size(18.dp))
                Spacer(Modifier.size(6.dp))
                Text("Listen", fontWeight = FontWeight.SemiBold)
            }

            Button(
                onClick = onPractise,
                colors = ButtonDefaults.buttonColors(
                    containerColor = accent.copy(alpha = 0.15f),
                    contentColor = accent
                ),
                contentPadding = PaddingValues(horizontal = 14.dp, vertical = 8.dp)
            ) {
                Icon(Icons.Filled.Mic, contentDescription = null, modifier = Modifier.size(18.dp))
                Spacer(Modifier.size(6.dp))
                Text("Practise", fontWeight = FontWeight.SemiBold)
            }
        }

        Text(item.meaning, style = MaterialTheme.typography.bodyLarge, fontWeight = FontWeight.Medium)
        Text(
            item.definition,
            style = MaterialTheme.typography.bodyMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
        Text(
            "\"${item.example}\"",
            style = MaterialTheme.typography.bodySmall,
            fontStyle = FontStyle.Italic,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
    }
}

@Composable
private fun VocabularyPracticeDialog(
    item: VocabularyItem,
    container: AppContainer,
    onDismiss: () -> Unit
) {
    val speechManager = container.speechManager
    val isListening by speechManager.isListening.collectAsStateWithLifecycle()
    val transcript by speechManager.transcript.collectAsStateWithLifecycle()
    val speechError by speechManager.error.collectAsStateWithLifecycle()

    var resultText by remember { mutableStateOf<String?>(null) }
    var resultColor by remember { mutableStateOf(Color.Gray) }
    var errorText by remember { mutableStateOf<String?>(null) }

    val scope = rememberCoroutineScope()

    val permissionLauncher = rememberLauncherForActivityResult(
        ActivityResultContracts.RequestPermission()
    ) { granted ->
        if (granted) {
            errorText = null
            speechManager.start()
        } else {
            errorText = "Microphone access is needed to practise pronunciation."
        }
    }

    fun stopAndScore() {
        speechManager.stop()
        scope.launch {
            // Give the recogniser a moment to deliver its final result.
            delay(500)
            val score = PronunciationScorer.score(speechManager.transcript.value, item.word)
            val percent = (score * 100).toInt()
            when {
                score >= 0.85 -> {
                    resultText = "Great job! 🎉 ($percent%)"
                    resultColor = SuccessGreen
                }
                score >= 0.6 -> {
                    resultText = "Close! Listen again and try. ($percent%)"
                    resultColor = WarningOrange
                }
                else -> {
                    resultText = "Keep practising — you can do it! ($percent%)"
                    resultColor = DangerRed
                }
            }
        }
    }

    Dialog(
        onDismissRequest = onDismiss,
        properties = DialogProperties(usePlatformDefaultWidth = false)
    ) {
        Surface(
            shape = RoundedCornerShape(24.dp),
            color = MaterialTheme.colorScheme.background,
            modifier = Modifier
                .fillMaxWidth()
                .padding(24.dp)
        ) {
            Column(
                modifier = Modifier
                    .verticalScroll(rememberScrollState())
                    .padding(24.dp),
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                Text(item.word, fontSize = 44.sp, fontWeight = FontWeight.Bold)
                Text(
                    item.phonetic,
                    style = MaterialTheme.typography.titleMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
                Text(
                    item.meaning,
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )

                TextButton(onClick = { container.ttsManager.speak(item.word, rate = 0.35f) }) {
                    Icon(Icons.Filled.VolumeUp, contentDescription = null)
                    Spacer(Modifier.size(8.dp))
                    Text("Hear the word", color = PrimaryBlue, fontWeight = FontWeight.SemiBold)
                }

                Surface(
                    onClick = {
                        resultText = null
                        errorText = null
                        when {
                            !speechManager.hasRecordPermission() ->
                                permissionLauncher.launch(Manifest.permission.RECORD_AUDIO)
                            isListening -> stopAndScore()
                            else -> speechManager.start()
                        }
                    },
                    shape = CircleShape,
                    color = if (isListening) DangerRed else PrimaryBlue,
                    modifier = Modifier.size(96.dp)
                ) {
                    Box(contentAlignment = Alignment.Center) {
                        Icon(
                            if (isListening) Icons.Filled.Stop else Icons.Filled.Mic,
                            contentDescription = if (isListening) "Stop" else "Record",
                            tint = Color.White,
                            modifier = Modifier.size(36.dp)
                        )
                    }
                }

                Text(
                    if (isListening) "Listening… say the word" else "Tap to record",
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )

                if (transcript.isNotEmpty()) {
                    Text(
                        "\"$transcript\"",
                        style = MaterialTheme.typography.titleMedium,
                        textAlign = TextAlign.Center,
                        modifier = Modifier.fillMaxWidth()
                    )
                }

                resultText?.let {
                    Text(
                        it,
                        style = MaterialTheme.typography.titleMedium,
                        color = resultColor,
                        textAlign = TextAlign.Center
                    )
                }

                val displayError = speechError ?: errorText
                if (displayError != null) {
                    Text(
                        displayError,
                        style = MaterialTheme.typography.bodySmall,
                        color = DangerRed,
                        textAlign = TextAlign.Center,
                        modifier = Modifier.fillMaxWidth()
                    )
                }

                TextButton(onClick = onDismiss) {
                    Text("Done", color = PrimaryBlue, fontWeight = FontWeight.SemiBold)
                }
            }
        }
    }
}
