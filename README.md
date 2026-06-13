# 📝 Cross-Platform TODO 比較プロジェクト

同一仕様の TODO アプリを複数の技術スタックで並行実装し、各実装のコードを比較するプロジェクトです。

## 実装スタック

| ディレクトリ | 技術 |
|---|---|
| `implementations/all-kotlin` | Kotlin Multiplatform + Compose Multiplatform |
| `implementations/all-swift` | Swift + SwiftUI |
| `implementations/kmp` | KMP（ロジック共有）+ ネイティブ UI |
| `implementations/cmp` | Compose Multiplatform フル共有 |
| `implementations/flutter` | Dart + Flutter |
| `implementations/react-native` | TypeScript + React Native |

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
