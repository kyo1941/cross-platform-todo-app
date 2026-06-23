package com.example.crosstodo.allkotlin.presentation.list

import com.example.crosstodo.allkotlin.data.TodoItem

sealed interface DeleteConfirmation {
    data object None : DeleteConfirmation
    data class Pending(val target: TodoItem) : DeleteConfirmation
}

data class TodoListUiState(
    val items: List<TodoItem> = emptyList(),
    val isLoading: Boolean = true,
    val deleteConfirmation: DeleteConfirmation = DeleteConfirmation.None,
)
