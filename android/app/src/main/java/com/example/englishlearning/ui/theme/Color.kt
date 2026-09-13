package com.example.englishlearning.ui.theme

import androidx.compose.ui.graphics.Color

// Mirrors the iOS `Theme` colours.
val PrimaryBlue = Color(0xFF4F8EF7)
val LightBlue = Color(0xFF7AA6FF)
val AccentCoral = Color(0xFFFF6B6B)
val SuccessGreen = Color(0xFF3CB371)
val WarningOrange = Color(0xFFFFA94D)
val DangerRed = Color(0xFFFF6B6B)
val BackgroundGray = Color(0xFFF2F2F7)

val ChapterColors = listOf(
    Color(0xFFFF6B6B),
    Color(0xFF3CB371),
    Color(0xFFFFA94D),
    Color(0xFF4F8EF7),
    Color(0xFFB57EDC)
)

/** Creates a Color from a hex string like "FF6B6B" or "#FF6B6B". */
fun colorFromHex(hex: String): Color {
    var value = hex.trim().removePrefix("#")
    if (value.length != 6) value = "4F8EF7"
    val rgb = value.toLongOrNull(16) ?: 0x4F8EF7L
    return Color(0xFF000000L or rgb)
}
