import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.appDependencies) private var dependencies
    @State private var repository: (any TodoRepository)?

    var body: some View {
        Group {
            if let repository {
                NavigationStack {
                    TodoListView(repository: repository)
                }
            } else {
                ProgressView()
            }
        }
        .onAppear {
            if repository == nil {
                repository = dependencies.makeTodoRepository(modelContext)
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: TodoEntity.self, inMemory: true)
}
