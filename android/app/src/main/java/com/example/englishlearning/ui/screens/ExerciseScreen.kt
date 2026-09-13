package com.example.englishlearning.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.mutableStateMapOf
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.example.englishlearning.AppContainer
import com.example.englishlearning.data.model.Chapter
import com.example.englishlearning.ui.components.McqCard
import com.example.englishlearning.ui.theme.colorFromHex

@Composable
fun ExerciseScreen(container: AppContainer, chapter: Chapter) {
    val results = remember { mutableStateMapOf<String, Boolean>() }
    val answeredCorrect = results.values.count { it }
    val accent = colorFromHex(chapter.colorHex)

    LazyColumn(
        modifier = Modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background),
        contentPadding = PaddingValues(vertical = 16.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        item {
            ScoreSummary(answeredCorrect, chapter.exercises.size, accent)
        }

        items(chapter.exercises) { question ->
            McqCard(
                question = question,
                accent = accent,
                modifier = Modifier.padding(horizontal = 16.dp),
                onResult = { correct -> results[question.id] = correct }
            )
        }
    }
}

@Composable
private fun ScoreSummary(answeredCorrect: Int, total: Int, accent: androidx.compose.ui.graphics.Color) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp)
            .clip(androidx.compose.foundation.shape.RoundedCornerShape(16.dp))
            .background(MaterialTheme.colorScheme.surface)
            .padding(16.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        Box(
            modifier = Modifier
                .size(56.dp)
                .clip(CircleShape)
                .background(accent.copy(alpha = 0.25f)),
            contentAlignment = Alignment.Center
        ) {
            Text(
                "$answeredCorrect/$total",
                style = MaterialTheme.typography.titleSmall,
                fontWeight = FontWeight.Bold,
                color = accent
            )
        }
        Column(verticalArrangement = Arrangement.spacedBy(2.dp)) {
            Text("Multiple-choice practice", style = MaterialTheme.typography.titleMedium)
            Text(
                "Choose the best answer for each question.",
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
    }
}
