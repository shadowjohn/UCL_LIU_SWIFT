import XCTest
@testable import FeimiCore

final class FeimiPanelLayoutTests: XCTestCase {
    func testNarrowLayoutKeepsPanelShorterThanDefaultAndWideLayouts() {
        XCTAssertLessThan(
            FeimiPanelLayout.narrowCandidateWidth,
            FeimiPanelLayout.defaultCandidateWidth
        )
        XCTAssertLessThan(
            FeimiPanelLayout.defaultCandidateWidth,
            FeimiPanelLayout.wideCandidateWidth
        )
    }

    func testContentWidthShrinksWhenCandidateWidthShrinks() {
        let narrowWidth = FeimiPanelLayout.contentWidth(
            candidateWidth: FeimiPanelLayout.narrowCandidateWidth,
            scale: 1
        )
        let defaultWidth = FeimiPanelLayout.contentWidth(
            candidateWidth: FeimiPanelLayout.defaultCandidateWidth,
            scale: 1
        )

        XCTAssertLessThan(narrowWidth, defaultWidth)
    }

    func testDefaultMetricsStayCloseToWindowsLegacyPanel() {
        XCTAssertEqual(FeimiPanelLayout.inputModeWidth, 36)
        XCTAssertEqual(FeimiPanelLayout.widthModeWidth, 36)
        XCTAssertEqual(FeimiPanelLayout.compositionWidth, 130)
        XCTAssertEqual(FeimiPanelLayout.defaultCandidateWidth, 350)
        XCTAssertEqual(FeimiPanelLayout.commandModeWidth, 86)
        XCTAssertEqual(FeimiPanelLayout.closeButtonWidth, 34)
        XCTAssertEqual(FeimiPanelLayout.cellHeight, 40)
        XCTAssertEqual(FeimiPanelLayout.contentWidth(
            candidateWidth: FeimiPanelLayout.defaultCandidateWidth,
            scale: 1
        ), 674)
        XCTAssertEqual(FeimiPanelLayout.contentHeight(scale: 1), 42)
    }
}
