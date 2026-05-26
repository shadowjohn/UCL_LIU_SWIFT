import Foundation

public struct JsonDictionaryParser: Sendable {
    public enum ParseError: Error, Equatable {
        case invalidJSON
        case missingChardefs
        case invalidChardefs
    }

    public init() {}

    public func parse(_ source: String) throws -> [String: [String]] {
        guard let data = source.data(using: .utf8),
              let object = try? JSONSerialization.jsonObject(with: data),
              let root = object as? [String: Any] else {
            throw ParseError.invalidJSON
        }

        guard let chardefs = root["chardefs"] as? [String: Any] else {
            throw ParseError.missingChardefs
        }

        var result: [String: [String]] = [:]
        for (code, value) in chardefs {
            let normalizedCode = code.lowercased()
            if let words = value as? [String] {
                result[normalizedCode] = words
            } else if let word = value as? String {
                result[normalizedCode] = [word]
            } else {
                throw ParseError.invalidChardefs
            }
        }

        return result
    }
}
