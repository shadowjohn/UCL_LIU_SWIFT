import XCTest
@testable import FeimiCore

final class FeimiDisplayFormatterTests: XCTestCase {
    func testFormatsLegacyPanelStateWithCompositionAndCandidates() {
        let result = FeimiEngineResult(
            composition: "abc",
            candidates: [
                Candidate(text: "肥", code: "abc", index: 0),
                Candidate(text: "飛", code: "abc", index: 1),
            ]
        )

        let state = FeimiDisplayFormatter().panelState(for: result)

        XCTAssertEqual(state.inputModeLabel, "肥")
        XCTAssertEqual(state.widthModeLabel, "半")
        XCTAssertEqual(state.compositionLabel, "abc")
        XCTAssertEqual(state.candidateLabel, "0肥 1飛")
        XCTAssertEqual(state.commandModeLabel, "正常模式")
        XCTAssertTrue(state.shouldShowPanel)
    }

    func testHidesLegacyPanelWhenCompositionAndCandidatesAreEmpty() {
        let result = FeimiEngineResult(composition: "", candidates: [])

        let state = FeimiDisplayFormatter().panelState(for: result)

        XCTAssertFalse(state.shouldShowPanel)
        XCTAssertEqual(state.compositionLabel, "")
        XCTAssertEqual(state.candidateLabel, "")
    }

    func testKeepsLegacyPanelVisibleInPersistentModeWhenEmpty() {
        let result = FeimiEngineResult(composition: "", candidates: [])

        let state = FeimiDisplayFormatter().panelState(for: result, keepsPanelVisible: true)

        XCTAssertTrue(state.shouldShowPanel)
        XCTAssertEqual(state.inputModeLabel, "肥")
        XCTAssertEqual(state.widthModeLabel, "半")
        XCTAssertEqual(state.compositionLabel, "")
        XCTAssertEqual(state.candidateLabel, "")
        XCTAssertEqual(state.commandModeLabel, "正常模式")
    }

    func testFormatsGameModeLabel() {
        let result = FeimiEngineResult(composition: "abc", candidates: [])

        let state = FeimiDisplayFormatter().panelState(for: result, isGameMode: true)

        XCTAssertEqual(state.commandModeLabel, "遊戲模式")
    }

    func testFormatsEnglishModeLabel() {
        let result = FeimiEngineResult(composition: "", candidates: [])

        let state = FeimiDisplayFormatter().panelState(
            for: result,
            isFeimiMode: false,
            keepsPanelVisible: true
        )

        XCTAssertEqual(state.inputModeLabel, "英")
        XCTAssertTrue(state.shouldShowPanel)
    }

    func testLimitsCandidateTextToTenItems() {
        let candidates = (0..<12).map { index in
            Candidate(text: "\(index)", code: "abc", index: index)
        }
        let result = FeimiEngineResult(composition: "abc", candidates: candidates)

        let state = FeimiDisplayFormatter().panelState(for: result)

        XCTAssertEqual(state.candidateLabel, "00 11 22 33 44 55 66 77 88 99")
    }
}
