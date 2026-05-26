public struct PinyiEngine: Sendable {
    public enum ParseError: Error, Equatable {
        case unsupportedVersion
        case missingHeader
    }

    private let keyToSymbol: [Character: Character]
    private let symbolToKey: [Character: Character]
    private let pronunciationToCandidates: [String: [String]]
    private let sameSoundRows: [[String]]

    public init(source: String) throws {
        let lines = source
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        guard lines.count >= 3 else {
            throw ParseError.missingHeader
        }

        guard lines[0] == "VERSION_0.01" else {
            throw ParseError.unsupportedVersion
        }

        let keys = lines[1].split(separator: " ").map(String.init)
        let symbols = lines[2].split(separator: " ").map(String.init)
        guard keys.count == symbols.count else {
            throw ParseError.missingHeader
        }

        var keyToSymbol: [Character: Character] = [:]
        var symbolToKey: [Character: Character] = [:]
        for index in keys.indices {
            guard let key = keys[index].first,
                  let symbol = symbols[index].first else {
                continue
            }
            keyToSymbol[key] = symbol
            symbolToKey[symbol] = key
        }

        var pronunciationToCandidates: [String: [String]] = [:]
        var rows: [[String]] = []
        for line in lines.dropFirst(3) {
            let parts = line.split(separator: " ").map(String.init)
            guard parts.count >= 2 else {
                continue
            }

            pronunciationToCandidates[parts[0]] = Array(parts.dropFirst())
            rows.append(parts)
        }

        self.keyToSymbol = keyToSymbol
        self.symbolToKey = symbolToKey
        self.pronunciationToCandidates = pronunciationToCandidates
        self.sameSoundRows = rows
    }

    public func zhuyinSymbols(for key: String) -> String {
        String(key.compactMap { keyToSymbol[$0] })
    }

    public func zhuyinKey(for symbols: String) -> String {
        String(symbols.compactMap { symbolToKey[$0] })
    }

    public func zhuyinCandidates(for key: String) -> [String] {
        pronunciationToCandidates[key] ?? []
    }

    public func sameSoundCandidates(containing text: String) -> [String] {
        var result: [String] = []
        var seen: Set<String> = []

        for row in sameSoundRows where row.dropFirst().contains(text) {
            for candidate in row.dropFirst() where !seen.contains(candidate) {
                seen.insert(candidate)
                result.append(candidate)
            }
        }

        return result
    }
}
