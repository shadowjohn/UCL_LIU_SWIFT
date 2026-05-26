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
}
