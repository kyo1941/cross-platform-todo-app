import SwiftUI

struct TodoEditView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: TodoEditViewModel?
    @State private var showDiscardAlert = false

    let todoId: String?

    var body: some View {
        Group {
            if let viewModel {
                editForm(viewModel: viewModel)
            } else {
                ProgressView()
            }
        }
        .navigationTitle(viewModel?.navigationTitle ?? "TODOを編集")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button {
                    handleBack()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.backward")
                        Text("戻る")
                    }
                }
                .disabled(viewModel?.isSaving == true)
            }
        }
        .alert("変更の破棄", isPresented: $showDiscardAlert) {
            Button("キャンセル", role: .cancel) {}
            Button("破棄", role: .destructive) { dismiss() }
        } message: {
            Text("編集内容が保存されていません。破棄しますか？")
        }
        .onAppear {
            if viewModel == nil {
                let repo = TodoRepository(modelContext: modelContext)
                viewModel = TodoEditViewModel(repository: repo, todoId: todoId)
            }
        }
        .onChange(of: viewModel?.shouldDismiss) { _, newValue in
            if newValue == true {
                dismiss()
            }
        }
    }

    @ViewBuilder
    private func editForm(viewModel: TodoEditViewModel) -> some View {
        ScrollView {
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("タイトル")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    TextField("タイトル", text: Bindable(viewModel).title)
                        .textFieldStyle(.roundedBorder)
                        .disabled(viewModel.isSaving)
                    if let error = viewModel.titleError {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }
                .padding(.bottom, 16)

                VStack(alignment: .leading, spacing: 4) {
                    Text("メモ")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    TextField("メモ", text: Bindable(viewModel).memo, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(3...10)
                        .disabled(viewModel.isSaving)
                    if let error = viewModel.memoError {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }
                .padding(.bottom, 24)

                Button {
                    viewModel.onSaveClick()
                } label: {
                    Text("保存")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(!viewModel.canSave)
            }
            .padding(16)
        }
    }

    private func handleBack() {
        guard let viewModel else {
            dismiss()
            return
        }
        if viewModel.hasChanges {
            showDiscardAlert = true
        } else {
            dismiss()
        }
    }
}
