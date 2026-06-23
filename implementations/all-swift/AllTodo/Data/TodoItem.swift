import Foundation
import SwiftData

@Model
final class TodoItem {

    var id: String
    var title: String
    var memo: String?
    var isDone: Bool
    var sortOrder: Int
    var createdAt: Int64
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
