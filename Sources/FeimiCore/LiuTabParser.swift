import Foundation

public struct LiuTabParser: Sendable {
    public enum ParseError: Error, Equatable {
        case truncatedData
        case invalidKeyIndex(Int)
        case invalidWordIndex
        case invalidUnicodeScalar(UInt32)
    }

    private static let indexToKey = Array(" abcdefghijklmnopqrstuvwxyz,.'[]")

    public init() {}

    public func parse(_ data: Data) throws -> [String: [String]] {
        guard data.count >= 1024 * 2 else {
            throw ParseError.truncatedData
        }

        let keyTable = try readKeyTable(from: data)
        let wordCount = Int(keyTable[1023])
        let highBitsLength = Int(ceil(Double(wordCount * 2 + 7) / 8.0)) + 8
        let oneBitLength = Int(ceil(Double(wordCount) / 8.0))
        let highBitsOffset = 1024 * 2
        let wordsOffset = highBitsOffset + highBitsLength + oneBitLength + oneBitLength
        let wordsLength = wordCount * 3

        guard data.count >= wordsOffset + wordsLength else {
            throw ParseError.truncatedData
        }

        let words = try readWords(
            from: data,
            wordCount: wordCount,
            highBitsOffset: highBitsOffset,
            wordsOffset: wordsOffset
        )

        var result: [String: [String]] = [:]
        for tableIndex in 32..<(keyTable.count - 1) {
            let start = Int(keyTable[tableIndex])
            let end = Int(keyTable[tableIndex + 1])
            guard start <= end, end <= words.count else {
                throw ParseError.invalidWordIndex
            }

            let key1 = tableIndex / 32
            let key2 = tableIndex % 32
            for wordIndex in start..<end {
                let word = words[wordIndex]
                let code = try codeString(for: [key1, key2, word.key3, word.key4])
                guard !code.isEmpty else {
                    continue
                }
                result[code, default: []].append(word.text)
            }
        }

        return result
    }

    private func readKeyTable(from data: Data) throws -> [UInt16] {
        var result: [UInt16] = []
        result.reserveCapacity(1024)

        for index in 0..<1024 {
            let offset = index * 2
            let value = UInt16(data[offset]) | (UInt16(data[offset + 1]) << 8)
            result.append(value)
        }

        return result
    }

    private func readWords(
        from data: Data,
        wordCount: Int,
        highBitsOffset: Int,
        wordsOffset: Int
    ) throws -> [(key3: Int, key4: Int, text: String)] {
        var result: [(key3: Int, key4: Int, text: String)] = []
        result.reserveCapacity(wordCount)

        for wordIndex in 0..<wordCount {
            let offset = wordsOffset + wordIndex * 3
            let packed = (Int(data[offset]) << 16) | (Int(data[offset + 1]) << 8) | Int(data[offset + 2])
            let key3 = (packed >> 19) & 0x1f
            let key4 = (packed >> 14) & 0x1f
            let lowBits = UInt32(packed & 0x3fff)
            let highBits = UInt32(bit(in: data, offset: highBitsOffset, bitIndex: wordIndex * 2 + 16) ? 2 : 0)
                + UInt32(bit(in: data, offset: highBitsOffset, bitIndex: wordIndex * 2 + 17) ? 1 : 0)
            let scalarValue = (highBits << 14) | lowBits

            guard let scalar = UnicodeScalar(scalarValue) else {
                throw ParseError.invalidUnicodeScalar(scalarValue)
            }

            result.append((key3: key3, key4: key4, text: String(scalar)))
        }

        return result
    }

    private func bit(in data: Data, offset: Int, bitIndex: Int) -> Bool {
        let byte = data[offset + bitIndex / 8]
        let mask = UInt8(1 << (7 - bitIndex % 8))
        return (byte & mask) != 0
    }

    private func codeString(for keyIndexes: [Int]) throws -> String {
        var code = ""
        for keyIndex in keyIndexes where keyIndex != 0 {
            guard Self.indexToKey.indices.contains(keyIndex) else {
                throw ParseError.invalidKeyIndex(keyIndex)
            }
            code.append(Self.indexToKey[keyIndex])
        }
        return code
    }
}
