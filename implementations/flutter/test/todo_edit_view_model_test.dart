import 'package:crosstodo_flutter/data/todo_item.dart';
import 'package:crosstodo_flutter/data/todo_repository.dart';
import 'package:crosstodo_flutter/di/providers.dart';
import 'package:crosstodo_flutter/presentation/edit/todo_edit_ui_state.dart';
import 'package:crosstodo_flutter/presentation/edit/todo_edit_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Minimal stub; add-mode validation never touches the repository.
class _StubRepository implements TodoRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(invocation.memberName.toString());
}

void main() {
  ProviderContainer makeContainer() {
    final container = ProviderContainer(
      overrides: [todoRepositoryProvider.overrideWithValue(_StubRepository())],
    );
    addTearDown(container.dispose);
    return container;
  }

  final provider = todoEditViewModelProvider; // family, called with null below.

  test('add mode starts non-saveable with no errors', () {
    final container = makeContainer();
    final state = container.read(provider(null));
    expect(state, isA<TodoEditAdd>());
    expect(state.canSave, isFalse);
    expect(state.titleError, isNull);
  });

  test('valid title enables save; clearing it shows the required error', () {
    final container = makeContainer();
    final vm = container.read(provider(null).notifier);

    vm.onTitleChange('Buy milk');
    expect(container.read(provider(null)).canSave, isTrue);

    vm.onTitleChange('');
    final state = container.read(provider(null));
    expect(state.canSave, isFalse);
    expect(state.titleError, errorTitleRequired);
  });

  test('title over 255 chars reports the too-long error', () {
    final container = makeContainer();
    final vm = container.read(provider(null).notifier);

    vm.onTitleChange('a' * 256);
    final state = container.read(provider(null));
    expect(state.canSave, isFalse);
    expect(state.titleError, errorTitleTooLong);
  });

  test('memo over 1000 chars reports the too-long error', () {
    final container = makeContainer();
    final vm = container.read(provider(null).notifier);

    vm.onTitleChange('ok');
    vm.onMemoChange('m' * 1001);
    final state = container.read(provider(null));
    expect(state.canSave, isFalse);
    expect(state.memoError, errorMemoTooLong);
  });

  test('edit mode seeds form from the existing item', () {
    final item = TodoItem(
      id: 'id-1',
      title: 'Existing',
      memo: 'note',
      isDone: false,
      sortOrder: 0,
      createdAt: 0,
      updatedAt: 0,
    );
    final state = TodoEditEdit(originalItem: item);
    expect(state.title, 'Existing');
    expect(state.memo, 'note');
    expect(state.canSave, isTrue);
    expect(state.navigationTitle, 'TODOを編集');
  });
}
