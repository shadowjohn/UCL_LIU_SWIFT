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

    func testPunctuationCodesUpdateCandidates() {
        var engine = FeimiEngine(dictionary: FeimiDictionary(chardefs: [
            "a.": ["點"],
            "b'": ["撇"],
            "c[": ["括"]
        ]))

        XCTAssertEqual(engine.handle(.text("a.")).candidates.map(\.text), ["點"])
        _ = engine.handle(.escape)
        XCTAssertEqual(engine.handle(.text("b'")).candidates.map(\.text), ["撇"])
        _ = engine.handle(.escape)
        XCTAssertEqual(engine.handle(.text("c[")).candidates.map(\.text), ["括"])
    }

    func testApostrophePinyiQueryUsesPinyiCandidates() throws {
        let pinyi = try PinyiEngine(source: """
        VERSION_0.01
        a b c
        ㄅ ㄆ ㄇ
        pns 你 妳 擬
        abc 肥 淝
        """)
        var engine = FeimiEngine(
            dictionary: FeimiDictionary(chardefs: [:]),
            pinyiEngine: pinyi
        )

        let result = engine.handle(.text("'pns"))

        XCTAssertEqual(result.composition, "'pns")
        XCTAssertEqual(result.candidates.map(\.text), ["你", "妳", "擬"])
    }

    func testApostropheChineseCharacterQueryFallsBackToSameSoundCandidates() throws {
        let pinyi = try PinyiEngine(source: """
        VERSION_0.01
        a b c
        ㄅ ㄆ ㄇ
        pns 你 妳 擬
        """)
        var engine = FeimiEngine(
            dictionary: FeimiDictionary(chardefs: [:]),
            pinyiEngine: pinyi
        )

        let result = engine.handle(.text("'你"))

        XCTAssertEqual(result.candidates.map(\.text), ["你", "妳", "擬"])
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

    func testDigitCommitsZeroBasedCandidateAndClearsComposition() {
        var engine = FeimiEngine(dictionary: FeimiDictionary(chardefs: [
            "cl": ["中", "忠", "衷"]
        ]))

        _ = engine.handle(.text("cl"))
        let result = engine.handle(.digit(1))

        XCTAssertEqual(result.commitText, "忠")
        XCTAssertEqual(result.composition, "")
        XCTAssertEqual(result.candidates, [])
    }

    func testDigitZeroCommitsFirstCandidateLikeLegacyFeimi() {
        var engine = FeimiEngine(dictionary: FeimiDictionary(chardefs: [
            "cl": ["中", "忠"]
        ]))

        _ = engine.handle(.text("cl"))
        let result = engine.handle(.digit(0))

        XCTAssertEqual(result.commitText, "中")
        XCTAssertEqual(result.composition, "")
        XCTAssertEqual(result.candidates, [])
    }

    func testUnavailableDigitKeepsComposition() {
        var engine = FeimiEngine(dictionary: FeimiDictionary(chardefs: [
            "cl": ["中"]
        ]))

        _ = engine.handle(.text("cl"))
        let result = engine.handle(.digit(9))

        XCTAssertNil(result.commitText)
        XCTAssertEqual(result.composition, "cl")
        XCTAssertEqual(result.candidates.map(\.text), ["中"])
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
