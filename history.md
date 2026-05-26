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
