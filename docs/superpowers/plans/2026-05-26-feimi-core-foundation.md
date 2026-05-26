# Feimi Core Foundation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the first testable Swift Feimi Core slice: dictionary lookup, CIN parsing, pinyi parsing, command parsing, and reverse lookup.

**Architecture:** Start with a Swift Package so the core can be tested without InputMethodKit. The package exposes small value types and focused services that the future macOS IME app can call. InputMethodKit, AppKit candidate windows, installer work, and permission UI remain outside this first foundation slice.

**Tech Stack:** Swift Package Manager, XCTest, Swift Foundation.

---

## Execution Notes

This repository is currently on Windows and does not have `swift` or `xcodebuild` installed. Execute the test commands on a macOS machine with Xcode or a Swift toolchain, or install a Swift toolchain before running this plan locally. Do not write production Swift code until the matching test has been written and observed failing in that Swift environment.

Implementation branch:

```powershell
git switch codex/feimi-core-foundation
```

Expected ignored local reference files:

```text
liu-uni.tab
wavs/
.superpowers/
```

## File Structure

Create:

- `Package.swift`: Swift Package manifest for `FeimiCore`.
- `Sources/FeimiCore/Candidate.swift`: candidate value type.
- `Sources/FeimiCore/FeimiDictionary.swift`: in-memory code lookup and reverse lookup.
- `Sources/FeimiCore/CinParser.swift`: parser for `%chardef` CIN data.
- `Sources/FeimiCore/PinyiEngine.swift`: parser and lookup engine for `pinyi.txt`.
- `Sources/FeimiCore/CommandProcessor.swift`: parser for `,,,` commands.
- `Sources/FeimiCore/FeimiEngine.swift`: small state machine for composing-buffer input.
- `Tests/FeimiCoreTests/FeimiDictionaryTests.swift`
- `Tests/FeimiCoreTests/CinParserTests.swift`
- `Tests/FeimiCoreTests/PinyiEngineTests.swift`
- `Tests/FeimiCoreTests/CommandProcessorTests.swift`
- `Tests/FeimiCoreTests/FeimiEngineTests.swift`

Modify:

- `history.md`: record each implementation milestone and any environment limitation.

## Task 1: Package Skeleton

**Files:**
- Create: `Package.swift`
- Create: `Sources/FeimiCore/Candidate.swift`
- Create: `Tests/FeimiCoreTests/FeimiDictionaryTests.swift`
- Modify: `history.md`

- [ ] **Step 1: Write the initial failing import test**

Create `Tests/FeimiCoreTests/FeimiDictionaryTests.swift`:

```swift
import XCTest
@testable import FeimiCore

final class FeimiDictionaryTests: XCTestCase {
    func testPackageImportsFeimiCore() {
        let candidate = Candidate(text: "肥", code: "ucl", index: 0)
        XCTAssertEqual(candidate.text, "肥")
        XCTAssertEqual(candidate.code, "ucl")
        XCTAssertEqual(candidate.index, 0)
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

Run:

```powershell
swift test --filter FeimiDictionaryTests.testPackageImportsFeimiCore
```

Expected: FAIL because `Package.swift` or `Candidate` does not exist.

- [ ] **Step 3: Add the package manifest**

Create `Package.swift`:

```swift
// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "UCLLIUSwift",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(name: "FeimiCore", targets: ["FeimiCore"])
    ],
    targets: [
        .target(name: "FeimiCore"),
        .testTarget(name: "FeimiCoreTests", dependencies: ["FeimiCore"])
    ]
)
```

- [ ] **Step 4: Add the minimal Candidate type**

Create `Sources/FeimiCore/Candidate.swift`:

```swift
public struct Candidate: Equatable, Sendable {
    public let text: String
    public let code: String
    public let index: Int

    public init(text: String, code: String, index: Int) {
        self.text = text
        self.code = code
        self.index = index
    }
}
```

- [ ] **Step 5: Run test to verify it passes**

Run:

```powershell
swift test --filter FeimiDictionaryTests.testPackageImportsFeimiCore
```

Expected: PASS.

- [ ] **Step 6: Commit**

```powershell
git add Package.swift Sources/FeimiCore/Candidate.swift Tests/FeimiCoreTests/FeimiDictionaryTests.swift history.md
git commit -m "Add FeimiCore Swift package skeleton"
```

## Task 2: FeimiDictionary Lookup

**Files:**
- Modify: `Tests/FeimiCoreTests/FeimiDictionaryTests.swift`
- Create: `Sources/FeimiCore/FeimiDictionary.swift`
- Modify: `history.md`

- [ ] **Step 1: Add failing tests for lookup and lowercasing**

Append to `FeimiDictionaryTests`:

```swift
    func testLookupReturnsCandidatesInOriginalOrder() throws {
        let dictionary = FeimiDictionary(chardefs: [
            "ucl": ["肥", "飛", "非"]
        ])

        XCTAssertEqual(dictionary.lookup("ucl"), [
            Candidate(text: "肥", code: "ucl", index: 0),
            Candidate(text: "飛", code: "ucl", index: 1),
            Candidate(text: "非", code: "ucl", index: 2)
        ])
    }

    func testLookupTreatsCodesAsLowercase() throws {
        let dictionary = FeimiDictionary(chardefs: [
            "sud.": ["녕"]
        ])

        XCTAssertEqual(dictionary.lookup("sUd.").first?.text, "녕")
    }

    func testLookupReturnsEmptyArrayForMissingCode() throws {
        let dictionary = FeimiDictionary(chardefs: [
            "ucl": ["肥"]
        ])

        XCTAssertEqual(dictionary.lookup("missing"), [])
    }
```

- [ ] **Step 2: Run tests to verify they fail**

Run:

```powershell
swift test --filter FeimiDictionaryTests
```

Expected: FAIL because `FeimiDictionary` does not exist.

- [ ] **Step 3: Implement dictionary lookup**

Create `Sources/FeimiCore/FeimiDictionary.swift`:

```swift
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
```

- [ ] **Step 4: Run tests to verify they pass**

Run:

```powershell
swift test --filter FeimiDictionaryTests
```

Expected: PASS.

- [ ] **Step 5: Commit**

```powershell
git add Sources/FeimiCore/FeimiDictionary.swift Tests/FeimiCoreTests/FeimiDictionaryTests.swift history.md
git commit -m "Add FeimiDictionary lookup"
```

## Task 3: Auxiliary Selection And Reverse Lookup

**Files:**
- Modify: `Tests/FeimiCoreTests/FeimiDictionaryTests.swift`
- Modify: `Sources/FeimiCore/FeimiDictionary.swift`
- Modify: `history.md`

- [ ] **Step 1: Add failing tests for `v/r/s/f` and reverse lookup**

Append to `FeimiDictionaryTests`:

```swift
    func testAuxiliarySelectionReturnsNthCandidateWhenDirectCodeMissing() throws {
        let dictionary = FeimiDictionary(chardefs: [
            "abc": ["一", "二", "三", "四", "五"]
        ])

        XCTAssertEqual(dictionary.lookup("abcv").map(\.text), ["二"])
        XCTAssertEqual(dictionary.lookup("abcr").map(\.text), ["三"])
        XCTAssertEqual(dictionary.lookup("abcs").map(\.text), ["四"])
        XCTAssertEqual(dictionary.lookup("abcf").map(\.text), ["五"])
    }

    func testDirectCodeWinsOverAuxiliarySelection() throws {
        let dictionary = FeimiDictionary(chardefs: [
            "abcv": ["直"],
            "abc": ["一", "二"]
        ])

        XCTAssertEqual(dictionary.lookup("abcv").map(\.text), ["直"])
    }

    func testReverseLookupUsesShortestKnownCodeAndCandidateIndex() throws {
        let dictionary = FeimiDictionary(chardefs: [
            "abcd": ["肥"],
            "ucl": ["肥", "飛"]
        ])

        XCTAssertEqual(dictionary.reverseLookup(character: "肥"), "ucl")
        XCTAssertEqual(dictionary.reverseLookup(character: "飛"), "ucl1")
        XCTAssertEqual(dictionary.reverseLookup(text: "肥飛"), "ucl ucl1")
    }
```

- [ ] **Step 2: Run tests to verify they fail**

Run:

```powershell
swift test --filter FeimiDictionaryTests
```

Expected: FAIL because auxiliary selection and reverse lookup are missing.

- [ ] **Step 3: Implement auxiliary selection and reverse lookup**

Replace `FeimiDictionary.swift` with:

```swift
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
```

- [ ] **Step 4: Run tests to verify they pass**

Run:

```powershell
swift test --filter FeimiDictionaryTests
```

Expected: PASS.

- [ ] **Step 5: Commit**

```powershell
git add Sources/FeimiCore/FeimiDictionary.swift Tests/FeimiCoreTests/FeimiDictionaryTests.swift history.md
git commit -m "Add Feimi reverse lookup"
```

## Task 4: CIN Parser

**Files:**
- Create: `Tests/FeimiCoreTests/CinParserTests.swift`
- Create: `Sources/FeimiCore/CinParser.swift`
- Modify: `history.md`

- [ ] **Step 1: Write failing CIN parser tests**

Create `Tests/FeimiCoreTests/CinParserTests.swift`:

```swift
import XCTest
@testable import FeimiCore

final class CinParserTests: XCTestCase {
    func testParsesChardefBlock() throws {
        let source = """
        %gen_inp
        %chardef begin
        ucl 肥 飛 非
        abc 一
        %chardef end
        """

        let parsed = try CinParser().parse(source)

        XCTAssertEqual(parsed["ucl"], ["肥", "飛", "非"])
        XCTAssertEqual(parsed["abc"], ["一"])
    }

    func testIgnoresBlankLinesAndHeaderOutsideChardef() throws {
        let source = """
        %ename liu

        %chardef begin

        ucl 肥

        %chardef end
        abc should-not-parse
        """

        XCTAssertEqual(try CinParser().parse(source), ["ucl": ["肥"]])
    }

    func testThrowsWhenChardefBlockIsMissing() throws {
        XCTAssertThrowsError(try CinParser().parse("ucl 肥")) { error in
            XCTAssertEqual(error as? CinParser.ParseError, .missingChardefBlock)
        }
    }
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run:

```powershell
swift test --filter CinParserTests
```

Expected: FAIL because `CinParser` does not exist.

- [ ] **Step 3: Implement CIN parser**

Create `Sources/FeimiCore/CinParser.swift`:

```swift
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
            if line.isEmpty { continue }

            if line == "%chardef begin" {
                inChardef = true
                sawChardef = true
                continue
            }

            if line == "%chardef end" {
                inChardef = false
                break
            }

            guard inChardef else { continue }

            let parts = line.split(whereSeparator: { $0 == " " || $0 == "\t" }).map(String.init)
            guard parts.count >= 2 else { continue }
            result[parts[0].lowercased(), default: []].append(contentsOf: parts.dropFirst())
        }

        guard sawChardef else {
            throw ParseError.missingChardefBlock
        }

        return result
    }
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run:

```powershell
swift test --filter CinParserTests
```

Expected: PASS.

- [ ] **Step 5: Commit**

```powershell
git add Sources/FeimiCore/CinParser.swift Tests/FeimiCoreTests/CinParserTests.swift history.md
git commit -m "Add CIN parser"
```

## Task 5: Pinyi Engine

**Files:**
- Create: `Tests/FeimiCoreTests/PinyiEngineTests.swift`
- Create: `Sources/FeimiCore/PinyiEngine.swift`
- Modify: `history.md`

- [ ] **Step 1: Write failing pinyi tests**

Create `Tests/FeimiCoreTests/PinyiEngineTests.swift`:

```swift
import XCTest
@testable import FeimiCore

final class PinyiEngineTests: XCTestCase {
    private let fixture = """
    VERSION_0.01
    , - . / 0 1 2 3 4 5 6 7 8 9 ; a b c d e f g h i j k l m n o p q r s t u v w x y z
    ㄝ ㄦ ㄡ ㄥ ㄢ ㄅ ㄉ ˇ ˋ ㄓ ˊ ˙ ㄚ ㄞ ㄤ ㄇ ㄖ ㄏ ㄎ ㄍ ㄑ ㄕ ㄘ ㄛ ㄨ ㄜ ㄠ ㄩ ㄙ ㄟ ㄣ ㄆ ㄐ ㄋ ㄔ ㄧ ㄒ ㄊ ㄌ ㄗ ㄈ
    -3 爾 耳 洱
    wj/ 通 恫 蓪
    pns 你 妳 擬
    """

    func testParsesVersion001Pinyi() throws {
        let engine = try PinyiEngine(source: fixture)

        XCTAssertEqual(engine.zhuyinSymbols(for: "wj/"), "ㄊㄨㄥ")
        XCTAssertEqual(engine.zhuyinKey(for: "ㄊㄨㄥ"), "wj/")
        XCTAssertEqual(engine.zhuyinCandidates(for: "wj/"), ["通", "恫", "蓪"])
    }

    func testSameSoundLookupDeduplicatesAndPreservesOrder() throws {
        let source = fixture + "\npns 你 祢 你\n"
        let engine = try PinyiEngine(source: source)

        XCTAssertEqual(engine.sameSoundCandidates(containing: "你"), ["你", "妳", "擬", "祢"])
    }
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run:

```powershell
swift test --filter PinyiEngineTests
```

Expected: FAIL because `PinyiEngine` does not exist.

- [ ] **Step 3: Implement pinyi parser and lookup**

Create `Sources/FeimiCore/PinyiEngine.swift`:

```swift
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

        guard lines.count >= 3 else { throw ParseError.missingHeader }
        guard lines[0] == "VERSION_0.01" else { throw ParseError.unsupportedVersion }

        let keys = lines[1].split(separator: " ").map(String.init)
        let symbols = lines[2].split(separator: " ").map(String.init)
        guard keys.count == symbols.count else { throw ParseError.missingHeader }

        var keyToSymbol: [Character: Character] = [:]
        var symbolToKey: [Character: Character] = [:]
        for index in keys.indices {
            guard let key = keys[index].first, let symbol = symbols[index].first else { continue }
            keyToSymbol[key] = symbol
            symbolToKey[symbol] = key
        }

        var pronunciationToCandidates: [String: [String]] = [:]
        var rows: [[String]] = []
        for line in lines.dropFirst(3) {
            let parts = line.split(separator: " ").map(String.init)
            guard parts.count >= 2 else { continue }
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
```

- [ ] **Step 4: Run tests to verify they pass**

Run:

```powershell
swift test --filter PinyiEngineTests
```

Expected: PASS.

- [ ] **Step 5: Commit**

```powershell
git add Sources/FeimiCore/PinyiEngine.swift Tests/FeimiCoreTests/PinyiEngineTests.swift history.md
git commit -m "Add pinyi parser"
```

## Task 6: Command Processor

**Files:**
- Create: `Tests/FeimiCoreTests/CommandProcessorTests.swift`
- Create: `Sources/FeimiCore/CommandProcessor.swift`
- Modify: `history.md`

- [ ] **Step 1: Write failing command tests**

Create `Tests/FeimiCoreTests/CommandProcessorTests.swift`:

```swift
import XCTest
@testable import FeimiCore

final class CommandProcessorTests: XCTestCase {
    func testRecognizesAll001CommandsCaseInsensitively() {
        let processor = CommandProcessor()

        XCTAssertEqual(processor.command(in: ",,,unlock"), .unlock)
        XCTAssertEqual(processor.command(in: ",,,LOCK"), .lock)
        XCTAssertEqual(processor.command(in: ",,,version"), .version)
        XCTAssertEqual(processor.command(in: ",,,c"), .simplified)
        XCTAssertEqual(processor.command(in: ",,,t"), .traditional)
        XCTAssertEqual(processor.command(in: ",,,s"), .narrow)
        XCTAssertEqual(processor.command(in: ",,,l"), .wide)
        XCTAssertEqual(processor.command(in: ",,,+"), .larger)
        XCTAssertEqual(processor.command(in: ",,,-"), .smaller)
        XCTAssertEqual(processor.command(in: ",,,z"), .articleToCode)
        XCTAssertEqual(processor.command(in: ",,,x"), .codeToArticle)
    }

    func testReturnsNilWhenBufferDoesNotEndWithCommand() {
        let processor = CommandProcessor()

        XCTAssertNil(processor.command(in: "abc"))
        XCTAssertNil(processor.command(in: ",,"))
        XCTAssertNil(processor.command(in: "abc,,,unknown"))
    }
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run:

```powershell
swift test --filter CommandProcessorTests
```

Expected: FAIL because `CommandProcessor` does not exist.

- [ ] **Step 3: Implement command processor**

Create `Sources/FeimiCore/CommandProcessor.swift`:

```swift
public enum FeimiCommand: Equatable, Sendable {
    case unlock
    case lock
    case version
    case simplified
    case traditional
    case narrow
    case wide
    case larger
    case smaller
    case articleToCode
    case codeToArticle
}

public struct CommandProcessor: Sendable {
    private let commands: [(suffix: String, command: FeimiCommand)] = [
        (",,,unlock", .unlock),
        (",,,lock", .lock),
        (",,,version", .version),
        (",,,c", .simplified),
        (",,,t", .traditional),
        (",,,s", .narrow),
        (",,,l", .wide),
        (",,,+", .larger),
        (",,,-", .smaller),
        (",,,z", .articleToCode),
        (",,,x", .codeToArticle)
    ]

    public init() {}

    public func command(in buffer: String) -> FeimiCommand? {
        let normalized = buffer.lowercased()
        return commands.first { normalized.hasSuffix($0.suffix) }?.command
    }
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run:

```powershell
swift test --filter CommandProcessorTests
```

Expected: PASS.

- [ ] **Step 5: Commit**

```powershell
git add Sources/FeimiCore/CommandProcessor.swift Tests/FeimiCoreTests/CommandProcessorTests.swift history.md
git commit -m "Add Feimi command processor"
```

## Task 7: Feimi Engine Basic Input

**Files:**
- Create: `Tests/FeimiCoreTests/FeimiEngineTests.swift`
- Create: `Sources/FeimiCore/FeimiEngine.swift`
- Modify: `history.md`

- [ ] **Step 1: Write failing engine tests**

Create `Tests/FeimiCoreTests/FeimiEngineTests.swift`:

```swift
import XCTest
@testable import FeimiCore

final class FeimiEngineTests: XCTestCase {
    func testTypingLettersUpdatesBufferAndCandidates() {
        var engine = FeimiEngine(dictionary: FeimiDictionary(chardefs: ["ucl": ["肥"]]))

        let result = engine.handle(.text("u"))
        XCTAssertEqual(result.composition, "u")
        XCTAssertEqual(result.candidates, [])

        let result2 = engine.handle(.text("cl"))
        XCTAssertEqual(result2.composition, "ucl")
        XCTAssertEqual(result2.candidates.map(\.text), ["肥"])
    }

    func testSpaceCommitsFirstCandidateAndClearsComposition() {
        var engine = FeimiEngine(dictionary: FeimiDictionary(chardefs: ["ucl": ["肥"]]))
        _ = engine.handle(.text("ucl"))

        let result = engine.handle(.space)

        XCTAssertEqual(result.commitText, "肥")
        XCTAssertEqual(result.composition, "")
        XCTAssertEqual(result.candidates, [])
    }

    func testEnterCommitsRawCode() {
        var engine = FeimiEngine(dictionary: FeimiDictionary(chardefs: ["ucl": ["肥"]]))
        _ = engine.handle(.text("ucl"))

        let result = engine.handle(.enter)

        XCTAssertEqual(result.commitText, "ucl")
        XCTAssertEqual(result.composition, "")
    }

    func testBackspaceDeletesPreviousCodeUnit() {
        var engine = FeimiEngine(dictionary: FeimiDictionary(chardefs: ["uc": ["測"]]))
        _ = engine.handle(.text("ucl"))

        let result = engine.handle(.backspace)

        XCTAssertEqual(result.composition, "uc")
        XCTAssertEqual(result.candidates.map(\.text), ["測"])
    }
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run:

```powershell
swift test --filter FeimiEngineTests
```

Expected: FAIL because `FeimiEngine` does not exist.

- [ ] **Step 3: Implement basic engine**

Create `Sources/FeimiCore/FeimiEngine.swift`:

```swift
public enum FeimiInput: Equatable, Sendable {
    case text(String)
    case space
    case enter
    case escape
    case backspace
}

public struct FeimiEngineResult: Equatable, Sendable {
    public let composition: String
    public let candidates: [Candidate]
    public let commitText: String?
    public let command: FeimiCommand?

    public init(composition: String, candidates: [Candidate], commitText: String? = nil, command: FeimiCommand? = nil) {
        self.composition = composition
        self.candidates = candidates
        self.commitText = commitText
        self.command = command
    }
}

public struct FeimiEngine: Sendable {
    private let dictionary: FeimiDictionary
    private let commandProcessor: CommandProcessor
    private var buffer = ""
    private var candidates: [Candidate] = []

    public init(dictionary: FeimiDictionary, commandProcessor: CommandProcessor = CommandProcessor()) {
        self.dictionary = dictionary
        self.commandProcessor = commandProcessor
    }

    public mutating func handle(_ input: FeimiInput) -> FeimiEngineResult {
        switch input {
        case .text(let text):
            buffer += text
            if let command = commandProcessor.command(in: buffer) {
                clear()
                return FeimiEngineResult(composition: "", candidates: [], command: command)
            }
            candidates = dictionary.lookup(buffer)
            return currentResult()

        case .space:
            if let first = candidates.first {
                clear()
                return FeimiEngineResult(composition: "", candidates: [], commitText: first.text)
            }
            return currentResult()

        case .enter:
            let raw = buffer
            clear()
            return FeimiEngineResult(composition: "", candidates: [], commitText: raw.isEmpty ? nil : raw)

        case .escape:
            clear()
            return currentResult()

        case .backspace:
            if !buffer.isEmpty {
                buffer.removeLast()
                candidates = dictionary.lookup(buffer)
            }
            return currentResult()
        }
    }

    private func currentResult() -> FeimiEngineResult {
        FeimiEngineResult(composition: buffer, candidates: candidates)
    }

    private mutating func clear() {
        buffer = ""
        candidates = []
    }
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run:

```powershell
swift test --filter FeimiEngineTests
```

Expected: PASS.

- [ ] **Step 5: Run full core test suite**

Run:

```powershell
swift test
```

Expected: PASS.

- [ ] **Step 6: Commit**

```powershell
git add Sources/FeimiCore/FeimiEngine.swift Tests/FeimiCoreTests/FeimiEngineTests.swift history.md
git commit -m "Add basic Feimi engine input handling"
```

## Self-Review

Spec coverage in this foundation plan:

- Dictionary lookup: Tasks 2 and 3.
- Reverse lookup for `,,,z` / `,,,x` core conversion: Task 3.
- `liu.cin` parser: Task 4.
- `pinyi.txt`, same-sound, and zhuyin data parsing: Task 5.
- `,,,` command parsing: Task 6.
- Basic composing behavior: Task 7.
- InputMethodKit app, candidate AppKit window, actual `liu-uni.tab` binary conversion, Application Support persistence, clipboard permissions, installer, and manual app acceptance are not in this foundation plan and should each get their own plan after this core package exists.

Placeholder scan:

- This plan contains no unresolved placeholder markers or unnamed implementation steps.

Type consistency:

- `Candidate`, `FeimiDictionary`, `CinParser`, `PinyiEngine`, `CommandProcessor`, and `FeimiEngine` signatures are introduced before use in later tasks.

## Execution Choice

Plan complete and saved to `docs/superpowers/plans/2026-05-26-feimi-core-foundation.md`.

Two execution options:

1. **Subagent-Driven** - Dispatch a fresh subagent per task, review between tasks, fast iteration.
2. **Inline Execution** - Execute tasks in this session using `superpowers:executing-plans`, with checkpoints.

Because this current workspace is on Windows without `swift`, either option needs a Swift-capable environment for red/green verification. If execution continues here, code can be written but Swift tests cannot be run locally.
