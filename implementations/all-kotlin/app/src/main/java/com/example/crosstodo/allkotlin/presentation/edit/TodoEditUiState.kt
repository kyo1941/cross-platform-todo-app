package com.example.crosstodo.allkotlin.presentation.edit

import com.example.crosstodo.allkotlin.data.TodoItem

sealed interface TodoEditMode {
    data object Add : TodoEditMode
    data object Loading : TodoEditMode
    data class Edit(val originalItem: TodoItem) : TodoEditMode
}

data class TodoEditUiState(
    val mode: TodoEditMode = TodoEditMode.Add,
    val title: String = "",
    val memo: String = "",
    val titleError: String? = null,
    val memoError: String? = null,
    val canSave: Boolean = false,
)
