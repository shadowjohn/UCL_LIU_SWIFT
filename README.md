# UCL_LIU_SWIFT

macOS 原生版「肥米輸入法」。

這個專案延續 `UCL_LIU` / `UCL_LIU_CSharp` 的肥米使用習慣，目標是在 macOS 上做出自己的 Swift / AppKit / InputMethodKit 輸入法，而不是 Rime schema，也不是套殼。

目前狀態：`0.01-dev`

- Feimi Core 已可查碼、選候選、反查、解析 `pinyi.txt`、解析 `liu.cin` / `liu.json` / `liu-uni.tab`。
- macOS InputMethodKit app scaffold 已建立，可在 macOS 上嘗試 build / install。
- 復古候選窗、完整 installer、更多 App 相容性測試仍在開發中。

## 作者與來源

肥米系列原始專案：

- `UCL_LIU`
- `UCL_LIU_CSharp`

本專案是 macOS Swift 版實作，參考 Python 版完整流程、C# 版簡化行為，以及 macOS 上 `ilimi-inputmethod` 的 InputMethodKit 架構。

## 版權

程式碼使用 MIT License。詳見 [LICENSE](LICENSE)。

字根檔另有版權限制：

- `liu-uni.tab` 不會放進 repo。
- 由正版字根轉出的完整 `liu.cin` / `liu.json` 也不會放進 repo。
- 使用者需要自行準備合法來源的字根檔。

內建可散布資源：

- `pinyi.txt`

## 系統需求

- macOS 13 Ventura 或更新版本
- Xcode 或 Command Line Tools
- Swift toolchain

確認工具：

```sh
xcodebuild -version
swift --version
```

若尚未安裝 Command Line Tools：

```sh
xcode-select --install
```

## 安裝方式

目前是開發者預覽流程，請在 macOS 上執行：

```sh
git clone <this-repo-url>
cd UCL_LIU_SWIFT

bash scripts/build-macos-input-method.sh
bash scripts/install-macos-input-method.sh
```

安裝後到：

```text
系統設定 > 鍵盤 > 文字輸入 > 編輯 > 新增輸入來源
```

加入「肥米」。如果第一次沒有看到輸入法，請登出再登入，或重新啟動 macOS。

快速登出快捷鍵：

```text
Shift + Command + Q
```

## 字根檔放哪裡

使用者資料目錄：

```sh
$HOME/Library/Application Support/UCL_LIU_SWIFT
```

建立資料夾：

```sh
mkdir -p "$HOME/Library/Application Support/UCL_LIU_SWIFT"
open "$HOME/Library/Application Support/UCL_LIU_SWIFT"
```

可放入以下任一檔案：

```text
liu.json
liu.cin
liu-uni.tab
pinyi.txt
```

載入順序：

1. 若有 `liu.json`，直接載入。
2. 若沒有 `liu.json` 但有 `liu.cin`，載入後產生 `liu.json` cache。
3. 若只有 `liu-uni.tab`，轉出 `liu.cin` 與 `liu.json` cache。
4. 若三者都沒有，輸入法會記錄錯誤，候選字表為空。

## 使用方式

基本打字行為：

- 輸入字根後顯示候選。
- `Space` 送出第一候選。
- 數字鍵以舊肥米規則選字：`0` 是第一候選，`1` 是第二候選。
- `Enter` 送出原始字根。
- `Esc` 清空組字。
- `Backspace` 刪除上一碼。
- 支援 `v/r/s/f` 輔助選字。

候選顯示沿用舊風格：

```text
0肥 1飛 2非 3啡 ...
```

同音查詢：

```text
'pns
```

會顯示類似：

```text
0你 1妳 2擬 ...
```

## 肥米指令

目前 core 已辨識下列指令，macOS 外殼會逐步接上完整行為：

```text
,,,unlock      正常模式
,,,lock        遊戲模式
,,,version     顯示版本
,,,c           切換簡體
,,,t           切換繁體
,,,s           UI 變窄
,,,l           UI 變寬
,,,+           UI 變大
,,,-           UI 變小
,,,z           框選文章轉字根
,,,x           框選字根轉文章
```

`0.01` 會優先把日常打字手感做穩。`,,,z` / `,,,x` 牽涉 macOS 選取文字、剪貼簿與權限，會採保守策略實作。

## 權限與隱私

一般打字不需要網路，也不會上傳內容。

`,,,z` / `,,,x` 這類框選轉換功能會讀取或取代目前選取文字。macOS 版預設策略：

- 優先使用 InputMethodKit / text input client API。
- native API 失敗時，不自動改用剪貼簿。
- 剪貼簿 copy/paste fallback 必須由使用者明確開啟。
- log 只記功能、目標 bundle id、成功/失敗原因、字數等 metadata，不記錄原文或轉換後文字。
- 若使用 pasteboard fallback，剪貼簿還原只能做到 best effort。

可能涉及的 macOS 權限：

- Accessibility
- Input Monitoring
- Clipboard / Pasteboard 存取提示

## 卸載方式

先到系統設定移除輸入來源：

```text
系統設定 > 鍵盤 > 文字輸入 > 編輯
```

再執行：

```sh
bash scripts/uninstall-macos-input-method.sh
```

手動移除：

```sh
killall UCL_LIU_SWIFT 2>/dev/null || true
rm -rf "$HOME/Library/Input Methods/UCL_LIU_SWIFT.app"
```

卸載預設保留使用者資料：

```sh
$HOME/Library/Application Support/UCL_LIU_SWIFT
```

完整重設會刪除字根、設定與 cache，請先備份：

```sh
rm -rf "$HOME/Library/Application Support/UCL_LIU_SWIFT"
```

## 開發

目前 Feimi Core 是 Swift Package，可在非 macOS 環境用 Docker 跑核心測試：

```sh
docker run --rm -v "$PWD":/workspace -w /workspace swift:5.9 swift test
```

macOS app scaffold 位於：

```text
macos/UCL_LIU_SWIFT/
```

建置 scripts：

```text
scripts/build-macos-input-method.sh
scripts/install-macos-input-method.sh
scripts/uninstall-macos-input-method.sh
```

核心模組：

```text
Sources/FeimiCore/
```

測試：

```text
Tests/FeimiCoreTests/
```

## 目前支援

- `FeimiDictionary` 字根查詢
- 0-based 候選選字
- `v/r/s/f` 輔助選字
- 字根反查
- `CinParser`
- `JsonDictionaryParser`
- `LiuTabParser`
- `FeimiDictionaryLoader`
- `PinyiEngine`
- `CommandProcessor`
- `FeimiEngine`
- 最小 macOS InputMethodKit shell

## 已知限制

- 尚未完成復古 AppKit 候選窗。
- 尚未完成正式 `.pkg` / `.dmg` installer。
- macOS 實機 App 相容性仍需測 TextEdit、Safari、Chrome、VS Code、Terminal 等。
- `,,,lock` / `,,,unlock` 等模式目前 core 已辨識，外殼行為仍需補齊。
- `,,,z` / `,,,x` 需要 macOS 權限與選取文字流程實測。
- 音效 `wavs/` 已隨 repo 簽入，供後續接上打字音使用。

## 參考資料

- `UCL_LIU`
- `UCL_LIU_CSharp`
- `y1lichen/ilimi-inputmethod`
- Apple InputMethodKit
- Apple AppKit text input client APIs

## 開發目標

UCL_LIU_SWIFT 的目標是：

```text
macOS 原生肥米輸入法
不是 Rime schema
不是套殼
而是肥米自己的 UI、自己的引擎、自己的手感
```
