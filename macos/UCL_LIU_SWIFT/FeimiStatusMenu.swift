import AppKit

final class FeimiStatusMenu: NSObject {
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
        menu.addItem(NSMenuItem(title: "UCL_LIU_SWIFT 0.01", action: nil, keyEquivalent: ""))
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(
            title: "開啟使用者資料夾",
            action: #selector(openApplicationSupportDirectory),
            keyEquivalent: ""
        ))
        menu.addItem(NSMenuItem(
            title: "關於肥米",
            action: #selector(showAbout),
            keyEquivalent: ""
        ))
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(
            title: "離開肥米",
            action: #selector(terminate),
            keyEquivalent: "q"
        ))
        menu.items.forEach { $0.target = self }
        statusItem.menu = menu
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

    @objc private func showAbout() {
        let alert = NSAlert()
        alert.messageText = "肥米輸入法"
        alert.informativeText = "UCL_LIU_SWIFT 0.01"
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }

    @objc private func terminate() {
        NSApp.terminate(nil)
    }
}
