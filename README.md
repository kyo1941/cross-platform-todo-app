# 📝 Cross-Platform TODO 比較プロジェクト

同一仕様の TODO アプリを複数の技術スタックで並行実装し、各実装のコードを比較するプロジェクトです。

## 実装スタック

| ディレクトリ | 分類 | 技術 |
|---|---|---|
| `implementations/all-kotlin` | ネイティブ基準線 | Kotlin + Jetpack Compose（Android 単体, Room） |
| `implementations/all-swift` | ネイティブ基準線 | Swift + SwiftUI（Apple 単体, SwiftData） |
| `implementations/kmp` | クロスPF | KMP（ロジック共有）+ ネイティブ UI |
| `implementations/cmp` | クロスPF | Compose Multiplatform フル共有 |
| `implementations/flutter` | クロスPF | Dart + Flutter |
| `implementations/react-native` | クロスPF | TypeScript + React Native |

> `all-kotlin` / `all-swift` は各エコシステムの**単体ネイティブ実装**で、クロスプラットフォーム化のコストを測る基準線。`kmp` / `cmp` / `flutter` / `react-native` がコード共有戦略の比較対象。

## ディレクトリ構成

```
.
└── implementations/   # 各スタックの実装
    ├── all-kotlin/
    ├── all-swift/
    ├── kmp/
    ├── cmp/
    ├── flutter/
    └── react-native/
```
