package com.example.crosstodo.allkotlin.presentation.edit

data class TodoEditUiState(
    val id: String? = null,
    val title: String = "",
    val memo: String = "",
    val titleError: String? = null,
    val memoError: String? = null,
    val isEditMode: Boolean = false,
    val canSave: Boolean = false,
)
