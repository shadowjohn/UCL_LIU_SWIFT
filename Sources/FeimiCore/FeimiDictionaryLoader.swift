import Foundation

public enum FeimiDictionarySource: String, Equatable, Sendable {
    case json
    case cin
    case tab
}

public struct FeimiDictionaryLoadResult: Sendable {
    public let source: FeimiDictionarySource
    public let chardefs: [String: [String]]
    public let dictionary: FeimiDictionary

    public init(source: FeimiDictionarySource, chardefs: [String: [String]]) {
        self.source = source
        self.chardefs = chardefs
        self.dictionary = FeimiDictionary(chardefs: chardefs)
    }
}

public struct FeimiDictionaryLoader {
    public enum LoadError: Error, Equatable {
        case missingDictionaryFiles
    }

    private let fileManager: FileManager

    public init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    public func load(from directory: URL) throws -> FeimiDictionaryLoadResult {
        let jsonURL = directory.appendingPathComponent("liu.json")
        let cinURL = directory.appendingPathComponent("liu.cin")
        let tabURL = directory.appendingPathComponent("liu-uni.tab")

        if fileManager.fileExists(atPath: jsonURL.path) {
            let source = try String(contentsOf: jsonURL, encoding: .utf8)
            return FeimiDictionaryLoadResult(
                source: .json,
                chardefs: try JsonDictionaryParser().parse(source)
            )
        }

        if fileManager.fileExists(atPath: cinURL.path) {
            let source = try String(contentsOf: cinURL, encoding: .utf8)
            let chardefs = try CinParser().parse(source)
            try writeJsonCache(chardefs, to: jsonURL)
            return FeimiDictionaryLoadResult(source: .cin, chardefs: chardefs)
        }

        if fileManager.fileExists(atPath: tabURL.path) {
            let data = try Data(contentsOf: tabURL)
            let chardefs = try LiuTabParser().parse(data)
            try writeCinCache(chardefs, to: cinURL)
            try writeJsonCache(chardefs, to: jsonURL)
            return FeimiDictionaryLoadResult(source: .tab, chardefs: chardefs)
        }

        throw LoadError.missingDictionaryFiles
    }

    private func writeJsonCache(_ chardefs: [String: [String]], to url: URL) throws {
        let object: [String: Any] = ["chardefs": chardefs]
        let data = try JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted, .sortedKeys])
        try data.write(to: url, options: .atomic)
    }

    private func writeCinCache(_ chardefs: [String: [String]], to url: URL) throws {
        var lines = [
            "%gen_inp",
            "%ename liu",
            "%cname 嘸蝦米",
            "%encoding UTF-8",
            "%selkey 0123456789",
            "%chardef begin"
        ]

        for code in chardefs.keys.sorted() {
            for word in chardefs[code] ?? [] {
                lines.append("\(code) \(word)")
            }
        }

        lines.append("%chardef end")
        try lines.joined(separator: "\n").write(to: url, atomically: true, encoding: .utf8)
    }
}
