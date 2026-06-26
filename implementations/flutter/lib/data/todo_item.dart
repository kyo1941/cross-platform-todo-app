/// Domain model for a single to-do entry. Shared across all implementations
/// (see the data model in the project spec).
class TodoItem {
  const TodoItem({
    required this.id,
    required this.title,
    required this.memo,
    required this.isDone,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String? memo;
  final bool isDone;
  final int sortOrder;

  /// Epoch millis (UTC). Set once at creation, never changed afterwards.
  final int createdAt;

  /// Epoch millis (UTC). Overwritten with the current time on every update.
  final int updatedAt;

  TodoItem copyWith({
    String? id,
    String? title,
    String? Function()? memo,
    bool? isDone,
    int? sortOrder,
    int? createdAt,
    int? updatedAt,
  }) {
    return TodoItem(
      id: id ?? this.id,
      title: title ?? this.title,
      memo: memo != null ? memo() : this.memo,
      isDone: isDone ?? this.isDone,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is TodoItem &&
      other.id == id &&
      other.title == title &&
      other.memo == memo &&
      other.isDone == isDone &&
      other.sortOrder == sortOrder &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt;

  @override
  int get hashCode =>
      Object.hash(id, title, memo, isDone, sortOrder, createdAt, updatedAt);
}
