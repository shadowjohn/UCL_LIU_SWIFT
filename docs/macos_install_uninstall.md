# macOS 安裝、重裝、卸載與重設

本文說明肥米輸入法在 macOS 上的預期安裝、重裝、卸載與重設流程。專案目前仍以 Swift Package 的 `FeimiCore` 為主，macOS App、InputMethodKit 包裝與 installer 尚未實作；以下安裝命令是未來 macOS 原生輸入法完成後可採用的流程草案。

## 系統需求

- macOS 13 Ventura 或更新版本。
- Xcode 或 Command Line Tools。
- 未來若要建置 `.app`，需安裝可使用 `xcodebuild` 的 Xcode toolchain。

檢查開發工具：

```sh
xcodebuild -version
swift --version
```

若尚未安裝 Command Line Tools：

```sh
xcode-select --install
```

## 開發者安裝與重裝

目前 repo 內已有最小 InputMethodKit app scaffold 與 shell scripts。macOS 上可先用 scripts 建置、安裝到使用者的 Input Methods 目錄：

```sh
cd /path/to/UCL_LIU_SWIFT

bash scripts/build-macos-input-method.sh
bash scripts/install-macos-input-method.sh
```

目前 scaffold 會從使用者資料目錄依序讀取：

1. `liu.json`
2. `liu.cin`，並產生 `liu.json` cache
3. `liu-uni.tab`，並產生 `liu.cin` 與 `liu.json` cache

```sh
mkdir -p "$HOME/Library/Application Support/UCL_LIU_SWIFT"
cp /path/to/liu.json "$HOME/Library/Application Support/UCL_LIU_SWIFT/liu.json"
# 或：
cp /path/to/liu.cin "$HOME/Library/Application Support/UCL_LIU_SWIFT/liu.cin"
# 或：
cp /path/to/liu-uni.tab "$HOME/Library/Application Support/UCL_LIU_SWIFT/liu-uni.tab"
```

重裝前 install script 會停止既有輸入法程序並移除舊版 app；也可手動執行：

```sh
killall UCL_LIU_SWIFT 2>/dev/null || true

rm -rf "$HOME/Library/Input Methods/UCL_LIU_SWIFT.app"
```

重新複製 app 後，若系統仍載入舊版輸入法，請登出再登入，或重新啟動 macOS。

快速登出快捷鍵：

```text
Shift + Command + Q
```

未來若改成 Xcode project / scheme，可採用：

```sh
xcodebuild \
  -scheme UCL_LIU_SWIFT \
  -configuration Debug \
  CONFIGURATION_BUILD_DIR="$HOME/Library/Input Methods/" \
  build
```

## 使用者安裝

未來正式版本預期會提供 `.pkg` 或 installer app。安裝器的工作應包含：

- 將輸入法 app 安裝到 `$HOME/Library/Input Methods/` 或系統指定的位置。
- 檢查必要資料目錄是否存在。
- 提示使用者到系統設定加入輸入來源。

安裝完成後，請到：

```text
系統設定 > 鍵盤 > 文字輸入 > 編輯 > 新增輸入來源
```

加入肥米輸入法。首次安裝後，macOS 可能需要重新登入才會顯示新的輸入來源。

本專案可參考 ilimi 類似的 macOS 輸入法安裝做法，但目前尚未實作 installer，也不應假設已具備完整安裝器行為。

未來 installer 若採用 app 形式，可考慮在安裝後清除 quarantine、註冊 input source，並提示使用者仍需到系統設定確認輸入來源是否啟用。

## 卸載

卸載時預設只移除輸入法程式，保留使用者資料與字典。

1. 到系統設定移除輸入來源：

```text
系統設定 > 鍵盤 > 文字輸入 > 編輯
```

2. 停止正在執行的輸入法程序：

```sh
bash scripts/uninstall-macos-input-method.sh
```

或手動執行：

```sh
killall UCL_LIU_SWIFT 2>/dev/null || true
```

3. 刪除輸入法 app：

```sh
rm -rf "$HOME/Library/Input Methods/UCL_LIU_SWIFT.app"
```

若卸載後輸入來源仍出現在系統設定中，請登出再登入，或重新啟動 macOS。

## 重設

### Soft reset

Soft reset 用於清除設定、log 或暫存狀態，預設不刪除使用者字典。

未來若設定與 log 放在 Application Support，可用類似流程清除：

```sh
rm -f "$HOME/Library/Application Support/UCL_LIU_SWIFT/config.json"
rm -rf "$HOME/Library/Application Support/UCL_LIU_SWIFT/log"
```

清除後請重新啟動輸入法，必要時登出再登入。

### Full reset

Full reset 會刪除使用者資料目錄。這會移除自訂字典、設定與使用者放入的表格檔；執行前請先備份。

```sh
rm -rf "$HOME/Library/Application Support/UCL_LIU_SWIFT"
```

警告：若你在此目錄放了 `liu.json`、`liu.cin` 或 `liu-uni.tab`，full reset 會一併刪除。

## 使用者資料位置

使用者資料預設放在：

```sh
$HOME/Library/Application Support/UCL_LIU_SWIFT
```

打開資料夾：

```sh
open "$HOME/Library/Application Support/UCL_LIU_SWIFT"
```

此目錄可放：

- `liu.json`
- `liu.cin`
- `liu-uni.tab`

`liu-uni.tab` 有版權限制，不隨 repo 或安裝包提供，也不應簽入版本控制。專案可內建並散布的是 `pinyi.txt`。

## 權限與隱私

一般輸入不需要網路連線。輸入法應優先使用 macOS 文字輸入 client API 讀寫組字與文字內容。

`,,,z` / `,,,x` 這類功能會讀取或取代目前選取文字。理想情況下應透過文字輸入 client API 完成；若目標 app 不支援或 API 無法取得選取文字，未來可能 fallback 到 pasteboard / copy-paste 流程。

`0.01` 版建議預設只啟用直接 API 路徑：

- 透過目前的 input client 取得 selected range。
- 只有在選取範圍有效且長度大於 0 時才執行轉換。
- 讀取選取文字後，用 replacement range 直接替換原選取文字。
- 若 app 不支援讀取或替換選取文字，顯示簡短失敗訊息，不自動改用剪貼簿。

視實作方式與目標 app 限制，macOS 可能要求以下權限：

- Accessibility
- Input Monitoring
- Clipboard / Pasteboard 存取提示

若使用 pasteboard / copy-paste fallback，應做成使用者明確 opt-in。首次啟用時需說明：此路徑會暫時讀寫剪貼簿、可能需要系統權限、會盡量還原但不能保證保留所有格式。

剪貼簿 fallback 的最低安全要求：

- 優先保存完整 pasteboard items 與 types，而不是只保存文字。
- 操作前後檢查 pasteboard change count。
- 若期間被其他 app 改寫剪貼簿，不要強行還原覆蓋使用者的新內容。
- 設定 timeout 與焦點檢查；失敗時停止，不要亂貼。
- log 只記功能名、目標 bundle id、native/pasteboard 路徑、成功/失敗原因與字數；不要記錄選取原文或轉換後文字。

即使完成上述保護，剪貼簿還原仍只能做到 best effort。當其他 app 同時改寫剪貼簿、系統拒絕權限或目標 app 行為特殊時，仍可能無法完整還原。
