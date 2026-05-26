# UCL_LIU_SWIFT 開發計畫

目標：製作 macOS 原生版「肥米輸入法」，延續 UCL_LIU / UCL_LIU_CSharp 的使用習慣、復古 UI、字根轉換流程，並參考 ilimi-inputmethod 的 Swift / macOS IME 實作方式。

## 參考專案

- UCL_LIU：Python + pyhook 版肥米輸入法
- UCL_LIU_CSharp：C# 版肥米輸入法
- ilimi-inputmethod：Swift macOS 蝦米輸入法範例

## 核心方向

本專案不採用 Rime。

原因：

- UI 要保持肥米風格
- 操作習慣要與原本 UCL_LIU 一致
- 字根、同音、注音、簡繁切換要自己控制
- 未來可發展成跨平台肥米核心

## Feimi Core 是什麼

Feimi Core 指的是「肥米輸入法核心引擎」。

它不是框架，也不是 Rime。

它負責：

- 讀取 `liu.json`
- 由輸入碼查候選字
- 處理 `pinyi.txt`
- 注音模式
- 同音字模式
- 簡繁切換
- 快打 / 一碼 / 選字規則
- 使用者設定
- 候選排序
- 之後可加入使用者詞頻學習

簡單說：

```text
macOS IME / UI 只是外殼
Feimi Core 才是肥米的大腦
技術選型
macOS 原生輸入法

使用：

Swift
AppKit
InputMethodKit

主要類別：

IMKServer
IMKInputController
IMKCandidates
UI

使用 AppKit 優先。

原因：

輸入法候選視窗比較偏傳統 macOS 元件
SwiftUI 對 IME / 浮動視窗控制不一定穩
復古 UI 用 AppKit 比較好控制
核心引擎

第一版先用 Swift 寫 Feimi Core。

未來如果要跨平台，再抽成：

feimi-core-cpp
feimi-core-swift binding
feimi-core-csharp binding
專案結構建議
UCL_LIU_SWIFT/
├─ README.md
├─ docs/
│  ├─ dev_plan.md
│  ├─ file_format.md
│  ├─ ime_behavior.md
│  └─ ui_style.md
├─ UCLLIUInputMethod/
│  ├─ AppDelegate.swift
│  ├─ InputController.swift
│  ├─ CandidateWindow.swift
│  ├─ StatusMenu.swift
│  └─ Info.plist
├─ FeimiCore/
│  ├─ FeimiEngine.swift
│  ├─ FeimiDictionary.swift
│  ├─ CinParser.swift
│  ├─ TabParser.swift
│  ├─ JsonDictionary.swift
│  ├─ PinyiParser.swift
│  ├─ ZhuyinEngine.swift
│  ├─ CommandProcessor.swift
│  └─ FeimiConfig.swift
├─ Tools/
│  ├─ liu_tab_to_cin.swift
│  ├─ liu_cin_to_json.swift
│  └─ pinyi_to_json.swift
├─ Resources/
│  ├─ liu.json
│  ├─ pinyi.txt
│  └─ DefaultTheme.json
└─ Tests/
   ├─ FeimiCoreTests/
   └─ ParserTests/
字根檔支援

第一版需支援三種輸入檔：

liu-uni.tab
liu.cin
liu.json

啟動順序：

1. 如果有 liu.json，直接讀 liu.json
2. 如果沒有 liu.json，但有 liu.cin，轉成 liu.json
3. 如果沒有 liu.cin，但有 liu-uni.tab，先轉 liu.cin，再轉 liu.json
4. 如果三者都沒有，顯示錯誤提示
pinyi.txt 支援

保留舊版行為：

pinyi.txt 與 app / 使用者資料目錄放一起
啟動時自動讀取

用途：

'xxx    同音字查詢
';      切換注音模式

範例：

'pns
→ 你 妳 擬 禰 儗 旎 ...

注音模式：

ㄈㄟ/
→ 肥 淝 腓 萉 蜰 ...
設定檔位置

macOS 建議使用：

~/Library/Application Support/UCL_LIU_SWIFT/

內容：

liu.json
liu.cin
liu-uni.tab
pinyi.txt
config.json
user_phrase.json
theme.json
log/

選單提供：

開啟肥米設定資料夾
重新載入字根
重新載入 pinyi.txt

這點可參考 ilimi-inputmethod 的使用者字檔匯入流程。

指令保留

需延續原本 UCL_LIU 操作。

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

第一版 MVP 可先做：

,,,unlock
,,,lock
,,,version
,,,c
,,,t
,,,s
,,,l
,,,+ 
,,,-

,,,z / ,,,x 牽涉剪貼簿與反查，可放第二階段。

輸入行為 MVP

基本行為：

輸入 a-z
累積 composing buffer
查 liu.json
顯示候選字
空白輸出第一候選
數字鍵選候選
Enter 輸出原始字根
Esc 清空
Backspace 刪除上一碼

候選顯示：

0肥 1飛 2非 3啡 ...

或：

1肥 2飛 3非 4啡 ...

需確認是否完全沿用舊版數字選字規則。

UI 風格

目標：復古肥米風格。

視覺方向：

小型浮動候選窗
黑底或深藍底
亮綠 / 黃色文字
像早期 Windows 小工具
不要 macOS 原生白色候選窗
不要太現代

候選窗內容：

目前輸入碼：abc
候選字：0肥 1飛 2非 3啡
模式：繁 / 簡 / 鎖定 / 注音

UI 尺寸需支援：

,,,s 變窄
,,,l 變寬
,,,+ 變大
,,,- 變小

設定保存到：

config.json
Native IME 實作重點

建立 macOS Input Method app。

Info.plist 需設定：

InputMethodServerControllerClass
tsInputMethodIconFileKey
tsInputMethodCharacterRepertoireKey

InputController 需處理：

handle(event:client:)
commitComposition(_:)
recognizedEvents(_:)

核心流程：

keyDown
↓
判斷是否為 command
↓
更新 composing buffer
↓
查 FeimiEngine
↓
更新 CandidateWindow
↓
使用者選字
↓
commit text 到目前 app
參考 ilimi-inputmethod 的項目

從 ilimi-inputmethod 參考：

Swift InputMethodKit 專案結構
build.sh
installer 打包方式
系統設定加入輸入法流程
使用者設定資料夾
字檔匯入流程
候選窗處理方式

注意 ilimi 曾有「輸入法在 Safari 等 app 使用一段時間後突然無法載入」類問題，所以本專案要特別加：

log
crash 防護
重新載入 server
候選窗狀態 reset
不同 app 切換時清 composing buffer
第一階段：可打字 MVP

目標：

可以在 macOS 任意文字框輸入肥米

功能：

建立 Swift InputMethodKit 專案
安裝後可在系統輸入法中選擇
能攔截鍵盤事件
能顯示復古候選窗
能讀取 liu.json
能輸入字根並送出候選字
支援空白 / 數字 / Enter / Esc / Backspace

驗收：

在 TextEdit 可輸入中文
在 Safari 網址列不 crash
在 VS Code 可輸入
切換 app 後 composing buffer 不亂掉
第二階段：字根轉換

目標：

保留 liu-uni.tab -> liu.cin -> liu.json 流程

功能：

TabParser
CinParser
JsonDictionary
啟動時自動轉換
轉換進度提示
轉換錯誤 log
轉換完成後快取 liu.json

驗收：

只放 liu-uni.tab 可以啟動
只放 liu.cin 可以啟動
只放 liu.json 可以啟動
轉出 json 後下次啟動變快
第三階段：pinyi / 注音 / 同音

功能：

讀取 pinyi.txt
'xxx 同音查詢
'; 切換注音模式
注音輸入查候選字
簡繁模式下候選同步調整

驗收：

'pns 可顯示同音候選
'; 後可用注音查字
,,,t / ,,,c 可切換繁簡
第四階段：完整肥米指令

功能：

lock / unlock
version
UI size
UI width
簡繁切換
設定保存
選單列 icon
開啟設定資料夾
第五階段：反查與剪貼簿

功能：

,,,z 框選文章轉字根
,,,x 框選字根轉文章

可能做法：

讀取剪貼簿
呼叫 FeimiEngine reverseLookup
轉換後寫回剪貼簿
模擬貼上

這階段要特別注意 macOS 權限：

Accessibility Permission
Input Monitoring Permission
Clipboard Permission
第六階段：Installer / Release

功能：

build.sh
pkg installer
GitHub Actions build
dmg / pkg release
README 安裝教學
移除教學

安裝流程：

下載 pkg
安裝
系統設定 > 鍵盤 > 輸入方式 > 加入 UCL_LIU_SWIFT
開啟使用者設定資料夾
放入 liu.json / liu.cin / liu-uni.tab / pinyi.txt
重新載入字根
測試項目
Parser Tests
liu-uni.tab -> liu.cin
liu.cin -> liu.json
pinyi.txt parse
重複碼處理
空白行處理
註解處理
Unicode 字元處理
Engine Tests
輸入碼查候選
候選排序
簡繁切換
同音查詢
注音查詢
lock mode
unlock mode
IME Tests
TextEdit
Safari
Chrome
VS Code
Terminal
LINE / Discord
中文輸入框
密碼欄位
切換 app
切換輸入法
睡眠喚醒
開發注意事項
不要一開始追求 AI

第一版不要做：

AI 聯想
自動補句
雲端詞庫
同步
大模型

先把肥米手感做出來。

不要先做太漂亮

第一版 UI 只要：

穩
快
復古
可調大小
不卡輸入
字典要快

liu.json 載入後應轉為 memory dictionary：

[String: [Candidate]]

不要每打一碼就讀檔。

log 必須保留

建議 log：

~/Library/Application Support/UCL_LIU_SWIFT/log/uclliu_yyyyMMdd.log

內容：

啟動
載入字典
轉換字典
IME event error
candidate window error
command error
README 第一版內容

README 應包含：

UCL_LIU_SWIFT 是什麼
和 UCL_LIU / UCL_LIU_CSharp 的關係
安裝方式
字根檔放哪裡
支援 liu-uni.tab / liu.cin / liu.json
支援 pinyi.txt
常用指令
已知限制
開發狀態
建議 Codex 任務切法
Task 1

建立 Swift InputMethodKit 最小專案，可安裝並出現在 macOS 輸入法清單。

Task 2

建立 FeimiCore，支援讀取 liu.json 並查候選。

Task 3

串接 InputController，輸入 a-z 顯示候選窗並可 commit。

Task 4

加入復古 CandidateWindow。

Task 5

加入 liu.cin / liu-uni.tab 轉換。

Task 6

加入 pinyi.txt。

Task 7

加入肥米指令。

Task 8

加入 installer / build.sh / README。

最終目標

UCL_LIU_SWIFT 要成為：

macOS 原生肥米輸入法
不是 Rime schema
不是套殼
而是肥米自己的 UI、自己的引擎、自己的手感

`Feimi Core` 簡單講就是「把肥米邏輯從 UI 拆出來」：以後 macOS、Windows、iOS、Android 都可以共用同一套查碼、候選、pinyi、簡繁、反查邏輯。