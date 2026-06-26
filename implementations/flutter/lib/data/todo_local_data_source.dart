import 'package:drift/drift.dart';

import 'todo_database.dart';
import 'todo_item.dart';

/// Abstraction over the local persistence layer. Works in terms of [TodoItem].
abstract interface class TodoLocalDataSource {
  Stream<List<TodoItem>> observeAll();
  Future<int?> getMaxSortOrder();
  Future<TodoItem?> getById(String id);
  Future<void> insert(TodoItem item);
  Future<void> update(TodoItem item);
  Future<void> delete(String id);
  Future<void> updateSortOrders(Map<String, int> orders);
}

/// drift-backed implementation of [TodoLocalDataSource].
class DriftTodoLocalDataSource implements TodoLocalDataSource {
  DriftTodoLocalDataSource(this._db);

  final TodoDatabase _db;

  @override
  Stream<List<TodoItem>> observeAll() {
    final query = _db.select(_db.todoItems)
      ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]);
    return query.watch().map((rows) => rows.map(_toDomain).toList());
  }

  @override
  Future<int?> getMaxSortOrder() async {
    final max = _db.todoItems.sortOrder.max();
    final query = _db.selectOnly(_db.todoItems)..addColumns([max]);
    final row = await query.getSingleOrNull();
    return row?.read(max);
  }

  @override
  Future<TodoItem?> getById(String id) async {
    final query = _db.select(_db.todoItems)..where((t) => t.id.equals(id));
    final row = await query.getSingleOrNull();
    return row == null ? null : _toDomain(row);
  }

  @override
  Future<void> insert(TodoItem item) =>
      _db.into(_db.todoItems).insert(_toCompanion(item));

  @override
  Future<void> update(TodoItem item) =>
      _db.update(_db.todoItems).replace(_toCompanion(item));

  @override
  Future<void> delete(String id) =>
      (_db.delete(_db.todoItems)..where((t) => t.id.equals(id))).go();

  @override
  Future<void> updateSortOrders(Map<String, int> orders) {
    return _db.transaction(() async {
      for (final entry in orders.entries) {
        await (_db.update(_db.todoItems)..where((t) => t.id.equals(entry.key)))
            .write(TodoItemsCompanion(sortOrder: Value(entry.value)));
      }
    });
  }

  TodoItem _toDomain(TodoRow row) => TodoItem(
        id: row.id,
        title: row.title,
        memo: row.memo,
        isDone: row.isDone,
        sortOrder: row.sortOrder,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
      );

  TodoItemsCompanion _toCompanion(TodoItem item) => TodoItemsCompanion(
        id: Value(item.id),
        title: Value(item.title),
        memo: Value(item.memo),
        isDone: Value(item.isDone),
        sortOrder: Value(item.sortOrder),
        createdAt: Value(item.createdAt),
        updatedAt: Value(item.updatedAt),
      );
}
