# History

## 2026-05-26

- 決策：`liu-uni.tab` 為有版權字根檔，只能作為本機參考/測試資料，不可簽入 repo；已加入 `.gitignore` 避免誤提交。
- 參考來源：Python 版 `D:\GD\UCL_LIU` 作為完整流程參考；C# 版 `D:\mytools\UCL_LIU_CSharp` 作為精簡可用行為參考；`y1lichen/ilimi-inputmethod` 作為 macOS InputMethodKit 架構參考。
- 決策：`pinyi.txt` 可作為 0.01 版內建資源；`wavs/` 打字音效先作為本機參考，不簽入 repo。
- 工作規則：開發期間每完成一段可理解的功能、規格或修正，就建立小而清楚的 git commit。
- 決策：`0.01` 版需納入 `,,,z` 框選文章轉字根與 `,,,x` 框選字根轉文章；規格需明確處理 macOS 剪貼簿與權限風險。
- 設計調整：`,,,z` / `,,,x` 優先嘗試 macOS text input client 的選取範圍、substring 與 replacement API；剪貼簿與模擬 copy/paste 只作為 fallback。
- 實作啟動：曾建立 `codex/feimi-core-foundation` 分支；使用者確認本次可直接疊在 `main`，後續小步 commit 直接在 `main` 進行。
- 環境紀錄：Windows 工作站本機找不到 `swift` 與 `xcodebuild`，但 Docker Desktop 可用；Feimi Core Swift Package 測試先用 `swift:5.9` container 執行。
- 實作：完成 Swift Package skeleton 與 `Candidate` value type；已用 Docker Swift 跑過 `FeimiDictionaryTests.testPackageImportsFeimiCore`。
- 實作：完成 `FeimiDictionary` 基本 lookup 與 code lowercasing；Docker Swift `FeimiDictionaryTests` 4 tests passing。
- 實作：完成 `v/r/s/f` 輔助選字與 reverse lookup；Docker Swift `FeimiDictionaryTests` 7 tests passing。
- 實作：完成 `CinParser`，支援 `%chardef begin/end` 解析、空白行忽略與缺少 chardef 區塊錯誤；Docker Swift `CinParserTests` 3 tests passing。
- 實作：完成 `PinyiEngine`，支援 `VERSION_0.01` header、注音 key/symbol 雙向轉換、候選查詢與同音去重；Docker Swift `PinyiEngineTests` 2 tests passing。
- 實作：完成 `CommandProcessor`，支援 0.01 的 `,,,` 指令與大小寫不敏感辨識；Docker Swift `CommandProcessorTests` 2 tests passing。
- 實作：完成 `FeimiEngine` 基本輸入狀態機，支援組字 buffer、候選刷新、空白送首選、Enter 送原碼或觸發 `,,,` 指令、Backspace 與 Escape；Docker Swift 全套 19 tests passing。
- 文件：新增 macOS 安裝、重裝、卸載與重設草案，明確標示 macOS app/installer 尚未實作，並記錄 `liu-uni.tab` 不隨 repo/installer 提供與 `,,,z`/`,,,x` 權限風險。
- 決策：`0.01` 的 `,,,z`/`,,,x` 預設只走 IMK/text input client 直接選取範圍讀寫；剪貼簿 copy/paste fallback 需明確 opt-in，且 log 不記錄選取原文或轉換後文字。
- 決策：沿用舊版肥米 0-based 候選選字規則；候選窗顯示 `0字 1字 ...`，空白與數字 `0` 送第一候選，數字 `1` 送第二候選。
- 實作：新增 macOS InputMethodKit 最小外殼草案，包含 `IMKServer` 啟動、`FeimiInputController` 鍵盤事件轉接、`liu.cin` 使用者資料載入，以及 build/install/uninstall scripts；Windows 端已用 XML 檢查、Docker Swift 全套 22 tests 與 Docker bash `-n` scripts 語法檢查。
