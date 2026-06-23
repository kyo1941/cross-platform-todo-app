# all-swift

iOS-native implementation of the shared TODO app spec, using
Swift + SwiftUI and SwiftData.

## Architecture

MVVM + Repository + DataSource, with dependencies injected through SwiftUI
environment values:

```
View/ (SwiftUI views)  ->  ViewModel/ (@Observable)
                         ->  Repository protocol
                         ->  DataSource protocol
                         ->  SwiftData
```

- `Data/` — domain `TodoItem`, SwiftData `TodoEntity`, repository and data-source protocols.
- `Dependencies/` — app dependency container and SwiftUI environment key.
- `ViewModel/` — typed UI state and events for list/edit screens.
- `View/` — `TodoListView` (S01), `TodoEditView` (S02), `DeleteConfirmDialog` (S03).

The list ViewModel observes the repository stream. Mutations go through the
repository, which publishes the latest ordered list after successful writes.

## Build & run

The Xcode project is generated via [XcodeGen](https://github.com/yonaskolb/XcodeGen).

```sh
xcodegen generate                  # generate AllTodo.xcodeproj
open AllTodo.xcodeproj             # open in Xcode and run
```

Requires Xcode with the iOS SDK.
