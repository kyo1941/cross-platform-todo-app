import SwiftUI

struct TodoEditView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: TodoEditViewModel?

    let repository: any TodoRepository
    let todoId: String?

    var body: some View {
        Group {
            if let viewModel {
                editForm(viewModel: viewModel)
            } else {
                ProgressView()
            }
        }
        .navigationTitle(viewModel?.uiState.navigationTitle ?? "TODOを編集")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button {
                    viewModel?.onCancelClick()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.backward")
                        Text("戻る")
                    }
                }
                .disabled(viewModel?.uiState.isSaving == true)
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = TodoEditViewModel(repository: repository, todoId: todoId)
            }
        }
        .onChange(of: viewModel?.event) { _, newValue in
            guard let event = newValue else { return }
            switch event {
            case .navigateBack:
                dismiss()
            }
            viewModel?.clearEvent()
        }
    }

    @ViewBuilder
    private func editForm(viewModel: TodoEditViewModel) -> some View {
        let uiState = viewModel.uiState
        ScrollView {
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("タイトル")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    TextField(
                        "タイトル",
                        text: Binding(
                            get: { viewModel.uiState.title },
                            set: { viewModel.onTitleChange($0) }
                        )
                    )
                    .textFieldStyle(.roundedBorder)
                    .disabled(uiState.isSaving)
                    if let error = uiState.titleError {
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
                    TextField(
                        "メモ",
                        text: Binding(
                            get: { viewModel.uiState.memo },
                            set: { viewModel.onMemoChange($0) }
                        ),
                        axis: .vertical
                    )
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(3...10)
                    .disabled(uiState.isSaving)
                    if let error = uiState.memoError {
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
                .disabled(!uiState.canSave)
            }
            .padding(16)
        }
    }
}
