import SwiftData
import SwiftUI

struct AppDependencies {
    var makeTodoRepository: @MainActor (ModelContext) -> any TodoRepository
}

extension AppDependencies {
    static let live = AppDependencies { modelContext in
        let localDataSource = SwiftDataTodoLocalDataSource(modelContext: modelContext)
        return DefaultTodoRepository(localDataSource: localDataSource)
    }
}

private struct AppDependenciesKey: EnvironmentKey {
    static let defaultValue: AppDependencies = .live
}

extension EnvironmentValues {
    var appDependencies: AppDependencies {
        get { self[AppDependenciesKey.self] }
        set { self[AppDependenciesKey.self] = newValue }
    }
}
