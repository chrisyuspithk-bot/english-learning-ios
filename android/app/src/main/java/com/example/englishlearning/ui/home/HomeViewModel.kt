package com.example.englishlearning.ui.home

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.englishlearning.data.model.Announcement
import com.example.englishlearning.data.model.ChapterSummary
import com.example.englishlearning.data.model.HomeworkSession
import com.example.englishlearning.data.model.User
import com.example.englishlearning.data.repository.ContentRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch

data class HomeUiState(
    val user: User? = null,
    val chapters: List<ChapterSummary> = emptyList(),
    val homework: List<HomeworkSession> = emptyList(),
    val announcements: List<Announcement> = emptyList(),
    val isLoading: Boolean = false,
    val error: String? = null
)

class HomeViewModel(private val contentRepository: ContentRepository) : ViewModel() {

    private val _uiState = MutableStateFlow(HomeUiState())
    val uiState: StateFlow<HomeUiState> = _uiState.asStateFlow()

    init {
        loadContent()
    }

    fun loadContent() {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true, error = null) }
            contentRepository.dashboard()
                .onSuccess { payload ->
                    _uiState.update {
                        it.copy(
                            isLoading = false,
                            user = payload.user,
                            chapters = payload.chapters,
                            homework = payload.homework,
                            announcements = payload.announcements
                        )
                    }
                }
                .onFailure { e ->
                    _uiState.update { it.copy(isLoading = false, error = e.message) }
                }
        }
    }
}
