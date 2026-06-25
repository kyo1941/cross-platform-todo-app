import Foundation

struct TodoItem: Equatable, Identifiable {
    var id: String
    var title: String
    var memo: String?
    var isDone: Bool
    var sortOrder: Int
    var createdAt: Int64
    var updatedAt: Int64
}
