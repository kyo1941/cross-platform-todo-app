package com.example.crosstodo.allkotlin.ui.list

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.DragHandle
import androidx.compose.material.icons.outlined.Delete
import androidx.compose.material3.Card
import androidx.compose.material3.Checkbox
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.FloatingActionButton
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateListOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.style.TextDecoration
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.example.crosstodo.allkotlin.data.TodoItem
import com.example.crosstodo.allkotlin.presentation.list.DeleteConfirmation
import com.example.crosstodo.allkotlin.presentation.list.TodoListEvent
import com.example.crosstodo.allkotlin.presentation.list.TodoListViewModel
import com.example.crosstodo.allkotlin.ui.components.DeleteConfirmDialog
import sh.calvin.reorderable.ReorderableItem
import sh.calvin.reorderable.rememberReorderableLazyListState

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun TodoListScreen(
    onNavigateToAdd: () -> Unit,
    onNavigateToEdit: (String) -> Unit,
    viewModel: TodoListViewModel = hiltViewModel(),
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()

    LaunchedEffect(Unit) {
        viewModel.events.collect { event ->
            when (event) {
                TodoListEvent.NavigateToAdd -> onNavigateToAdd()
                is TodoListEvent.NavigateToEdit -> onNavigateToEdit(event.id)
            }
        }
    }

    Scaffold(
        topBar = { TopAppBar(title = { Text("TODO") }) },
        floatingActionButton = {
            FloatingActionButton(onClick = viewModel::onAddClick) {
                Icon(Icons.Default.Add, contentDescription = "追加")
            }
        },
    ) { innerPadding ->
        TodoListContent(
            todoItems = uiState.items,
            isLoading = uiState.isLoading,
            modifier = Modifier.padding(innerPadding),
            onToggleDone = viewModel::onToggleDone,
            onItemClick = viewModel::onItemClick,
            onDeleteRequest = viewModel::onDeleteRequest,
            onReorder = viewModel::onReorder,
        )
    }

    (uiState.deleteConfirmation as? DeleteConfirmation.Pending)?.let { pending ->
        DeleteConfirmDialog(
            title = pending.target.title,
            onConfirm = viewModel::onDeleteConfirm,
            onDismiss = viewModel::onDeleteCancel,
        )
    }
}

@Composable
private fun TodoListContent(
    todoItems: List<TodoItem>,
    isLoading: Boolean,
    modifier: Modifier = Modifier,
    onToggleDone: (String) -> Unit,
    onItemClick: (String) -> Unit,
    onDeleteRequest: (String) -> Unit,
    onReorder: (Int, Int) -> Unit,
) {
    if (!isLoading && todoItems.isEmpty()) {
        Box(
            modifier = modifier.fillMaxSize(),
            contentAlignment = Alignment.Center,
        ) {
            Text("TODOがありません", style = MaterialTheme.typography.bodyLarge)
        }
        return
    }

    // Local working copy reordered optimistically during a drag. The database is
    // updated only once, when the drag ends, to avoid per-move writes and to keep
    // the list consistent across multi-position drags.
    val displayItems = remember { mutableStateListOf<TodoItem>() }
    var draggingId by remember { mutableStateOf<String?>(null) }

    LaunchedEffect(todoItems) {
        if (draggingId == null) {
            displayItems.clear()
            displayItems.addAll(todoItems)
        }
    }

    val lazyListState = rememberLazyListState()
    val reorderableState = rememberReorderableLazyListState(lazyListState) { from, to ->
        displayItems.add(to.index, displayItems.removeAt(from.index))
    }

    LazyColumn(
        state = lazyListState,
        modifier = modifier.fillMaxSize(),
        contentPadding = PaddingValues(top = 8.dp, bottom = 88.dp, start = 12.dp, end = 12.dp),
        verticalArrangement = Arrangement.spacedBy(8.dp),
    ) {
        items(displayItems, key = { it.id }) { item ->
            ReorderableItem(reorderableState, key = item.id) { _ ->
                TodoRow(
                    item = item,
                    onToggleDone = { onToggleDone(item.id) },
                    onClick = { onItemClick(item.id) },
                    onDeleteRequest = { onDeleteRequest(item.id) },
                    dragHandle = {
                        IconButton(
                            onClick = {},
                            modifier = Modifier.draggableHandle(
                                onDragStarted = { draggingId = item.id },
                                onDragStopped = {
                                    val id = draggingId
                                    draggingId = null
                                    if (id != null) {
                                        val from = todoItems.indexOfFirst { it.id == id }
                                        val to = displayItems.indexOfFirst { it.id == id }
                                        if (from != -1 && to != -1 && from != to) {
                                            onReorder(from, to)
                                        }
                                    }
                                },
                            ),
                        ) {
                            Icon(
                                Icons.Default.DragHandle,
                                contentDescription = "並び替え",
                            )
                        }
                    },
                )
            }
        }
    }
}

@Composable
private fun TodoRow(
    item: TodoItem,
    onToggleDone: () -> Unit,
    onClick: () -> Unit,
    onDeleteRequest: () -> Unit,
    dragHandle: @Composable () -> Unit,
) {
    Card(onClick = onClick) {
        Row(
            modifier = Modifier.padding(end = 4.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Checkbox(checked = item.isDone, onCheckedChange = { onToggleDone() })
            Column(
                modifier = Modifier
                    .weight(1f)
                    .padding(vertical = 8.dp),
            ) {
                Text(
                    text = item.title,
                    style = MaterialTheme.typography.bodyLarge,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis,
                    textDecoration = if (item.isDone) TextDecoration.LineThrough else null,
                    color = if (item.isDone) {
                        MaterialTheme.colorScheme.onSurfaceVariant
                    } else {
                        MaterialTheme.colorScheme.onSurface
                    },
                )
                item.memo?.takeIf { it.isNotBlank() }?.let { memo ->
                    Text(
                        text = memo,
                        style = MaterialTheme.typography.bodyMedium,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis,
                    )
                }
            }
            dragHandle()
            IconButton(onClick = onDeleteRequest) {
                Icon(Icons.Outlined.Delete, contentDescription = "削除")
            }
        }
    }
}
