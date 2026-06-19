package com.example.crosstodo.allkotlin.presentation.list

import com.example.crosstodo.allkotlin.data.TodoItem

data class TodoListUiState(
    val items: List<TodoItem> = emptyList(),
    val isLoading: Boolean = true,
    val deleteTargetId: String? = null,
) {
    val deleteTarget: TodoItem?
        get() = deleteTargetId?.let { id -> items.firstOrNull { it.id == id } }
}
