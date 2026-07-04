import 'package:uuid/uuid.dart';

import 'todo_item.dart';
import 'todo_local_data_source.dart';

abstract interface class TodoRepository {
  Stream<List<TodoItem>> observeAll();
  Future<TodoItem?> getById(String id);
  Future<TodoItem> add(String title, String? memo);
  Future<void> update(TodoItem item);
  Future<void> delete(String id);
  Future<void> toggleDone(String id);
  Future<void> reorder(List<String> orderedIds);
}

class DefaultTodoRepository implements TodoRepository {
  DefaultTodoRepository(this._localDataSource, {Uuid? uuid})
      : _uuid = uuid ?? const Uuid();

  final TodoLocalDataSource _localDataSource;
  final Uuid _uuid;

  @override
  Stream<List<TodoItem>> observeAll() => _localDataSource.observeAll();

  @override
  Future<TodoItem?> getById(String id) => _localDataSource.getById(id);

  @override
  Future<TodoItem> add(String title, String? memo) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final nextSortOrder = (await _localDataSource.getMaxSortOrder() ?? -1) + 1;
    final item = TodoItem(
      id: _uuid.v4(),
      title: title.trim(),
      memo: _normalizeMemo(memo),
      isDone: false,
      sortOrder: nextSortOrder,
      createdAt: now,
      updatedAt: now,
    );
    await _localDataSource.insert(item);
    return item;
  }

  @override
  Future<void> update(TodoItem item) {
    final normalized = item.copyWith(
      title: item.title.trim(),
      memo: () => _normalizeMemo(item.memo),
    );
    return _localDataSource.update(normalized);
  }

  @override
  Future<void> delete(String id) => _localDataSource.delete(id);

  @override
  Future<void> toggleDone(String id) async {
    final current = await _localDataSource.getById(id);
    if (current == null) return;
    await _localDataSource.update(
      current.copyWith(
        isDone: !current.isDone,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  @override
  Future<void> reorder(List<String> orderedIds) {
    final orders = {
      for (final (index, id) in orderedIds.indexed) id: index,
    };
    return _localDataSource.updateSortOrders(orders);
  }

  String? _normalizeMemo(String? memo) {
    final trimmed = memo?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }
}
