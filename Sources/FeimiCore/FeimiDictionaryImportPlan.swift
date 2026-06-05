import Foundation

public struct FeimiDictionaryImportPlan: Equatable {
    public enum ImportKind: Equatable, Sendable {
        case json
        case cin
        case tab
    }

    public enum ImportError: Error, Equatable, Sendable {
        case unsupportedFile(String)
    }

    public let kind: ImportKind
    public let sourceURL: URL
    public let destinationFileName: String
    public let fileNamesToBackUpBeforeCopy: [String]

    public init(sourceURL: URL) throws {
        let fileName = sourceURL.lastPathComponent
        let lowercasedFileName = fileName.lowercased()
        let lowercasedExtension = sourceURL.pathExtension.lowercased()

        self.sourceURL = sourceURL

        if lowercasedFileName == "liu-uni.tab" {
            self.kind = .tab
            self.destinationFileName = "liu-uni.tab"
            self.fileNamesToBackUpBeforeCopy = ["liu-uni.tab", "liu.cin", "liu.json"]
        } else if lowercasedExtension == "cin" {
            self.kind = .cin
            self.destinationFileName = "liu.cin"
            self.fileNamesToBackUpBeforeCopy = ["liu.cin", "liu.json"]
        } else if lowercasedExtension == "json" {
            self.kind = .json
            self.destinationFileName = "liu.json"
            self.fileNamesToBackUpBeforeCopy = ["liu.json"]
        } else {
            throw ImportError.unsupportedFile(fileName)
        }
    }

    public func destinationURL(in directory: URL) -> URL {
        directory.appendingPathComponent(destinationFileName)
    }

    public func fileURLsToBackUpBeforeCopy(in directory: URL) -> [URL] {
        fileNamesToBackUpBeforeCopy.map { directory.appendingPathComponent($0) }
    }
}
