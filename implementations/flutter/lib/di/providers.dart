import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/todo_database.dart';
import '../data/todo_local_data_source.dart';
import '../data/todo_repository.dart';

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
