import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'todo_database.g.dart';

/// drift persistence model. The table name and (via build.yaml) the column
/// names follow the shared SQL schema (snake_case); Dart getters stay
/// camelCase. The generated row class is named [TodoRow] to keep it distinct
/// from the domain [TodoItem].
@DataClassName('TodoRow')
class TodoItems extends Table {
  @override
  String get tableName => 'todo_item';

  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get memo => text().nullable()();
  BoolColumn get isDone => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [TodoItems])
class TodoDatabase extends _$TodoDatabase {
  /// Primary constructor. Accepts any [QueryExecutor] so tests can pass an
  /// in-memory database.
  TodoDatabase(super.e);

  /// Opens the on-device database backed by a file in the app documents
  /// directory.
  TodoDatabase.open() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'todo.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
