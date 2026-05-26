import Foundation

enum LiuTabTestSupport {
    static func makeTab(entries: [(String, Character)]) -> Data {
        let sorted = entries.sorted { lhs, rhs in
            LiuTabKey.index(for: lhs.0) < LiuTabKey.index(for: rhs.0)
        }
        let buckets = Dictionary(grouping: sorted, by: { LiuTabKey.index(for: $0.0) })
        var keyTable = Array(repeating: UInt16(0), count: 1024)
        var words: [(key3: Int, key4: Int, scalar: UInt32)] = []

        for tableIndex in 0..<1023 {
            keyTable[tableIndex] = UInt16(words.count)
            for entry in buckets[tableIndex] ?? [] {
                let code = entry.0
                let key3 = LiuTabKey.keyIndex(at: 2, in: code)
                let key4 = LiuTabKey.keyIndex(at: 3, in: code)
                let scalar = entry.1.unicodeScalars.first!.value
                words.append((key3, key4, scalar))
            }
        }
        keyTable[1023] = UInt16(words.count)

        var data = Data()
        for value in keyTable {
            data.append(UInt8(value & 0xff))
            data.append(UInt8(value >> 8))
        }

        var highBits = Array(repeating: UInt8(0), count: 8 + max(1, Int(ceil(Double(words.count * 2 + 7) / 8.0))))
        for (index, word) in words.enumerated() {
            let high = UInt8((word.scalar >> 14) & 0x03)
            setBit(&highBits, at: index * 2 + 16, to: (high & 0x02) != 0)
            setBit(&highBits, at: index * 2 + 17, to: (high & 0x01) != 0)
        }
        data.append(contentsOf: highBits)
        data.append(contentsOf: Array(repeating: UInt8(0), count: max(1, Int(ceil(Double(words.count) / 8.0)))))
        data.append(contentsOf: Array(repeating: UInt8(0), count: max(1, Int(ceil(Double(words.count) / 8.0)))))

        for word in words {
            let low = Int(word.scalar & 0x3fff)
            let packed = (word.key3 << 19) | (word.key4 << 14) | low
            data.append(UInt8((packed >> 16) & 0xff))
            data.append(UInt8((packed >> 8) & 0xff))
            data.append(UInt8(packed & 0xff))
        }

        return data
    }

    private static func setBit(_ bytes: inout [UInt8], at bitIndex: Int, to value: Bool) {
        guard value else {
            return
        }

        let byteIndex = bitIndex / 8
        let shift = 7 - (bitIndex % 8)
        bytes[byteIndex] |= UInt8(1 << shift)
    }
}

private enum LiuTabKey {
    private static let keys = Array(" abcdefghijklmnopqrstuvwxyz,.'[]")

    static func keyIndex(at position: Int, in code: String) -> Int {
        let characters = Array(code)
        guard characters.indices.contains(position) else {
            return 0
        }

        return keys.firstIndex(of: characters[position])!
    }

    static func index(for code: String) -> Int {
        keyIndex(at: 0, in: code) * 32 + keyIndex(at: 1, in: code)
    }
}
