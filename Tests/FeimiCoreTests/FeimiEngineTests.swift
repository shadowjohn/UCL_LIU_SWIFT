import XCTest
@testable import FeimiCore

final class FeimiEngineTests: XCTestCase {
    func testTypingLettersUpdatesCompositionAndCandidates() {
        var engine = FeimiEngine(dictionary: FeimiDictionary(chardefs: [
            "cl": ["中", "忠"]
        ]))

        let first = engine.handle(.text("c"))
        XCTAssertEqual(first.composition, "c")
        XCTAssertEqual(first.candidates, [])
        XCTAssertNil(first.commitText)

        let second = engine.handle(.text("l"))
        XCTAssertEqual(second.composition, "cl")
        XCTAssertEqual(second.candidates.map(\.text), ["中", "忠"])
        XCTAssertNil(second.commitText)
    }

    func testSpaceCommitsFirstCandidateAndClearsComposition() {
        var engine = FeimiEngine(dictionary: FeimiDictionary(chardefs: [
            "cl": ["中", "忠"]
        ]))

        _ = engine.handle(.text("cl"))
        let result = engine.handle(.space)

        XCTAssertEqual(result.commitText, "中")
        XCTAssertEqual(result.composition, "")
        XCTAssertEqual(result.candidates, [])
    }

    func testEnterCommitsRawCompositionWhenNoCandidateIsAccepted() {
        var engine = FeimiEngine(dictionary: FeimiDictionary(chardefs: [:]))

        _ = engine.handle(.text("abc"))
        let result = engine.handle(.enter)

        XCTAssertEqual(result.commitText, "abc")
        XCTAssertEqual(result.composition, "")
        XCTAssertEqual(result.candidates, [])
    }

    func testBackspaceDeletesPreviousCharacterAndRefreshesCandidates() {
        var engine = FeimiEngine(dictionary: FeimiDictionary(chardefs: [
            "cl": ["中"],
            "c": ["一"]
        ]))

        _ = engine.handle(.text("cl"))
        let result = engine.handle(.backspace)

        XCTAssertEqual(result.composition, "c")
        XCTAssertEqual(result.candidates.map(\.text), ["一"])
    }

    func testCommandClearsCompositionAndReturnsCommand() {
        var engine = FeimiEngine(dictionary: FeimiDictionary(chardefs: [:]))

        _ = engine.handle(.text(",,,z"))
        let result = engine.handle(.enter)

        XCTAssertEqual(result.command, .articleToCode)
        XCTAssertNil(result.commitText)
        XCTAssertEqual(result.composition, "")
    }
}
