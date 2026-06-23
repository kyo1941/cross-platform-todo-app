package com.example.crosstodo.allkotlin.presentation.edit

import com.example.crosstodo.allkotlin.data.TodoItem

sealed interface TodoEditUiState {
    val title: String
    val memo: String
    val titleError: String?
    val memoError: String?
    val canSave: Boolean
    val isSaving: Boolean

    data object Loading : TodoEditUiState {
        override val title: String = ""
        override val memo: String = ""
        override val titleError: String? = null
        override val memoError: String? = null
        override val canSave: Boolean = false
        override val isSaving: Boolean = false
    }

    data class Add(
        override val title: String = "",
        override val memo: String = "",
        override val titleError: String? = null,
        override val memoError: String? = null,
        override val canSave: Boolean = false,
        override val isSaving: Boolean = false,
    ) : TodoEditUiState

    data class Edit(
        val originalItem: TodoItem,
        override val title: String = originalItem.title,
        override val memo: String = originalItem.memo.orEmpty(),
        override val titleError: String? = null,
        override val memoError: String? = null,
        override val canSave: Boolean = true,
        override val isSaving: Boolean = false,
    ) : TodoEditUiState
}
