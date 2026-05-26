public struct FeimiDictionary: Sendable {
    private let chardefs: [String: [String]]
    private let reverse: [String: String]
    private let auxiliaryIndex: [Character: Int] = [
        "v": 1,
        "r": 2,
        "s": 3,
        "f": 4
    ]

    public init(chardefs: [String: [String]]) {
        var normalized: [String: [String]] = [:]
        var reverseBuilder: [String: String] = [:]

        for (code, words) in chardefs {
            let normalizedCode = code.lowercased()
            normalized[normalizedCode] = words
            for (index, word) in words.enumerated() {
                let reverseCode = index == 0 ? normalizedCode : "\(normalizedCode)\(index)"
                if let existing = reverseBuilder[word] {
                    if reverseCode.count < existing.count {
                        reverseBuilder[word] = reverseCode
                    }
                } else {
                    reverseBuilder[word] = reverseCode
                }
            }
        }

        self.chardefs = normalized
        self.reverse = reverseBuilder
    }

    public func lookup(_ code: String) -> [Candidate] {
        let normalizedCode = code.lowercased()
        if let words = chardefs[normalizedCode] {
            return candidates(words: words, code: normalizedCode)
        }

        guard let last = normalizedCode.last,
              let index = auxiliaryIndex[last] else {
            return []
        }

        let baseCode = String(normalizedCode.dropLast())
        guard let words = chardefs[baseCode], index < words.count else {
            return []
        }

        return [Candidate(text: words[index], code: normalizedCode, index: 0)]
    }

    public func reverseLookup(character: Character) -> String? {
        reverse[String(character)]
    }

    public func reverseLookup(text: String) -> String {
        text.compactMap { reverseLookup(character: $0) }.joined(separator: " ")
    }

    private func candidates(words: [String], code: String) -> [Candidate] {
        words.enumerated().map { index, text in
            Candidate(text: text, code: code, index: index)
        }
    }
}
