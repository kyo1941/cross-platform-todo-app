import SwiftUI

/// Reusable delete confirmation dialog.
/// Matches Kotlin's `DeleteConfirmDialog` (S03).
struct DeleteConfirmDialog: ViewModifier {
    let title: String?
    let onConfirm: () -> Void
    let onCancel: () -> Void

    var isPresented: Bool { title != nil }

    func body(content: Content) -> some View {
        content.alert(
            "削除の確認",
            isPresented: .constant(isPresented),
            presenting: title
        ) { _ in
            Button("キャンセル", role: .cancel) { onCancel() }
            Button("削除", role: .destructive) { onConfirm() }
        } message: { itemTitle in
            Text("「\(itemTitle)」を削除しますか？")
        }
    }
}

extension View {
    /// Presents a delete confirmation dialog for the item with the given title.
    func deleteConfirmDialog(
        title: String?,
        onConfirm: @escaping () -> Void,
        onCancel: @escaping () -> Void
    ) -> some View {
        modifier(DeleteConfirmDialog(title: title, onConfirm: onConfirm, onCancel: onCancel))
    }
}
