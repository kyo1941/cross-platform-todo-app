import SwiftUI

struct DeleteConfirmDialog: ViewModifier {
    let title: String?
    @Binding var isPresented: Bool
    let onConfirm: () -> Void
    let onCancel: () -> Void

    func body(content: Content) -> some View {
        content.alert(
            "削除の確認",
            isPresented: $isPresented,
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
    func deleteConfirmDialog(
        title: String?,
        isPresented: Binding<Bool>,
        onConfirm: @escaping () -> Void,
        onCancel: @escaping () -> Void
    ) -> some View {
        modifier(DeleteConfirmDialog(
            title: title,
            isPresented: isPresented,
            onConfirm: onConfirm,
            onCancel: onCancel
        ))
    }
}
