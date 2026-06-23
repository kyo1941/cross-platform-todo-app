# all-kotlin

Android-native baseline implementation of the shared TODO app spec, using
Kotlin + Jetpack Compose, Room, Hilt, and Navigation Compose.

## Architecture

MVVM + Repository, in three layers:

```
ui/ (Compose screens)  ->  presentation/ (ViewModel + UiState)  ->  data/ (Repository -> LocalDataSource -> Room)
```

- `data/` — `TodoItem` domain model, Room `TodoEntity`/`TodoDao`/`TodoDatabase`,
  `TodoLocalDataSource`, and `TodoRepository` (single source of truth).
- `presentation/list` and `presentation/edit` — ViewModels and UI state.
- `ui/` — `TodoListScreen` (S01), `TodoEditScreen` (S02), `DeleteConfirmDialog` (S03).
- `di/` — Hilt modules.

The list observes `TodoRepository.observeAll()` as a `Flow`, so toggles, deletes,
and reorders propagate reactively without the ViewModel rewriting the list.

## Build & run

```sh
./gradlew :app:assembleDebug      # build the debug APK
./gradlew :app:installDebug       # install on a connected device/emulator
```

Requires the Android SDK; `local.properties` (gitignored) must point at it via
`sdk.dir`.
