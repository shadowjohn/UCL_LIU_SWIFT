import AppKit

final class FeimiStatusMenu: NSObject, NSMenuDelegate {
    static let shared = FeimiStatusMenu()

    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

    private override init() {
        super.init()
        configureStatusItem()
    }

    private func configureStatusItem() {
        if let button = statusItem.button {
            button.title = "肥"
            button.font = NSFont.boldSystemFont(ofSize: 15)
            button.toolTip = "肥米輸入法"
        }

        let menu = NSMenu()
        menu.delegate = self
        rebuildMenu(menu)
        statusItem.menu = menu
    }

    func menuNeedsUpdate(_ menu: NSMenu) {
        rebuildMenu(menu)
    }

    private func rebuildMenu(_ menu: NSMenu) {
        menu.removeAllItems()
        menu.addItem(makeItem(title: "肥米 0.01", action: nil))
        menu.addItem(.separator())
        menu.addItem(makeItem(title: "1.關於肥米輸入法", action: #selector(showAbout)))
        menu.addItem(makeItem(
            title: FeimiRuntimeState.shared.isGameMode ? "2.切換至「正常模式」" : "2.切換至「遊戲模式」",
            action: #selector(toggleGameMode)
        ))
        menu.addItem(outputModeMenuItem())
        menu.addItem(uiAdjustmentMenuItem())
        menu.addItem(makeItem(
            title: "5.【●】Ctrl+Space 英/肥切換（目前：\(FeimiRuntimeState.shared.isFeimiMode ? "肥" : "英")）",
            action: #selector(toggleFeimiMode)
        ))
        menu.addItem(disabledItem(title: "6.【　】顯示短根（未接上）"))
        menu.addItem(.separator())
        menu.addItem(makeItem(title: "7.重新載入字典", action: #selector(reloadData)))
        menu.addItem(makeItem(title: "8.開啟使用者資料夾", action: #selector(openApplicationSupportDirectory)))
        menu.addItem(.separator())
        menu.addItem(makeItem(title: "11. 離開(Quit)", action: #selector(terminate), keyEquivalent: "q"))
    }

    private func outputModeMenuItem() -> NSMenuItem {
        let item = makeItem(title: "3.選擇出字模式", action: nil)
        let submenu = NSMenu()
        submenu.addItem(disabledItem(title: "【●】macOS 原生出字模式"))
        submenu.addItem(disabledItem(title: "【　】BIG5模式（未接上）"))
        submenu.addItem(disabledItem(title: "【　】複製貼上模式（未接上）"))
        item.submenu = submenu
        return item
    }

    private func uiAdjustmentMenuItem() -> NSMenuItem {
        let item = makeItem(title: "4.畫面調整", action: nil)
        let submenu = NSMenu()
        let shortMark = FeimiLegacyPanel.shared.isNarrowLayoutEnabled() ? "●" : "　"
        submenu.addItem(makeItem(
            title: "【\(shortMark)】短版模式",
            action: #selector(toggleShortLayout)
        ))
        submenu.addItem(makeItem(title: "【,,,+】畫面加大", action: #selector(increasePanelScale)))
        submenu.addItem(makeItem(title: "【,,,-】畫面縮小", action: #selector(decreasePanelScale)))
        submenu.addItem(.separator())
        submenu.addItem(makeItem(title: "顯示文字框", action: #selector(showLegacyPanel)))
        submenu.addItem(makeItem(title: "隱藏文字框", action: #selector(hideLegacyPanel)))
        item.submenu = submenu
        return item
    }

    private func makeItem(
        title: String,
        action: Selector?,
        keyEquivalent: String = ""
    ) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: action, keyEquivalent: keyEquivalent)
        if action != nil {
            item.target = self
        }
        return item
    }

    private func disabledItem(title: String) -> NSMenuItem {
        let item = makeItem(title: title, action: nil)
        item.isEnabled = false
        return item
    }

    @objc private func showLegacyPanel() {
        let state = FeimiPanelState(
            inputModeLabel: FeimiRuntimeState.shared.isFeimiMode ? "肥" : "英",
            widthModeLabel: "半",
            compositionLabel: "",
            candidateLabel: "",
            commandModeLabel: FeimiRuntimeState.shared.isGameMode ? "遊戲模式" : "正常模式",
            shouldShowPanel: true
        )
        FeimiLegacyPanel.shared.update(with: state, anchor: nil, revealsUserHiddenPanel: true)
    }

    @objc private func hideLegacyPanel() {
        FeimiLegacyPanel.shared.hideByUser()
    }

    @objc private func toggleGameMode() {
        FeimiRuntimeState.shared.toggleGameMode()
        showLegacyPanel()
    }

    @objc private func toggleFeimiMode() {
        FeimiRuntimeState.shared.toggleFeimiMode()
        showLegacyPanel()
    }

    @objc private func toggleShortLayout() {
        if FeimiLegacyPanel.shared.isNarrowLayoutEnabled() {
            FeimiLegacyPanel.shared.setWideLayout()
        } else {
            FeimiLegacyPanel.shared.setNarrowLayout()
        }
        showLegacyPanel()
    }

    @objc private func increasePanelScale() {
        FeimiLegacyPanel.shared.increaseScale()
        showLegacyPanel()
    }

    @objc private func decreasePanelScale() {
        FeimiLegacyPanel.shared.decreaseScale()
        showLegacyPanel()
    }

    @objc private func openApplicationSupportDirectory() {
        do {
            try FileManager.default.createDirectory(
                at: FeimiDataStore.applicationSupportDirectory,
                withIntermediateDirectories: true
            )
            NSWorkspace.shared.open(FeimiDataStore.applicationSupportDirectory)
        } catch {
            NSSound.beep()
            NSLog("UCL_LIU_SWIFT: cannot open application support directory: \(error)")
        }
    }

    @objc private func reloadData() {
        NotificationCenter.default.post(name: .feimiReloadData, object: nil)
    }

    @objc private func showAbout() {
        let alert = NSAlert()
        alert.messageText = "肥米輸入法"
        alert.informativeText = """
        Swift / macOS 版
        作者：羽山秋人 (http://3wa.tw)
        版本：0.01

        熱鍵提示：
        「Ctrl+Space」英 / 肥切換
        「,,,VERSION」目前版本
        「,,,UNLOCK」回到正常模式
        「,,,LOCK」進入遊戲模式
        「,,,S」UI變窄
        「,,,L」UI變寬
        「,,,+」UI變大
        「,,,-」UI變小
        「,,,X」框字的字根轉回文字（實作中）
        「,,,Z」框字的文字變成字根（實作中）
        """
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }

    @objc private func terminate() {
        NSApp.terminate(nil)
    }
}
