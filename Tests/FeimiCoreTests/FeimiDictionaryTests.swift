import XCTest
@testable import FeimiCore

final class FeimiDictionaryTests: XCTestCase {
    func testPackageImportsFeimiCore() {
        let candidate = Candidate(text: "肥", code: "ucl", index: 0)
        XCTAssertEqual(candidate.text, "肥")
        XCTAssertEqual(candidate.code, "ucl")
        XCTAssertEqual(candidate.index, 0)
    }

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
}
