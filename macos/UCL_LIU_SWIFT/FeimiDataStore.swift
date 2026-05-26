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

        do {
            let result = try FeimiDictionaryLoader().load(from: applicationSupportDirectory)
            NSLog("UCL_LIU_SWIFT: loaded dictionary from \(result.source.rawValue) with \(result.chardefs.count) codes")
            return result.dictionary
        } catch {
            NSLog("UCL_LIU_SWIFT: cannot load liu.json, liu.cin or liu-uni.tab: \(error)")
            return FeimiDictionary(chardefs: [:])
        }
    }
}
