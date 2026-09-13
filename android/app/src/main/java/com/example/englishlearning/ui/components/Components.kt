package com.example.englishlearning.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ColumnScope
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Cancel
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material3.Button
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.example.englishlearning.data.model.MCQuestion
import com.example.englishlearning.ui.theme.PrimaryBlue
import com.example.englishlearning.ui.theme.SuccessGreen
import com.example.englishlearning.ui.theme.DangerRed

/** Rounded, bordered card container — mirrors the iOS `Card` view. */
@Composable
fun AppCard(
    accent: Color,
    modifier: Modifier = Modifier,
    content: @Composable ColumnScope.() -> Unit
) {
    Column(
        modifier = modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(16.dp))
            .background(MaterialTheme.colorScheme.surface)
            .border(1.5.dp, accent.copy(alpha = 0.35f), RoundedCornerShape(16.dp))
            .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp),
        content = content
    )
}

@Composable
fun SectionHeader(title: String, icon: ImageVector = Icons.Filled.CheckCircle) {
    Row(
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(8.dp),
        modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp)
    ) {
        Icon(icon, contentDescription = null, tint = PrimaryBlue)
        Text(title, style = MaterialTheme.typography.titleMedium, fontWeight = FontWeight.Bold)
    }
}

@Composable
fun ProgressBar(value: Double, modifier: Modifier = Modifier) {
    val fraction = value.coerceIn(0.0, 1.0).toFloat()
    Box(
        modifier = modifier
            .fillMaxWidth()
            .height(8.dp)
            .clip(RoundedCornerShape(4.dp))
            .background(Color.Gray.copy(alpha = 0.2f))
    ) {
        Box(
            modifier = Modifier
                .fillMaxWidth(fraction)
                .fillMaxHeight()
                .background(PrimaryBlue, RoundedCornerShape(4.dp))
        )
    }
}

@Composable
fun LoadingIndicator(modifier: Modifier = Modifier) {
    Box(modifier = modifier, contentAlignment = Alignment.Center) {
        CircularProgressIndicator()
    }
}

/**
 * Multiple-choice question card with instant marking and an explanation.
 * Mirrors the iOS `MCQCard` shared by the Exercise and Reading sections.
 */
@Composable
fun McqCard(
    question: MCQuestion,
    accent: Color,
    modifier: Modifier = Modifier,
    onResult: ((Boolean) -> Unit)? = null
) {
    var selectedIndex by remember(question.id) { mutableStateOf<Int?>(null) }
    var didCheck by remember(question.id) { mutableStateOf(false) }
    val isCorrect = selectedIndex == question.correctIndex

    Column(
        modifier = modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(16.dp))
            .background(MaterialTheme.colorScheme.surface)
            .border(1.5.dp, accent.copy(alpha = 0.35f), RoundedCornerShape(16.dp))
            .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(14.dp)
    ) {
        Text(question.prompt, style = MaterialTheme.typography.titleMedium, fontWeight = FontWeight.SemiBold)

        question.options.forEachIndexed { index, option ->
            OptionRow(
                index = index,
                option = option,
                selectedIndex = selectedIndex,
                didCheck = didCheck,
                correctIndex = question.correctIndex,
                onSelect = { if (!didCheck) selectedIndex = index }
            )
        }

        if (didCheck) {
            ResultView(
                isCorrect = isCorrect,
                explanation = question.explanation,
                onReset = {
                    selectedIndex = null
                    didCheck = false
                }
            )
        } else {
            Button(
                onClick = {
                    if (selectedIndex != null) {
                        didCheck = true
                        onResult?.invoke(isCorrect)
                    }
                },
                enabled = selectedIndex != null,
                modifier = Modifier.fillMaxWidth()
            ) {
                Text("Check answer", fontWeight = FontWeight.SemiBold)
            }
        }
    }
}

@Composable
private fun OptionRow(
    index: Int,
    option: String,
    selectedIndex: Int?,
    didCheck: Boolean,
    correctIndex: Int,
    onSelect: () -> Unit
) {
    val letter = ('A'.code + index).toChar()
    val isSelected = selectedIndex == index
    val isCorrectOption = index == correctIndex

    var background = MaterialTheme.colorScheme.surface
    var border = Color.Gray.copy(alpha = 0.35f)
    var letterColor = Color.Gray

    when {
        didCheck && isCorrectOption -> {
            background = SuccessGreen.copy(alpha = 0.15f)
            border = SuccessGreen
            letterColor = SuccessGreen
        }
        didCheck && isSelected -> {
            background = DangerRed.copy(alpha = 0.15f)
            border = DangerRed
            letterColor = DangerRed
        }
        isSelected -> {
            background = PrimaryBlue.copy(alpha = 0.15f)
            border = PrimaryBlue
            letterColor = PrimaryBlue
        }
    }

    Surface(
        onClick = onSelect,
        shape = RoundedCornerShape(12.dp),
        color = background,
        border = androidx.compose.foundation.BorderStroke(1.5.dp, border),
        modifier = Modifier.fillMaxWidth()
    ) {
        Row(
            modifier = Modifier.padding(12.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            Box(
                modifier = Modifier
                    .size(28.dp)
                    .clip(CircleShape)
                    .background(letterColor.copy(alpha = 0.15f)),
                contentAlignment = Alignment.Center
            ) {
                Text(letter.toString(), fontWeight = FontWeight.Bold, color = letterColor)
            }
            Text(option, modifier = Modifier.weight(1f))
            when {
                didCheck && isCorrectOption -> Icon(
                    Icons.Filled.CheckCircle,
                    contentDescription = null,
                    tint = SuccessGreen
                )
                didCheck && isSelected -> Icon(
                    Icons.Filled.Cancel,
                    contentDescription = null,
                    tint = DangerRed
                )
            }
        }
    }
}

@Composable
private fun ResultView(isCorrect: Boolean, explanation: String, onReset: () -> Unit) {
    Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
        Row(
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            Icon(
                if (isCorrect) Icons.Filled.CheckCircle else Icons.Filled.Cancel,
                contentDescription = null,
                tint = if (isCorrect) SuccessGreen else DangerRed
            )
            Text(
                if (isCorrect) "Correct!" else "Not quite",
                fontWeight = FontWeight.Bold,
                color = if (isCorrect) SuccessGreen else DangerRed
            )
        }
        Text(
            explanation,
            style = MaterialTheme.typography.bodyMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
        TextButton(onClick = onReset) {
            Text("Try again", color = PrimaryBlue, fontWeight = FontWeight.SemiBold)
        }
    }
}
