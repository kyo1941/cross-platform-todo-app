import SwiftUI

/// TODO edit/create screen (S02). Stub — full implementation in Commit 4.
struct TodoEditView: View {
    let todoId: String?

    var body: some View {
        Text(todoId != nil ? "TODO編集" : "TODO作成")
            .navigationTitle(todoId != nil ? "TODO編集" : "TODO作成")
    }
}
