import XCTest
@testable import FeimiCore

final class JsonDictionaryParserTests: XCTestCase {
    func testParsesPimeStyleChardefs() throws {
        let source = """
        {
          "chardefs": {
            "CL": ["中", "忠"],
            "a": "日"
          }
        }
        """

        let result = try JsonDictionaryParser().parse(source)

        XCTAssertEqual(result["cl"], ["中", "忠"])
        XCTAssertEqual(result["a"], ["日"])
    }

    func testThrowsWhenChardefsAreMissing() {
        XCTAssertThrowsError(try JsonDictionaryParser().parse("{}")) { error in
            XCTAssertEqual(error as? JsonDictionaryParser.ParseError, .missingChardefs)
        }
    }
}
