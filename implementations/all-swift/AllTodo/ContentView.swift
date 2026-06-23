import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            TodoListView()
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: TodoItem.self, inMemory: true)
}
