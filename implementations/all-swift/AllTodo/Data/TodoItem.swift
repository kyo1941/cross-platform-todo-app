import Foundation
import SwiftData

/// Persistence model for a single to-do entry.
/// Property names and constraints match the shared data model spec.
@Model
final class TodoItem {

    /// UUID string primary key (matches Kotlin `UUID.randomUUID().toString()`).
    var id: String
    /// Required. Max 255 characters (validated at the presentation layer).
    var title: String
    /// Optional. Max 1000 characters (validated at the presentation layer).
    var memo: String?
    /// Completion status.
    var isDone: Bool
    /// Manual sort order (ascending). New items get `MAX(sortOrder) + 1`.
    var sortOrder: Int
    /// Epoch milliseconds. Set once on creation.
    var createdAt: Int64
    /// Epoch milliseconds. Updated on every mutation.
    var updatedAt: Int64

    init(
        id: String = UUID().uuidString,
        title: String,
        memo: String? = nil,
        isDone: Bool = false,
        sortOrder: Int = 0,
        createdAt: Int64 = Int64(Date().timeIntervalSince1970 * 1000),
        updatedAt: Int64 = Int64(Date().timeIntervalSince1970 * 1000)
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
