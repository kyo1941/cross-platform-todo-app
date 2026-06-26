import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/todo_database.dart';
import '../data/todo_local_data_source.dart';
import '../data/todo_repository.dart';

/// Dependency-injection wiring (Riverpod), equivalent to the Hilt modules in
/// all-kotlin: it builds the database, data source, and repository graph.

final todoDatabaseProvider = Provider<TodoDatabase>((ref) {
  final db = TodoDatabase.open();
  ref.onDispose(db.close);
  return db;
});

final todoLocalDataSourceProvider = Provider<TodoLocalDataSource>((ref) {
  return DriftTodoLocalDataSource(ref.watch(todoDatabaseProvider));
});

final todoRepositoryProvider = Provider<TodoRepository>((ref) {
  return DefaultTodoRepository(ref.watch(todoLocalDataSourceProvider));
});
