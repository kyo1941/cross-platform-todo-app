import Foundation
import SwiftData

@Model
final class TodoEntity {
    @Attribute(.unique) var id: String
    var title: String
    var memo: String?
    var isDone: Bool
    var sortOrder: Int
    var createdAt: Int64
    var updatedAt: Int64

    init(
        id: String,
        title: String,
        memo: String?,
        isDone: Bool,
        sortOrder: Int,
        createdAt: Int64,
        updatedAt: Int64
    ) {
        self.id = id
        self.title = title
        self.memo = memo
        self.isDone = isDone
        self.sortOrder = sortOrder
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

extension TodoEntity {
    convenience init(item: TodoItem) {
        self.init(
            id: item.id,
            title: item.title,
            memo: item.memo,
            isDone: item.isDone,
            sortOrder: item.sortOrder,
            createdAt: item.createdAt,
            updatedAt: item.updatedAt
        )
    }

    func toDomain() -> TodoItem {
        TodoItem(
            id: id,
            title: title,
            memo: memo,
            isDone: isDone,
            sortOrder: sortOrder,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }

    func apply(_ item: TodoItem) {
        title = item.title
        memo = item.memo
        isDone = item.isDone
        sortOrder = item.sortOrder
        createdAt = item.createdAt
        updatedAt = item.updatedAt
    }
}
