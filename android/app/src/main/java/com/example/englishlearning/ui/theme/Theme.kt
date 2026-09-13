package com.example.englishlearning.ui.theme

import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable

private val LightColors = lightColorScheme(
    primary = PrimaryBlue,
    onPrimary = androidx.compose.ui.graphics.Color.White,
    secondary = AccentCoral,
    tertiary = SuccessGreen,
    background = BackgroundGray,
    surface = androidx.compose.ui.graphics.Color.White,
    surfaceVariant = BackgroundGray,
    error = DangerRed
)

@Composable
fun EnglishLearningTheme(content: @Composable () -> Unit) {
    MaterialTheme(
        colorScheme = LightColors,
        typography = Typography,
        content = content
    )
}
