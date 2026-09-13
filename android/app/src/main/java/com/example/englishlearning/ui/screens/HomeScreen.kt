package com.example.englishlearning.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
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
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Logout
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewmodel.compose.viewModel
import com.example.englishlearning.AppContainer
import com.example.englishlearning.data.model.Announcement
import com.example.englishlearning.data.model.ChapterSummary
import com.example.englishlearning.data.model.HomeworkSession
import com.example.englishlearning.data.model.User
import com.example.englishlearning.ui.auth.AuthViewModel
import com.example.englishlearning.ui.components.AppCard
import com.example.englishlearning.ui.components.LoadingIndicator
import com.example.englishlearning.ui.components.ProgressBar
import com.example.englishlearning.ui.components.SectionHeader
import com.example.englishlearning.ui.home.HomeViewModel
import com.example.englishlearning.ui.theme.AccentCoral
import com.example.englishlearning.ui.theme.AppIcons
import com.example.englishlearning.ui.theme.PrimaryBlue
import com.example.englishlearning.ui.theme.SuccessGreen
import com.example.englishlearning.ui.theme.DangerRed
import com.example.englishlearning.ui.theme.colorFromHex

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun HomeScreen(
    container: AppContainer,
    authViewModel: AuthViewModel,
    onOpenChapter: (String, String) -> Unit,
    onLogout: () -> Unit
) {
    val viewModel: HomeViewModel = viewModel { HomeViewModel(container.contentRepository) }
    val state by viewModel.uiState.collectAsStateWithLifecycle()

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Home") },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = MaterialTheme.colorScheme.background
                ),
                actions = {
                    IconButton(onClick = {
                        authViewModel.logout()
                        container.speechManager.stop()
                        container.ttsManager.stop()
                        onLogout()
                    }) {
                        Icon(Icons.Filled.Logout, contentDescription = "Log out")
                    }
                }
            )
        }
    ) { padding ->
        Box(
            modifier = Modifier
                .fillMaxSize()
                .background(MaterialTheme.colorScheme.background)
                .padding(padding)
        ) {
            when {
                state.isLoading -> LoadingIndicator(Modifier.fillMaxSize())

                state.error != null -> ErrorContent(
                    message = state.error.orEmpty(),
                    onRetry = viewModel::loadContent
                )

                else -> HomeContent(
                    state = state,
                    onOpenChapter = onOpenChapter
                )
            }
        }
    }
}

@Composable
private fun ErrorContent(message: String, onRetry: () -> Unit) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(32.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Text(message, color = DangerRed, style = MaterialTheme.typography.bodyMedium)
        Spacer(Modifier.height(16.dp))
        androidx.compose.material3.Button(onClick = onRetry) { Text("Retry") }
    }
}

@Composable
private fun HomeContent(
    state: com.example.englishlearning.ui.home.HomeUiState,
    onOpenChapter: (String, String) -> Unit
) {
    LazyColumn(
        modifier = Modifier.fillMaxSize(),
        contentPadding = PaddingValues(vertical = 16.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        item { WelcomeHeader(state.user) }

        state.homework.firstOrNull()?.let { item { HomeworkCard(it) } }
        state.announcements.firstOrNull()?.let { item { AnnouncementCard(it) } }

        item { SectionHeader("Chapters", AppIcons.Book) }

        items(state.chapters) { chapter ->
            ChapterRow(chapter) { onOpenChapter(chapter.id, chapter.title) }
        }
    }
}

@Composable
private fun WelcomeHeader(user: User?) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        Box(
            modifier = Modifier
                .size(56.dp)
                .clip(CircleShape)
                .background(colorFromHex(user?.avatarColorHex ?: "4F8EF7")),
            contentAlignment = Alignment.Center
        ) {
            Text(
                text = (user?.englishName?.take(1) ?: "S"),
                color = Color.White,
                fontWeight = FontWeight.Bold
            )
        }
        Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
            Text(
                "Hello, ${user?.englishName ?: "Student"} 👋",
                style = MaterialTheme.typography.titleMedium,
                fontWeight = FontWeight.Bold
            )
            val grade = user?.grade.orEmpty()
            val school = user?.school.orEmpty()
            val subtitle = if (school.isEmpty()) grade else "$grade · $school"
            if (subtitle.isNotBlank()) {
                Text(
                    subtitle,
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
        }
    }
}

@Composable
private fun HomeworkCard(homework: HomeworkSession) {
    AppCard(accent = PrimaryBlue, modifier = Modifier.padding(horizontal = 16.dp)) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Text(
                "📚 Latest Homework",
                style = MaterialTheme.typography.labelMedium,
                fontWeight = FontWeight.SemiBold,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
            Spacer(Modifier.weight(1f))
            homework.score?.let { score ->
                Text(
                    "$score/100",
                    style = MaterialTheme.typography.labelMedium,
                    fontWeight = FontWeight.Bold,
                    color = if (score >= 60) SuccessGreen else DangerRed
                )
            }
        }
        Text(homework.title, style = MaterialTheme.typography.titleMedium)
        Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            Text(
                homework.type,
                style = MaterialTheme.typography.labelSmall,
                color = PrimaryBlue,
                modifier = Modifier
                    .clip(RoundedCornerShape(6.dp))
                    .background(PrimaryBlue.copy(alpha = 0.15f))
                    .padding(horizontal = 8.dp, vertical = 4.dp)
            )
            Text(
                "Due ${homework.dueDate}",
                style = MaterialTheme.typography.labelSmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
        ProgressBar(homework.progress)
        Text(
            "${(homework.progress * 100).toInt()}% completed",
            style = MaterialTheme.typography.labelSmall,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
    }
}

@Composable
private fun AnnouncementCard(announcement: Announcement) {
    AppCard(accent = AccentCoral, modifier = Modifier.padding(horizontal = 16.dp)) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Text(
                "📢 Teacher Announcement",
                style = MaterialTheme.typography.labelMedium,
                fontWeight = FontWeight.SemiBold,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
            Spacer(Modifier.weight(1f))
            Text(
                announcement.date,
                style = MaterialTheme.typography.labelSmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
        Text(announcement.title, style = MaterialTheme.typography.titleMedium)
        Text(
            announcement.body,
            style = MaterialTheme.typography.bodyMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
        Text(
            "— ${announcement.author}",
            style = MaterialTheme.typography.labelSmall,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
    }
}

@Composable
private fun ChapterRow(chapter: ChapterSummary, onClick: () -> Unit) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp)
            .clip(RoundedCornerShape(16.dp))
            .background(MaterialTheme.colorScheme.surface)
            .clickable(onClick = onClick)
            .padding(16.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        Box(
            modifier = Modifier
                .size(52.dp)
                .clip(RoundedCornerShape(12.dp))
                .background(colorFromHex(chapter.colorHex)),
            contentAlignment = Alignment.Center
        ) {
            androidx.compose.material3.Icon(
                AppIcons.chapter(chapter.icon),
                contentDescription = null,
                tint = Color.White,
                modifier = Modifier.size(22.dp)
            )
        }
        Column(
            modifier = Modifier.weight(1f),
            verticalArrangement = Arrangement.spacedBy(4.dp)
        ) {
            Text(
                "Chapter ${chapter.number}",
                style = MaterialTheme.typography.labelSmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
            Text(chapter.title, style = MaterialTheme.typography.titleMedium)
            Text(
                chapter.subtitle,
                style = MaterialTheme.typography.labelSmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
        Icon(
            AppIcons.ChevronRight,
            contentDescription = null,
            tint = MaterialTheme.colorScheme.onSurfaceVariant
        )
    }
}
