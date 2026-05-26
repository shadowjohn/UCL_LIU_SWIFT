import Foundation

enum FeimiDataStore {
    static let applicationSupportDirectory: URL = {
        FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library", isDirectory: true)
            .appendingPathComponent("Application Support", isDirectory: true)
            .appendingPathComponent("UCL_LIU_SWIFT", isDirectory: true)
    }()

    static func loadDictionary() -> FeimiDictionary {
        do {
            try FileManager.default.createDirectory(
                at: applicationSupportDirectory,
                withIntermediateDirectories: true
            )
        } catch {
            NSLog("UCL_LIU_SWIFT: cannot create application support directory: \(error)")
        }

        let cinURL = applicationSupportDirectory.appendingPathComponent("liu.cin")
        guard let source = try? String(contentsOf: cinURL, encoding: .utf8) else {
            NSLog("UCL_LIU_SWIFT: no liu.cin found at \(cinURL.path)")
            return FeimiDictionary(chardefs: [:])
        }

        do {
            let chardefs = try CinParser().parse(source)
            NSLog("UCL_LIU_SWIFT: loaded liu.cin with \(chardefs.count) codes")
            return FeimiDictionary(chardefs: chardefs)
        } catch {
            NSLog("UCL_LIU_SWIFT: cannot parse liu.cin: \(error)")
            return FeimiDictionary(chardefs: [:])
        }
    }
}
