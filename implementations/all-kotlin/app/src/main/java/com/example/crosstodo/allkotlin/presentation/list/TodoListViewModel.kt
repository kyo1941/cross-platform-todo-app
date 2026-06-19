package com.example.crosstodo.allkotlin.presentation.list

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.crosstodo.allkotlin.data.TodoRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.channels.Channel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.receiveAsFlow
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch
import javax.inject.Inject

/** One-shot navigation events emitted by the list screen interactions. */
sealed interface TodoListEvent {
    data object NavigateToAdd : TodoListEvent
    data class NavigateToEdit(val id: String) : TodoListEvent
}

@HiltViewModel
class TodoListViewModel @Inject constructor(
    private val repository: TodoRepository,
) : ViewModel() {

    private val deleteTargetId = MutableStateFlow<String?>(null)

    val uiState: StateFlow<TodoListUiState> =
        combine(repository.observeAll(), deleteTargetId) { items, targetId ->
            TodoListUiState(items = items, isLoading = false, deleteTargetId = targetId)
        }.stateIn(
            scope = viewModelScope,
            started = SharingStarted.WhileSubscribed(5_000),
            initialValue = TodoListUiState(),
        )

    private val _events = Channel<TodoListEvent>(Channel.BUFFERED)
    val events = _events.receiveAsFlow()

    fun onToggleDone(id: String) {
        viewModelScope.launch { repository.toggleDone(id) }
    }

    fun onDeleteRequest(id: String) {
        deleteTargetId.value = id
    }

    fun onDeleteConfirm() {
        val target = deleteTargetId.value ?: return
        viewModelScope.launch {
            repository.delete(target)
            deleteTargetId.value = null
        }
    }

    fun onDeleteCancel() {
        deleteTargetId.value = null
    }

    fun onReorder(fromIndex: Int, toIndex: Int) {
        val current = uiState.value.items
        if (fromIndex !in current.indices || toIndex !in current.indices) return
        val reordered = current.toMutableList().apply { add(toIndex, removeAt(fromIndex)) }
        viewModelScope.launch { repository.reorder(reordered.map { it.id }) }
    }

    fun onAddClick() {
        viewModelScope.launch { _events.send(TodoListEvent.NavigateToAdd) }
    }

    fun onItemClick(id: String) {
        viewModelScope.launch { _events.send(TodoListEvent.NavigateToEdit(id)) }
    }
}
