# all-swift

iOS-native implementation of the shared TODO app spec, using
Swift + SwiftUI and SwiftData.

## Architecture

MVVM + Repository, in three layers:

```
View/ (SwiftUI views)  ->  ViewModel/ (@Observable)  ->  Data/ (Repository -> SwiftData)
```

- `Data/` — `TodoItem` SwiftData model, `TodoRepository`.
- `ViewModel/` — `TodoListViewModel`, `TodoEditViewModel`.
- `View/` — `TodoListView` (S01), `TodoEditView` (S02), `DeleteConfirmDialog` (S03).

The list observes the repository reactively, so toggles, deletes,
and reorders propagate without the ViewModel rewriting the list.

## Build & run

The Xcode project is generated via [XcodeGen](https://github.com/yonaskolb/XcodeGen).

```sh
xcodegen generate                  # generate AllTodo.xcodeproj
open AllTodo.xcodeproj             # open in Xcode and run
```

Requires Xcode with the iOS SDK.
