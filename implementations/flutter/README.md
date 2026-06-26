# flutter

Cross-platform implementation of the shared TODO app spec, using
Dart + Flutter, Riverpod (state + DI), drift (reactive SQLite), and go_router.

## Architecture

MVVM + Repository, in three layers:

```
ui/ (widgets/screens)  ->  presentation/ (Notifier + UiState)  ->  data/ (Repository -> LocalDataSource -> drift)
```

- `data/` — `TodoItem` domain model, drift `TodoDatabase`/table (`todo_item`),
  `TodoLocalDataSource`, and `TodoRepository` (single source of truth).
- `presentation/list` and `presentation/edit` — Riverpod `Notifier`s and the
  sum-type UI states (`DeleteConfirmation`, `TodoEditUiState` as sealed classes).
- `ui/` — `TodoListScreen` (S01), `TodoEditScreen` (S02), `DeleteConfirmDialog` (S03).
- `di/` — Riverpod providers wiring the database/data-source/repository graph.

The list watches `TodoRepository.observeAll()` as a `Stream` (drift `.watch()`),
so toggles, deletes, and reorders propagate reactively without the view model
rewriting the list.

## Setup

drift generates `*.g.dart` (gitignored); generate it before building or testing:

```sh
flutter pub get
dart run build_runner build
```

## Build & run

```sh
flutter run                        # run on a connected device/simulator
flutter test                       # repository + view-model unit tests
flutter analyze                    # static analysis
```

Requires the Flutter SDK. Targets Android and iOS (`flutter create` platforms).
