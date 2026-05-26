import Foundation

public struct CinParser: Sendable {
    public enum ParseError: Error, Equatable {
        case missingChardefBlock
    }

    public init() {}

    public func parse(_ source: String) throws -> [String: [String]] {
        var inChardef = false
        var sawChardef = false
        var result: [String: [String]] = [:]

        for rawLine in source.components(separatedBy: .newlines) {
            let line = rawLine.trimmingCharacters(in: .whitespacesAndNewlines)
            if line.isEmpty {
                continue
            }

            if line == "%chardef begin" {
                inChardef = true
                sawChardef = true
                continue
            }

            if line == "%chardef end" {
                inChardef = false
                break
            }

            guard inChardef else {
                continue
            }

            let parts = line.split { $0 == " " || $0 == "\t" }.map(String.init)
            guard parts.count >= 2 else {
                continue
            }

            result[parts[0].lowercased(), default: []].append(contentsOf: parts.dropFirst())
        }

        guard sawChardef else {
            throw ParseError.missingChardefBlock
        }

        return result
    }
}
