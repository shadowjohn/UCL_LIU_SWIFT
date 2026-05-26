# UCL_LIU_SWIFT TODO

更新日期：2026-05-26

## 粗估進度

以 `0.01` 版「可以在 macOS 順暢日常打字」作為目標，目前大約：

```text
已完成：約 40%
未完成：約 60%
```

這個估算偏保守，原因是 Feimi Core 已有一批可測功能，但 macOS InputMethodKit 實機行為、候選窗、權限、installer 與跨 App 驗收都還沒有在 mac 上跑完。

分項估算：

| 區塊 | 目前狀態 | 粗估完成度 |
| --- | --- | --- |
| Feimi Core 查碼/選字/字典 | 已有測試覆蓋，基本可用 | 75% |
| `pinyi.txt` / 同音 | 已接入 engine，注音模式尚缺 | 50% |
| macOS InputMethodKit 外殼 | scaffold 已有，尚未 mac 實機修正 | 25% |
| 復古候選窗 | 尚未開發 | 0% |
| 指令副作用與設定保存 | command parser 已有，實際行為尚缺 | 20% |
| `,,,z` / `,,,x` | core 反查已有，mac 選取文字流程尚缺 | 20% |
| installer / release | 只有 dev scripts，正式包裝尚缺 | 15% |
| macOS App 相容性驗收 | 尚未跑 TextEdit/Safari/VS Code 等矩陣 | 0% |

## 已完成

- [x] Swift Package skeleton。
- [x] `FeimiDictionary` lookup。
- [x] `v/r/s/f` 輔助選字。
- [x] 字根反查 `reverseLookup`。
- [x] `CinParser`。
- [x] `JsonDictionaryParser`。
- [x] `LiuTabParser`，測試使用人工合成 tab bytes，不簽入正版 `liu-uni.tab`。
- [x] `FeimiDictionaryLoader`：`liu.json` > `liu.cin` > `liu-uni.tab`。
- [x] `PinyiEngine` parser。
- [x] `CommandProcessor` 辨識 `,,,` 指令。
- [x] `FeimiEngine` 基本組字、候選、空白、數字、Enter、Esc、Backspace。
- [x] `FeimiEngine` 接上 `'pns` pinyi / 同音候選。
- [x] macOS `IMKServer` / `IMKInputController` 最小 scaffold。
- [x] dev build / install / uninstall scripts。
- [x] README 與 macOS install/uninstall 文件。

## 0.01 必做：可順暢打字

### P0：先在 macOS 跑起來

- [ ] 在 macOS + Xcode 上執行 `scripts/build-macos-input-method.sh`。
- [ ] 修正 macOS framework 編譯錯誤，確認 `.app` 可產生。
- [ ] 執行 `scripts/install-macos-input-method.sh`，確認輸入法出現在系統輸入來源。
- [ ] 放入 `liu.json` / `liu.cin` / `liu-uni.tab`，確認字典載入與 cache 產生。
- [ ] 若字典缺失，顯示可理解錯誤並寫 log，不讓輸入法 crash。

### P0：輸入事件與送字

- [ ] 在 TextEdit 驗證 a-z 與 `,.'[]+-` 字根輸入。
- [ ] 驗證 `Space` 送第一候選。
- [ ] 驗證數字鍵 `0...9` 以舊肥米 0-based 規則選候選。
- [ ] 驗證 `Enter` 送原始字根。
- [ ] 驗證 `Esc` 清空。
- [ ] 驗證 `Backspace` 刪除上一碼。
- [ ] 切換 App 或輸入來源時清掉 stale composing buffer。
- [ ] 系統快捷鍵、Command/Control/Option 組合鍵不要被攔截。

### P0：候選窗

- [x] 建立 AppKit 復古候選窗。
- [x] 顯示目前輸入碼。
- [x] 顯示 `0肥 1飛 2非 ...` 候選。
- [x] 跟隨目前輸入位置。
- [x] 支援候選過長時截斷或分頁。
- [x] 切換 App、送字、Esc 後正確關閉或重設。

### P0：基本指令副作用

- [ ] `,,,version` 顯示版本或送出版本文字。
- [ ] `,,,lock` / `,,,unlock` 真的切換遊戲/正常模式。
- [ ] `,,,s` / `,,,l` 調整候選窗寬度。
- [ ] `,,,+` / `,,,-` 調整候選窗縮放。
- [ ] 指令執行後清空組字狀態。

### P0：設定與 log

- [ ] 建立 `config.json`。
- [ ] 保存 UI 寬度、縮放、lock/unlock、繁簡模式。
- [ ] 建立 `log/uclliu_yyyyMMdd.log`。
- [ ] 記錄啟動、字典載入、字典轉換、pinyi 載入、IME event error、command error。
- [ ] log 不記錄使用者輸入內容全文。

### P0：macOS 實機驗收

- [ ] TextEdit 可日常打字。
- [ ] Safari 地址列 / 搜尋框不 crash。
- [ ] Chrome input / textarea 可輸入。
- [ ] VS Code editor 可輸入。
- [ ] Terminal 可輸入或至少不破壞快捷鍵。
- [ ] 快速連打不明顯卡頓。
- [ ] 睡眠喚醒、切換 App、切換輸入法後狀態不亂。

## 0.01 必做但可晚一點接：完整肥米感

- [ ] `,,,c` / `,,,t` 簡繁切換。
- [ ] `';` 注音模式。
- [ ] 注音模式候選查詢與 commit。
- [ ] 同音查詢候選分頁。
- [ ] 候選數超過 10 個時分頁或更多提示。
- [x] 開啟使用者資料夾的選單列項目。
- [ ] 重新載入字根的選單列項目。
- [ ] 重新載入 `pinyi.txt` 的選單列項目。

## 0.01 風險功能：`,,,z` / `,,,x`

目標是 0.01 至少在 TextEdit 可用，其他 App 逐步擴充。

- [ ] `,,,z`：讀目前選取文章。
- [ ] `,,,z`：用 `FeimiDictionary.reverseLookup` 轉成字根。
- [ ] `,,,z`：用 text input client replacement range 取代選取文字。
- [ ] `,,,x`：讀目前選取字根文字。
- [ ] `,,,x`：把字根轉回文章。
- [ ] `,,,x`：用 text input client replacement range 取代選取文字。
- [ ] native API 失敗時顯示清楚訊息，不自動碰剪貼簿。
- [ ] pasteboard fallback 做成明確 opt-in。
- [ ] pasteboard fallback 保存完整 pasteboard items/types，並檢查 change count。
- [ ] `,,,z` / `,,,x` log 只記 metadata，不記錄選取原文或轉換後文字。

## 0.02：安裝與發佈

- [ ] 正式 `.pkg` 或 `.dmg`。
- [ ] installer app 或 post-install 流程。
- [ ] 安裝後註冊 input source。
- [ ] 清除 quarantine 的安全處理。
- [ ] README 安裝流程改成正式使用者版。
- [ ] GitHub Actions 或 macOS release build 流程。

## 0.03：設定、詞庫與體驗

- [ ] 設定 UI。
- [ ] user phrase / custom dictionary。
- [ ] 使用者詞頻或排序調整。
- [ ] theme.json。
- [ ] 音效設定，評估 `wavs/` 是否可合法散布。
- [ ] 更完整的錯誤提示與診斷頁。

## 開發提醒

- `liu-uni.tab` 不可簽入。
- `wavs/` 目前不簽入。
- 任何從正版字根轉出的完整 `liu.cin` / `liu.json` 不簽入。
- 每完成一段功能、修正、決策或踩雷紀錄，要更新 `history.md` 並 commit。
- macOS 實機 build / install 的結果要回寫本檔與 `history.md`。
