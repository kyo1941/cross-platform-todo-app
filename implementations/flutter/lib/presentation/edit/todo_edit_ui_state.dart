import '../../data/todo_item.dart';

/// Edit-screen state modeled as a sum type: Loading while fetching an existing
/// item, Add for a brand-new entry, and Edit carrying the original item (see
/// the state modeling guideline in the project spec).
sealed class TodoEditUiState {
  const TodoEditUiState();

  String get title;
  String get memo;
  String? get titleError;
  String? get memoError;
  bool get canSave;
  bool get isSaving;

  String get navigationTitle => switch (this) {
        TodoEditAdd() => 'TODOを追加',
        TodoEditLoading() || TodoEditEdit() => 'TODOを編集',
      };

  /// Returns a copy with the form fields replaced, preserving the variant.
  /// Loading carries no form, so it is returned unchanged.
  TodoEditUiState copyForm({
    String? title,
    String? memo,
    String? Function()? titleError,
    String? Function()? memoError,
    bool? canSave,
    bool? isSaving,
  }) {
    switch (this) {
      case TodoEditLoading():
        return this;
      case final TodoEditAdd current:
        return TodoEditAdd(
          title: title ?? current.title,
          memo: memo ?? current.memo,
          titleError: titleError != null ? titleError() : current.titleError,
          memoError: memoError != null ? memoError() : current.memoError,
          canSave: canSave ?? current.canSave,
          isSaving: isSaving ?? current.isSaving,
        );
      case final TodoEditEdit current:
        return TodoEditEdit(
          originalItem: current.originalItem,
          title: title ?? current.title,
          memo: memo ?? current.memo,
          titleError: titleError != null ? titleError() : current.titleError,
          memoError: memoError != null ? memoError() : current.memoError,
          canSave: canSave ?? current.canSave,
          isSaving: isSaving ?? current.isSaving,
        );
    }
  }
}

class TodoEditLoading extends TodoEditUiState {
  const TodoEditLoading();

  @override
  String get title => '';
  @override
  String get memo => '';
  @override
  String? get titleError => null;
  @override
  String? get memoError => null;
  @override
  bool get canSave => false;
  @override
  bool get isSaving => false;
}

class TodoEditAdd extends TodoEditUiState {
  const TodoEditAdd({
    this.title = '',
    this.memo = '',
    this.titleError,
    this.memoError,
    this.canSave = false,
    this.isSaving = false,
  });

  @override
  final String title;
  @override
  final String memo;
  @override
  final String? titleError;
  @override
  final String? memoError;
  @override
  final bool canSave;
  @override
  final bool isSaving;
}

class TodoEditEdit extends TodoEditUiState {
  TodoEditEdit({
    required this.originalItem,
    String? title,
    String? memo,
    this.titleError,
    this.memoError,
    this.canSave = true,
    this.isSaving = false,
  })  : title = title ?? originalItem.title,
        memo = memo ?? originalItem.memo ?? '';

  final TodoItem originalItem;

  @override
  final String title;
  @override
  final String memo;
  @override
  final String? titleError;
  @override
  final String? memoError;
  @override
  final bool canSave;
  @override
  final bool isSaving;
}
