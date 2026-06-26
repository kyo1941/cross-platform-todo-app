import '../../data/todo_item.dart';

/// Delete-confirmation state modeled as a sum type so the "nothing pending" and
/// "pending for a specific item" cases can't be confused (see the state
/// modeling guideline in the project spec).
sealed class DeleteConfirmation {
  const DeleteConfirmation();
}

class DeleteConfirmationNone extends DeleteConfirmation {
  const DeleteConfirmationNone();
}

class DeleteConfirmationPending extends DeleteConfirmation {
  const DeleteConfirmationPending(this.target);

  final TodoItem target;
}

class TodoListUiState {
  const TodoListUiState({
    this.items = const [],
    this.isLoading = true,
    this.deleteConfirmation = const DeleteConfirmationNone(),
  });

  final List<TodoItem> items;
  final bool isLoading;
  final DeleteConfirmation deleteConfirmation;

  TodoListUiState copyWith({
    List<TodoItem>? items,
    bool? isLoading,
    DeleteConfirmation? deleteConfirmation,
  }) {
    return TodoListUiState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      deleteConfirmation: deleteConfirmation ?? this.deleteConfirmation,
    );
  }
}

/// One-shot navigation events emitted by the list screen interactions.
sealed class TodoListEvent {
  const TodoListEvent();
}

class NavigateToAdd extends TodoListEvent {
  const NavigateToAdd();
}

class NavigateToEdit extends TodoListEvent {
  const NavigateToEdit(this.id);

  final String id;
}
