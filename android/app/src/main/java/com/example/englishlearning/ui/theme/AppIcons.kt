package com.example.englishlearning.ui.theme

import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.Article
import androidx.compose.material.icons.filled.AutoAwesome
import androidx.compose.material.icons.filled.Book
import androidx.compose.material.icons.filled.Cancel
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.ChevronRight
import androidx.compose.material.icons.filled.Eco
import androidx.compose.material.icons.filled.Favorite
import androidx.compose.material.icons.filled.Help
import androidx.compose.material.icons.filled.Logout
import androidx.compose.material.icons.filled.MenuBook
import androidx.compose.material.icons.filled.Mic
import androidx.compose.material.icons.filled.PlayArrow
import androidx.compose.material.icons.filled.Spellcheck
import androidx.compose.material.icons.filled.Stop
import androidx.compose.material.icons.filled.VolumeUp
import androidx.compose.ui.graphics.vector.ImageVector

/**
 * Maps iOS SF Symbol names (stored in the backend content model) onto Material
 * icons. A couple of semantic equivalents are used where no direct match exists.
 */
object AppIcons {
    val Book: ImageVector = Icons.Filled.MenuBook
    val Vocabulary: ImageVector = Icons.Filled.Spellcheck
    val Grammar: ImageVector = Icons.Filled.Article
    val Exercise: ImageVector = Icons.Filled.CheckCircle
    val Reading: ImageVector = Icons.Filled.Book
    val Listen: ImageVector = Icons.Filled.VolumeUp
    val Mic: ImageVector = Icons.Filled.Mic
    val Stop: ImageVector = Icons.Filled.Stop
    val Play: ImageVector = Icons.Filled.PlayArrow
    val Back: ImageVector = Icons.Filled.ArrowBack
    val ChevronRight: ImageVector = Icons.Filled.ChevronRight
    val Logout: ImageVector = Icons.Filled.Logout
    val Check: ImageVector = Icons.Filled.CheckCircle
    val Cross: ImageVector = Icons.Filled.Cancel
    val Help: ImageVector = Icons.Filled.Help

    fun chapter(name: String?): ImageVector = when (name) {
        "heart.fill" -> Icons.Filled.Favorite
        "leaf.fill" -> Icons.Filled.Eco
        "sparkles" -> Icons.Filled.AutoAwesome
        "book.fill" -> Icons.Filled.MenuBook
        else -> Icons.Filled.MenuBook
    }
}
