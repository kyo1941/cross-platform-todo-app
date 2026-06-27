import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/todo_item.dart';
import '../../presentation/list/todo_list_ui_state.dart';
import '../../presentation/list/todo_list_view_model.dart';
import '../components/delete_confirm_dialog.dart';

/// S01: the to-do list. Shows items, the add button, and per-item check,
/// delete, navigation, and drag-to-reorder interactions.
class TodoListScreen extends ConsumerStatefulWidget {
  const TodoListScreen({
    super.key,
    required this.onNavigateToAdd,
    required this.onNavigateToEdit,
  });

  final VoidCallback onNavigateToAdd;
  final void Function(String id) onNavigateToEdit;

  @override
  ConsumerState<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends ConsumerState<TodoListScreen> {
  late final StreamSubscription<TodoListEvent> _eventsSubscription;

  @override
  void initState() {
    super.initState();
    _eventsSubscription =
        ref.read(todoListViewModelProvider.notifier).events.listen((event) {
      switch (event) {
        case NavigateToAdd():
          widget.onNavigateToAdd();
        case NavigateToEdit(:final id):
          widget.onNavigateToEdit(id);
      }
    });
  }

  @override
  void dispose() {
    _eventsSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.read(todoListViewModelProvider.notifier);
    final uiState = ref.watch(todoListViewModelProvider);

    // Show the delete dialog on the transition into a pending state. Keying on
    // the target id avoids re-showing it when the list stream re-emits.
    ref.listen<String?>(
      todoListViewModelProvider.select((s) => switch (s.deleteConfirmation) {
            DeleteConfirmationPending(:final target) => target.id,
            DeleteConfirmationNone() => null,
          }),
      (previous, next) {
        if (previous == null && next != null) {
          final target = switch (ref
              .read(todoListViewModelProvider)
              .deleteConfirmation) {
            DeleteConfirmationPending(:final target) => target,
            DeleteConfirmationNone() => null,
          };
          if (target != null) {
            showDeleteConfirmDialog(
              context,
              title: target.title,
              onConfirm: viewModel.onDeleteConfirm,
              onDismiss: viewModel.onDeleteCancel,
            );
          }
        }
      },
    );

    return Scaffold(
      appBar: AppBar(title: const Text('TODO')),
      floatingActionButton: FloatingActionButton(
        onPressed: viewModel.onAddClick,
        tooltip: '追加',
        child: const Icon(Icons.add),
      ),
      body: _TodoListBody(
        items: uiState.items,
        isLoading: uiState.isLoading,
        onToggleDone: viewModel.onToggleDone,
        onItemClick: viewModel.onItemClick,
        onDeleteRequest: viewModel.onDeleteRequest,
        onReorder: viewModel.onReorder,
      ),
    );
  }
}

class _TodoListBody extends StatelessWidget {
  const _TodoListBody({
    required this.items,
    required this.isLoading,
    required this.onToggleDone,
    required this.onItemClick,
    required this.onDeleteRequest,
    required this.onReorder,
  });

  final List<TodoItem> items;
  final bool isLoading;
  final void Function(String id) onToggleDone;
  final void Function(String id) onItemClick;
  final void Function(String id) onDeleteRequest;
  final void Function(int fromIndex, int toIndex) onReorder;

  @override
  Widget build(BuildContext context) {
    if (!isLoading && items.isEmpty) {
      return Center(
        child: Text(
          'TODOがありません',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }

    return ReorderableListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 88),
      itemCount: items.length,
      // Reorder only via the explicit drag handle (like all-kotlin/all-swift),
      // not by long-pressing the whole row.
      buildDefaultDragHandles: false,
      // onReorderItem already adjusts newIndex to the final destination index.
      onReorderItem: (oldIndex, newIndex) => onReorder(oldIndex, newIndex),
      itemBuilder: (context, index) {
        final item = items[index];
        return _TodoRow(
          key: ValueKey(item.id),
          index: index,
          item: item,
          onToggleDone: () => onToggleDone(item.id),
          onTap: () => onItemClick(item.id),
          onDeleteRequest: () => onDeleteRequest(item.id),
        );
      },
    );
  }
}

class _TodoRow extends StatelessWidget {
  const _TodoRow({
    super.key,
    required this.index,
    required this.item,
    required this.onToggleDone,
    required this.onTap,
    required this.onDeleteRequest,
  });

  final int index;
  final TodoItem item;
  final VoidCallback onToggleDone;
  final VoidCallback onTap;
  final VoidCallback onDeleteRequest;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final memo = item.memo;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.only(right: 4),
          child: Row(
            children: [
              Checkbox(
                value: item.isDone,
                onChanged: (_) => onToggleDone(),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              decoration: item.isDone
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: item.isDone
                                  ? colorScheme.onSurfaceVariant
                                  : colorScheme.onSurface,
                            ),
                      ),
                      if (memo != null && memo.trim().isNotEmpty)
                        Text(
                          memo,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                    ],
                  ),
                ),
              ),
              ReorderableDragStartListener(
                index: index,
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Icon(Icons.drag_handle, semanticLabel: '並び替え'),
                ),
              ),
              IconButton(
                onPressed: onDeleteRequest,
                icon: const Icon(Icons.delete_outline),
                tooltip: '削除',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
