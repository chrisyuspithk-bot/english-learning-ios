package com.example.englishlearning.ui.chapter

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.englishlearning.data.model.Chapter
import com.example.englishlearning.data.repository.ContentRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch

data class ChapterUiState(
    val chapter: Chapter? = null,
    val isLoading: Boolean = false,
    val error: String? = null
)

class ChapterViewModel(private val contentRepository: ContentRepository) : ViewModel() {

    private val _uiState = MutableStateFlow(ChapterUiState())
    val uiState: StateFlow<ChapterUiState> = _uiState.asStateFlow()

    fun loadChapter(id: String) {
        if (_uiState.value.chapter?.id == id) return
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true, error = null, chapter = null) }
            contentRepository.chapter(id)
                .onSuccess { chapter ->
                    _uiState.update { it.copy(isLoading = false, chapter = chapter) }
                }
                .onFailure {
                    _uiState.update {
                        it.copy(isLoading = false, error = "Could not load this chapter.")
                    }
                }
        }
    }
}
