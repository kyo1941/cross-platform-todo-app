package com.example.crosstodo.allkotlin.presentation.edit

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
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

    private val _uiState = MutableStateFlow(
        if (todoId != null) TodoEditUiState.Loading else TodoEditUiState.Add(),
    )
    val uiState: StateFlow<TodoEditUiState> = _uiState.asStateFlow()

    private val _navigateBack = Channel<Unit>(Channel.BUFFERED)
    val navigateBack = _navigateBack.receiveAsFlow()

    /** Whether the title field has been edited at least once, to avoid an error on a pristine form. */
    private var titleChangedOnce = false

    init {
        if (todoId != null) {
            viewModelScope.launch {
                val item = repository.getById(todoId)
                if (item == null) {
                    // The item was removed (e.g. deleted elsewhere); leave the screen.
                    _navigateBack.send(Unit)
                    return@launch
                }
                titleChangedOnce = true
                _uiState.value = TodoEditUiState.Edit(originalItem = item)
            }
        }
    }

    fun onTitleChange(value: String) {
        titleChangedOnce = true
        _uiState.update { it.copyForm(title = value) }
        validate()
    }

    fun onMemoChange(value: String) {
        _uiState.update { it.copyForm(memo = value) }
        validate()
    }

    fun onSaveClick() {
        val state = _uiState.value
        if (!state.canSave) return
        val title = state.title.trim()
        val memo = state.memo.trim().takeUnless { it.isEmpty() }
        viewModelScope.launch {
            when (state) {
                is TodoEditUiState.Edit -> repository.update(
                    state.originalItem.copy(
                        title = title,
                        memo = memo,
                        updatedAt = System.currentTimeMillis(),
                    ),
                )
                is TodoEditUiState.Add -> repository.add(title, memo)
                TodoEditUiState.Loading -> return@launch
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
            trimmedTitleLength == 0 -> if (titleChangedOnce) ERROR_TITLE_REQUIRED else null
            trimmedTitleLength > TITLE_MAX_LENGTH -> ERROR_TITLE_TOO_LONG
            else -> null
        }
        val memoError = if (state.memo.length > MEMO_MAX_LENGTH) ERROR_MEMO_TOO_LONG else null
        val canSave = state !is TodoEditUiState.Loading &&
            trimmedTitleLength in 1..TITLE_MAX_LENGTH &&
            memoError == null
        _uiState.update {
            it.copyForm(titleError = titleError, memoError = memoError, canSave = canSave)
        }
    }

    private fun TodoEditUiState.copyForm(
        title: String = this.title,
        memo: String = this.memo,
        titleError: String? = this.titleError,
        memoError: String? = this.memoError,
        canSave: Boolean = this.canSave,
    ): TodoEditUiState = when (this) {
        is TodoEditUiState.Add -> copy(
            title = title,
            memo = memo,
            titleError = titleError,
            memoError = memoError,
            canSave = canSave,
        )
        is TodoEditUiState.Edit -> copy(
            title = title,
            memo = memo,
            titleError = titleError,
            memoError = memoError,
            canSave = canSave,
        )
        TodoEditUiState.Loading -> this
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
