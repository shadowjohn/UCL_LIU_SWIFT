# Changelog

肥米輸入法 macOS Swift 版的使用者可讀更新紀錄。

## 0.01-dev - 2026-06-05

### 新增

- 建立 Swift / AppKit / InputMethodKit 版肥米輸入法雛形，可用開發者 scripts build / install / uninstall。
- 完成 Feimi Core 基礎輸入流程：字根組字、候選查詢、0-based 數字選字、`Space` 送首選、`Enter` 送原碼、`Esc` 清空、`Backspace` 刪碼。
- 支援 `v/r/s/f` 輔助選字與字根反查。
- 支援 `liu.json`、`liu.cin`、`liu-uni.tab` 載入鏈；`liu.cin` / `liu-uni.tab` 可產生本機 cache。
- 支援 `pinyi.txt` 同音資料載入與 `'pns` 這類 pinyi 候選查詢。
- 新增復古肥米浮動文字框，顯示「肥 / 半 / 組字 / 候選 / 正常模式」。
- 浮動文字框可長駐、拖曳、保存位置，並支援 `,,,s` / `,,,l` / `,,,+` / `,,,-` 調整寬度與縮放。
- 新增 menu bar「肥」選單，包含關於、正常/遊戲模式、出字模式、畫面調整、Ctrl+Space 英/肥切換、字根檔、離開。
- 新增字根匯入流程：第一次缺字根會提示選取 `liu-uni.tab`、`.cin` 或 `.json`，也可從 `7.字根檔 > 匯入字根檔...` 手動匯入。
- 匯入字根前會先用暫存資料夾試載入；通過後才替換現有字根，並將被替換的字根/cache 備份到 `Dictionary Backups/<timestamp>/`。
- `wavs/` 打字音效檔已納入 repo，供後續接上音效功能。

### 改善

- macOS 輸入法顯示名稱改為「肥米」，技術識別仍保留 `UCL_LIU_SWIFT`。
- 安裝流程會註冊並嘗試啟用 input source；若系統設定尚未看到肥米，會提示使用者按 `Shift+Command+Q` 登出再登入。
- 對照一粒米 macOS 輸入法設定，補齊 input source metadata、menu icon、visibility 與 ad-hoc codesign 流程。
- 肥米文字框比例調整得更接近 Windows 版，文字上下置中。
- `Ctrl+Space` 改為肥米內部英/肥切換，不交給 macOS 切換輸入來源。
- README、TODO、macOS 安裝/卸載文件補齊目前支援、字根政策、權限風險與測試流程。

### 修正

- 修正 macOS install 後查不到新註冊 input source 的問題。
- 修正 macOS build 的 `isControlSpace(_:) -> Bool` 缺少明確 `return`。
- 修正復古文字框拖曳 callback 型別造成 macOS build 失敗。
- 修正肥模式在沒有字根 buffer 時按 `Backspace` 會被輸入法吃掉，導致無法刪除已輸出文字。
- 修正只有 a-z 和逗號可組字的問題，允許肥米常用 punctuation keys：`,.'[]+-`。

### 尚未完成

- `,,,c` / `,,,t` 簡繁切換尚未接上。
- `';` 注音模式、同音分頁、短根顯示尚未接上。
- `,,,z` / `,,,x` 框選文字與字根互轉尚未完成；macOS 版會優先走 text input client，剪貼簿 fallback 需使用者明確開啟。
- 正式 `.pkg` / `.dmg` installer 尚未完成。
- TextEdit、Safari、Chrome、VS Code、Terminal 等 macOS 實機輸入矩陣仍需驗收。

### 注意

- `liu-uni.tab` 有版權限制，不會簽入 repo，也不會隨安裝包提供。
- 由正版字根轉出的完整 `liu.cin` / `liu.json` 同樣不可簽入。
- 本版仍是 `0.01-dev`，目標是逐步逼近日常順暢打字。
