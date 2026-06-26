import 'package:crosstodo_flutter/data/todo_database.dart';
import 'package:crosstodo_flutter/data/todo_local_data_source.dart';
import 'package:crosstodo_flutter/data/todo_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late TodoDatabase db;
  late TodoRepository repository;

  setUp(() {
    db = TodoDatabase(NativeDatabase.memory());
    repository = DefaultTodoRepository(DriftTodoLocalDataSource(db));
  });

  tearDown(() async {
    await db.close();
  });

  test('add assigns incrementing sortOrder starting at 0', () async {
    final first = await repository.add('A', null);
    final second = await repository.add('B', null);
    expect(first.sortOrder, 0);
    expect(second.sortOrder, 1);
  });

  test('add trims the title and stores a blank memo as null', () async {
    final item = await repository.add('  hello  ', '   ');
    expect(item.title, 'hello');
    expect(item.memo, isNull);

    final withMemo = await repository.add('x', '  note  ');
    expect(withMemo.memo, 'note');
  });

  test('toggleDone flips isDone', () async {
    final item = await repository.add('A', null);
    await repository.toggleDone(item.id);
    expect((await repository.getById(item.id))!.isDone, isTrue);
    await repository.toggleDone(item.id);
    expect((await repository.getById(item.id))!.isDone, isFalse);
  });

  test('reorder reassigns sortOrder to 0,1,2 by position', () async {
    final a = await repository.add('A', null);
    final b = await repository.add('B', null);
    final c = await repository.add('C', null);

    await repository.reorder([c.id, a.id, b.id]);

    final items = await repository.observeAll().first;
    expect(items.map((e) => e.id).toList(), [c.id, a.id, b.id]);
    expect(items.map((e) => e.sortOrder).toList(), [0, 1, 2]);
  });

  test('update normalizes title and memo', () async {
    final item = await repository.add('A', 'memo');
    await repository.update(item.copyWith(title: '  B  ', memo: () => '   '));
    final updated = await repository.getById(item.id);
    expect(updated!.title, 'B');
    expect(updated.memo, isNull);
  });

  test('delete removes the item', () async {
    final item = await repository.add('A', null);
    await repository.delete(item.id);
    expect(await repository.getById(item.id), isNull);
  });

  test('observeAll orders by sortOrder ascending', () async {
    await repository.add('A', null);
    await repository.add('B', null);
    final items = await repository.observeAll().first;
    expect(items.map((e) => e.title).toList(), ['A', 'B']);
  });
}
