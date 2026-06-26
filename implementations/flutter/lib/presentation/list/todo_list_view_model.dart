import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/todo_item.dart';
import '../../data/todo_repository.dart';
import '../../di/providers.dart';
import 'todo_list_ui_state.dart';

final todoListViewModelProvider =
    NotifierProvider<TodoListViewModel, TodoListUiState>(
  TodoListViewModel.new,
);

class TodoListViewModel extends Notifier<TodoListUiState> {
  final StreamController<TodoListEvent> _events =
      StreamController<TodoListEvent>.broadcast();

  /// One-shot navigation events, consumed by the list screen.
  Stream<TodoListEvent> get events => _events.stream;

  late final TodoRepository _repository;
  String? _deleteTargetId;

  @override
  TodoListUiState build() {
    _repository = ref.watch(todoRepositoryProvider);

    final subscription = _repository.observeAll().listen((items) {
      state = state.copyWith(
        items: items,
        isLoading: false,
        deleteConfirmation: _makeDeleteConfirmation(items),
      );
    });

    ref.onDispose(() {
      subscription.cancel();
      _events.close();
    });

    return const TodoListUiState();
  }

  void onToggleDone(String id) {
    unawaited(_repository.toggleDone(id));
  }

  void onDeleteRequest(String id) {
    _deleteTargetId = id;
    state = state.copyWith(
      deleteConfirmation: _makeDeleteConfirmation(state.items),
    );
  }

  void onDeleteConfirm() {
    final confirmation = state.deleteConfirmation;
    if (confirmation is! DeleteConfirmationPending) return;
    unawaited(
      _repository.delete(confirmation.target.id).then((_) {
        _deleteTargetId = null;
        state = state.copyWith(deleteConfirmation: const DeleteConfirmationNone());
      }),
    );
  }

  void onDeleteCancel() {
    _deleteTargetId = null;
    state = state.copyWith(deleteConfirmation: const DeleteConfirmationNone());
  }

  /// Reorders the working list optimistically and persists the new order.
  /// The repository stream later emits the same order, so the UI stays stable.
  void onReorder(int fromIndex, int toIndex) {
    final items = List<TodoItem>.of(state.items);
    if (fromIndex < 0 ||
        fromIndex >= items.length ||
        toIndex < 0 ||
        toIndex >= items.length) {
      return;
    }
    final item = items.removeAt(fromIndex);
    items.insert(toIndex, item);
    state = state.copyWith(
      items: items,
      deleteConfirmation: _makeDeleteConfirmation(items),
    );
    unawaited(_repository.reorder(items.map((it) => it.id).toList()));
  }

  void onAddClick() {
    _events.add(const NavigateToAdd());
  }

  void onItemClick(String id) {
    _events.add(NavigateToEdit(id));
  }

  DeleteConfirmation _makeDeleteConfirmation(List<TodoItem> items) {
    final targetId = _deleteTargetId;
    if (targetId == null) return const DeleteConfirmationNone();
    for (final item in items) {
      if (item.id == targetId) return DeleteConfirmationPending(item);
    }
    return const DeleteConfirmationNone();
  }
}
