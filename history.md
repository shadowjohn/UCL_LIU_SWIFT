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
- 實作：新增 macOS InputMethodKit 最小外殼草案，包含 `IMKServer` 啟動、`FeimiInputController` 鍵盤事件轉接、使用者資料目錄字典載入，以及 build/install/uninstall scripts；Windows 端已用 XML 檢查、Docker Swift 全套 22 tests 與 Docker bash `-n` scripts 語法檢查。
- 實作：完成 `liu.json` / `liu.cin` / `liu-uni.tab` 載入鏈；`liu.json` 優先，`liu.cin` 會產生 `liu.json` cache，`liu-uni.tab` 會產生 `liu.cin` 與 `liu.json` cache；測試使用人工合成 tab bytes，未簽入有版權字根。
- 修正：macOS key handling 允許肥米字根常用 punctuation keys `,.'[]+-`，避免只有 a-z 與逗號可進入組字 buffer。
- 實作：`FeimiEngine` 接上 `PinyiEngine`，支援 `'pns` 這類 pinyi key 候選與以單字反查同音候選；macOS 外殼會讀使用者資料夾 `pinyi.txt`，沒有時使用 bundle 內建 `pinyi.txt`。
- 文件：參考 `UCL_LIU_CSharp` README 結構新增 macOS Swift 版 `README.md`，涵蓋專案定位、安裝/卸載、字根檔政策、使用方式、指令、權限隱私、開發與已知限制。
- 文件：新增 `TODO.md`，粗估 `0.01` 可順暢打字目標目前約完成 40%、剩餘約 60%，並列出 macOS 實機、候選窗、指令副作用、設定/log、`,,,z`/`,,,x`、installer 與驗收待辦。
- 修正：macOS install script 複製輸入法後會呼叫 app 的 `install` 模式執行 `TISRegisterInputSource` / enable input source，並提示使用者若系統設定仍看不到輸入法，按 `Shift+Command+Q` 登出後重進。
- 修正：`TISCreateInputSourceList` 改用 `includeAllInstalled = true`，避免剛註冊但尚未啟用的 input source 被查詢流程排除；同時清掉 macOS build 的 unused result warnings。
- 修正：macOS 輸入法 plist 改用合法且含 `inputmethod` 的 bundle id `tw.3wa.inputmethod.UCL-LIU-SWIFT`，輸入來源 id 固定為 `tw.3wa.UCL_LIU_SWIFT`；補上 `LSBackgroundOnly`、`ComponentInputModeDict` 與 icon key，並在註冊後查不到輸入來源時輸出附近 TIS 診斷。
- 修正：對照 `y1lichen/ilimi-inputmethod` 後，macOS plist 改回 top-level TIS input source 設定並補齊一粒米使用的 visibility/menu icon/Touch Bar/caps-lock 等 key；註冊查找改為掃全部 TIS sources 並同時比對 input source id 與 input mode id；build/install script 會嘗試 ad-hoc codesign 與 lsregister。
- 實作：新增復古肥米浮動候選窗與 macOS menu bar「肥」status item；候選窗顯示 `肥`、`半`、目前輸入碼、`0候選 1候選 ...` 與 `正常模式`，送字、Esc、切換輸入法時會收起；新增 `FeimiDisplayFormatter` 與測試固定顯示格式。
- 實作：接上復古浮動窗控制指令，`,,,lock` / `,,,unlock` 會切換正常/遊戲模式，`,,,s` / `,,,l` 會調整候選窗寬度，`,,,+` / `,,,-` 會調整縮放並保存；menu bar 新增顯示/隱藏文字框與重新載入字典/pinyi；確認指令執行後會清空組字狀態。
- 修正：macOS 輸入法顯示名稱改為「肥米」，保留 executable、bundle id 與 input source id 的技術識別值，避免影響既有註冊流程；menu bar、關於視窗與安裝提示同步改用「肥米」。
