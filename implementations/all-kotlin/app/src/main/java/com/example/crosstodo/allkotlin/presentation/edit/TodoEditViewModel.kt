package com.example.crosstodo.allkotlin.presentation.edit

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.crosstodo.allkotlin.data.TodoItem
import com.example.crosstodo.allkotlin.data.TodoRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.channels.Channel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.receiveAsFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class TodoEditViewModel @Inject constructor(
    private val repository: TodoRepository,
    savedStateHandle: SavedStateHandle,
) : ViewModel() {

    private val todoId: String? = savedStateHandle.get<String>(ARG_TODO_ID)

    private val _uiState = MutableStateFlow(TodoEditUiState(id = todoId, isEditMode = todoId != null))
    val uiState: StateFlow<TodoEditUiState> = _uiState.asStateFlow()

    private val _navigateBack = Channel<Unit>(Channel.BUFFERED)
    val navigateBack = _navigateBack.receiveAsFlow()

    /** Original item in edit mode; preserves isDone/sortOrder/createdAt on save. */
    private var loadedItem: TodoItem? = null

    /** Whether the title field has been edited, to avoid an error on a pristine form. */
    private var titleTouched = false

    init {
        if (todoId != null) {
            viewModelScope.launch {
                val item = repository.getById(todoId) ?: return@launch
                loadedItem = item
                titleTouched = true
                _uiState.update {
                    it.copy(title = item.title, memo = item.memo.orEmpty())
                }
                validate()
            }
        }
    }

    fun onTitleChange(value: String) {
        titleTouched = true
        _uiState.update { it.copy(title = value) }
        validate()
    }

    fun onMemoChange(value: String) {
        _uiState.update { it.copy(memo = value) }
        validate()
    }

    fun onSaveClick() {
        val state = _uiState.value
        if (!state.canSave) return
        val title = state.title.trim()
        val memo = state.memo.trim().takeUnless { it.isEmpty() }
        viewModelScope.launch {
            val existing = loadedItem
            if (existing != null) {
                repository.update(
                    existing.copy(
                        title = title,
                        memo = memo,
                        updatedAt = System.currentTimeMillis(),
                    ),
                )
            } else {
                repository.add(title, memo)
            }
            _navigateBack.send(Unit)
        }
    }

    fun onCancelClick() {
        viewModelScope.launch { _navigateBack.send(Unit) }
    }

    private fun validate() {
        val state = _uiState.value
        val trimmedTitleLength = state.title.trim().length
        val titleError = when {
            trimmedTitleLength == 0 -> if (titleTouched) ERROR_TITLE_REQUIRED else null
            trimmedTitleLength > TITLE_MAX_LENGTH -> ERROR_TITLE_TOO_LONG
            else -> null
        }
        val memoError = if (state.memo.length > MEMO_MAX_LENGTH) ERROR_MEMO_TOO_LONG else null
        val canSave = trimmedTitleLength in 1..TITLE_MAX_LENGTH && memoError == null
        _uiState.update {
            it.copy(titleError = titleError, memoError = memoError, canSave = canSave)
        }
    }

    companion object {
        const val ARG_TODO_ID = "todoId"
        const val TITLE_MAX_LENGTH = 255
        const val MEMO_MAX_LENGTH = 1000
        const val ERROR_TITLE_REQUIRED = "タイトルを入力してください"
        const val ERROR_TITLE_TOO_LONG = "タイトルは255文字以内で入力してください"
        const val ERROR_MEMO_TOO_LONG = "メモは1000文字以内で入力してください"
    }
}
