import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/todo_repository.dart';
import '../../di/providers.dart';
import 'todo_edit_ui_state.dart';

const titleMaxLength = 255;
const memoMaxLength = 1000;
const errorTitleRequired = 'タイトルを入力してください';
const errorTitleTooLong = 'タイトルは255文字以内で入力してください';
const errorMemoTooLong = 'メモは1000文字以内で入力してください';

final todoEditViewModelProvider = NotifierProvider.autoDispose
    .family<TodoEditViewModel, TodoEditUiState, String?>(TodoEditViewModel.new);

class TodoEditViewModel
    extends AutoDisposeFamilyNotifier<TodoEditUiState, String?> {
  final StreamController<void> _navigateBack =
      StreamController<void>.broadcast();

  Stream<void> get navigateBack => _navigateBack.stream;

  late final TodoRepository _repository;

  bool _titleChangedOnce = false;

  @override
  TodoEditUiState build(String? arg) {
    _repository = ref.watch(todoRepositoryProvider);
    ref.onDispose(_navigateBack.close);

    if (arg != null) {
      unawaited(_loadItem(arg));
      return const TodoEditLoading();
    }
    return const TodoEditAdd();
  }

  void onTitleChange(String value) {
    _titleChangedOnce = true;
    state = state.copyForm(title: value);
    _validate();
  }

  void onMemoChange(String value) {
    state = state.copyForm(memo: value);
    _validate();
  }

  void onSaveClick() {
    final current = state;
    if (!current.canSave || current.isSaving) return;
    state = state.copyForm(isSaving: true, canSave: false);

    final title = current.title.trim();
    final trimmedMemo = current.memo.trim();
    final memo = trimmedMemo.isEmpty ? null : trimmedMemo;

    unawaited(_save(current, title, memo));
  }

  void onCancelClick() {
    _navigateBack.add(null);
  }

  Future<void> _save(TodoEditUiState current, String title, String? memo) async {
    try {
      switch (current) {
        case TodoEditEdit(:final originalItem):
          await _repository.update(
            originalItem.copyWith(
              title: title,
              memo: () => memo,
              updatedAt: DateTime.now().millisecondsSinceEpoch,
            ),
          );
        case TodoEditAdd():
          await _repository.add(title, memo);
        case TodoEditLoading():
          return;
      }
      _navigateBack.add(null);
    } catch (_) {
      state = state.copyForm(isSaving: false);
      _validate();
    }
  }

  Future<void> _loadItem(String id) async {
    try {
      final item = await _repository.getById(id);
      if (item == null) {
        // The item was removed (e.g. deleted elsewhere); leave the screen.
        _navigateBack.add(null);
        return;
      }
      _titleChangedOnce = true;
      state = TodoEditEdit(originalItem: item);
    } catch (_) {
      _navigateBack.add(null);
    }
  }

  void _validate() {
    final trimmedTitleLength = state.title.trim().length;
    final String? titleError;
    if (trimmedTitleLength == 0) {
      titleError = _titleChangedOnce ? errorTitleRequired : null;
    } else if (trimmedTitleLength > titleMaxLength) {
      titleError = errorTitleTooLong;
    } else {
      titleError = null;
    }
    final memoError = state.memo.length > memoMaxLength ? errorMemoTooLong : null;
    final canSave = state is! TodoEditLoading &&
        !state.isSaving &&
        trimmedTitleLength >= 1 &&
        trimmedTitleLength <= titleMaxLength &&
        memoError == null;

    state = state.copyForm(
      titleError: () => titleError,
      memoError: () => memoError,
      canSave: canSave,
    );
  }
}
