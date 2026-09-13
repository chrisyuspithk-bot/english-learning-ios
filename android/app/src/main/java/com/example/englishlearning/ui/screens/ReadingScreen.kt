package com.example.englishlearning.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.VolumeUp
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.example.englishlearning.AppContainer
import com.example.englishlearning.data.model.Chapter
import com.example.englishlearning.ui.components.AppCard
import com.example.englishlearning.ui.components.McqCard
import com.example.englishlearning.ui.components.SectionHeader
import com.example.englishlearning.ui.theme.AppIcons
import com.example.englishlearning.ui.theme.PrimaryBlue
import com.example.englishlearning.ui.theme.colorFromHex

@Composable
fun ReadingScreen(container: AppContainer, chapter: Chapter) {
    val passage = chapter.reading
    val accent = colorFromHex(chapter.colorHex)

    LazyColumn(
        modifier = Modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background),
        contentPadding = PaddingValues(vertical = 16.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        item {
            AppCard(accent = accent, modifier = Modifier.padding(horizontal = 16.dp)) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Text(passage.title, style = MaterialTheme.typography.titleMedium, modifier = Modifier.weight(1f))
                    TextButton(onClick = {
                        container.ttsManager.speak(passage.paragraphs.joinToString(" "), rate = 0.42f)
                    }) {
                        Icon(Icons.Filled.VolumeUp, contentDescription = null, modifier = Modifier.size(18.dp))
                        Spacer(Modifier.size(6.dp))
                        Text("Read aloud", color = PrimaryBlue, fontWeight = FontWeight.SemiBold)
                    }
                }
                passage.paragraphs.forEach { paragraph ->
                    Text(
                        paragraph,
                        style = MaterialTheme.typography.bodyLarge,
                        modifier = Modifier.fillMaxWidth()
                    )
                }
            }
        }

        item {
            SectionHeader("Comprehension questions", AppIcons.Help)
        }

        items(passage.questions) { question ->
            McqCard(
                question = question,
                accent = accent,
                modifier = Modifier.padding(horizontal = 16.dp)
            )
        }
    }
}
