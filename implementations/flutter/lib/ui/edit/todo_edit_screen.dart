import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../presentation/edit/todo_edit_ui_state.dart';
import '../../presentation/edit/todo_edit_view_model.dart';

class TodoEditScreen extends ConsumerStatefulWidget {
  const TodoEditScreen({
    super.key,
    required this.todoId,
    required this.onNavigateBack,
  });

  final String? todoId;
  final VoidCallback onNavigateBack;

  @override
  ConsumerState<TodoEditScreen> createState() => _TodoEditScreenState();
}

class _TodoEditScreenState extends ConsumerState<TodoEditScreen> {
  final _titleController = TextEditingController();
  final _memoController = TextEditingController();
  late final StreamSubscription<void> _navigateBackSubscription;

  @override
  void initState() {
    super.initState();
    _navigateBackSubscription = ref
        .read(todoEditViewModelProvider(widget.todoId).notifier)
        .navigateBack
        .listen((_) => widget.onNavigateBack());
  }

  @override
  void dispose() {
    _navigateBackSubscription.cancel();
    _titleController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = todoEditViewModelProvider(widget.todoId);
    final viewModel = ref.read(provider.notifier);
    final uiState = ref.watch(provider);

    ref.listen<TodoEditUiState>(provider, (previous, next) {
      if (previous is TodoEditLoading && next is TodoEditEdit) {
        _titleController.text = next.title;
        _memoController.text = next.memo;
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(uiState.navigationTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: '戻る',
          onPressed: uiState.isSaving ? null : viewModel.onCancelClick,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              onChanged: viewModel.onTitleChange,
              enabled: !uiState.isSaving,
              maxLines: 1,
              decoration: InputDecoration(
                labelText: 'タイトル',
                border: const OutlineInputBorder(),
                errorText: uiState.titleError,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _memoController,
              onChanged: viewModel.onMemoChange,
              enabled: !uiState.isSaving,
              minLines: 3,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                labelText: 'メモ',
                border: const OutlineInputBorder(),
                errorText: uiState.memoError,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: uiState.canSave ? viewModel.onSaveClick : null,
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }
}
