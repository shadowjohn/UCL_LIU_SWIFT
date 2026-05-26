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
