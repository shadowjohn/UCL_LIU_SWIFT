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
