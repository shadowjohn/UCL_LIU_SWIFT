import AppKit

final class FeimiDictionaryImportController {
    static let shared = FeimiDictionaryImportController()

    private let fileManager: FileManager
    private var hasPromptedForMissingDictionary = false

    private init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    func importDictionary() {
        let panel = NSOpenPanel()
        panel.title = "選取肥米字根檔"
        panel.message = "請選取合法來源的 liu-uni.tab、liu.cin 或 liu.json。"
        panel.prompt = "匯入"
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowsMultipleSelection = false
        panel.allowedFileTypes = ["json", "cin", "tab"]

        guard panel.runModal() == .OK,
              let sourceURL = panel.url else {
            return
        }

        importDictionary(from: sourceURL)
    }

    func importDictionary(from sourceURL: URL) {
        do {
            let plan = try copyDictionaryFile(from: sourceURL)
            let result = try FeimiDictionaryLoader().load(from: FeimiDataStore.applicationSupportDirectory)
            NSLog("UCL_LIU_SWIFT: imported dictionary file \(plan.destinationFileName), loaded \(result.source.rawValue)")
            NotificationCenter.default.post(name: .feimiReloadData, object: nil)
            showSuccessAlert(plan: plan, loadedSource: result.source)
        } catch let error as FeimiDictionaryImportPlan.ImportError {
            showErrorAlert(
                message: "無法匯入字根檔",
                detail: "只支援 liu-uni.tab、.cin 或 .json。\n\n\(error)"
            )
        } catch {
            NSLog("UCL_LIU_SWIFT: dictionary import failed: \(error)")
            showErrorAlert(message: "字根匯入失敗", detail: "\(error)")
        }
    }

    func promptForMissingDictionaryIfNeeded() {
        guard !hasPromptedForMissingDictionary,
              !FeimiDataStore.hasDictionarySource() else {
            return
        }

        hasPromptedForMissingDictionary = true

        let alert = NSAlert()
        alert.messageText = "肥米需要字根檔才能輸入中文。"
        alert.informativeText = "請選取合法來源的 liu-uni.tab、liu.cin 或 liu.json，或稍後放到使用者資料夾。"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "選取字根檔...")
        alert.addButton(withTitle: "開啟使用者資料夾")
        alert.addButton(withTitle: "稍後")

        switch alert.runModal() {
        case .alertFirstButtonReturn:
            importDictionary()
        case .alertSecondButtonReturn:
            openApplicationSupportDirectory()
        default:
            break
        }
    }

    func openApplicationSupportDirectory() {
        do {
            try fileManager.createDirectory(
                at: FeimiDataStore.applicationSupportDirectory,
                withIntermediateDirectories: true
            )
            NSWorkspace.shared.open(FeimiDataStore.applicationSupportDirectory)
        } catch {
            NSSound.beep()
            NSLog("UCL_LIU_SWIFT: cannot open application support directory: \(error)")
        }
    }

    private func copyDictionaryFile(from sourceURL: URL) throws -> FeimiDictionaryImportPlan {
        let plan = try FeimiDictionaryImportPlan(sourceURL: sourceURL)
        try validateSelectedDictionary(plan)

        let directory = FeimiDataStore.applicationSupportDirectory
        let destinationURL = plan.destinationURL(in: directory)

        try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        try backUpExistingFiles(for: plan, excluding: sourceURL, in: directory)

        if !isSameFile(sourceURL, destinationURL) {
            try fileManager.copyItem(at: sourceURL, to: destinationURL)
        }

        return plan
    }

    private func validateSelectedDictionary(_ plan: FeimiDictionaryImportPlan) throws {
        let temporaryDirectory = fileManager.temporaryDirectory
            .appendingPathComponent("UCL_LIU_SWIFT-DictionaryImport-\(UUID().uuidString)", isDirectory: true)

        try fileManager.createDirectory(at: temporaryDirectory, withIntermediateDirectories: true)
        defer {
            try? fileManager.removeItem(at: temporaryDirectory)
        }

        try fileManager.copyItem(at: plan.sourceURL, to: plan.destinationURL(in: temporaryDirectory))
        _ = try FeimiDictionaryLoader().load(from: temporaryDirectory)
    }

    private func backUpExistingFiles(
        for plan: FeimiDictionaryImportPlan,
        excluding sourceURL: URL,
        in directory: URL
    ) throws {
        let existingURLs = plan.fileURLsToBackUpBeforeCopy(in: directory).filter { url in
            fileManager.fileExists(atPath: url.path) && !isSameFile(url, sourceURL)
        }

        guard !existingURLs.isEmpty else {
            return
        }

        let backupDirectory = directory
            .appendingPathComponent("Dictionary Backups", isDirectory: true)
            .appendingPathComponent(timestamp(), isDirectory: true)

        try fileManager.createDirectory(at: backupDirectory, withIntermediateDirectories: true)

        for url in existingURLs {
            let backupURL = backupDirectory.appendingPathComponent(url.lastPathComponent)
            try fileManager.moveItem(at: url, to: backupURL)
        }
    }

    private func isSameFile(_ lhs: URL, _ rhs: URL) -> Bool {
        lhs.standardizedFileURL.path == rhs.standardizedFileURL.path
    }

    private func timestamp() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyyMMdd-HHmmss-SSS"
        return formatter.string(from: Date())
    }

    private func showSuccessAlert(plan: FeimiDictionaryImportPlan, loadedSource: FeimiDictionarySource) {
        let alert = NSAlert()
        alert.messageText = "字根匯入完成"
        alert.informativeText = "\(plan.destinationFileName) 已匯入，肥米已重新載入 \(loadedSource.rawValue) 字根。"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }

    private func showErrorAlert(message: String, detail: String) {
        let alert = NSAlert()
        alert.messageText = message
        alert.informativeText = detail
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}
