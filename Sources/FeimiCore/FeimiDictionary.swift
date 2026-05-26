public struct FeimiDictionary: Sendable {
    private let chardefs: [String: [String]]

    public init(chardefs: [String: [String]]) {
        var normalized: [String: [String]] = [:]
        for (code, words) in chardefs {
            normalized[code.lowercased()] = words
        }
        self.chardefs = normalized
    }

    public func lookup(_ code: String) -> [Candidate] {
        let normalizedCode = code.lowercased()
        return (chardefs[normalizedCode] ?? []).enumerated().map { index, text in
            Candidate(text: text, code: normalizedCode, index: index)
        }
    }
}
