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
}
