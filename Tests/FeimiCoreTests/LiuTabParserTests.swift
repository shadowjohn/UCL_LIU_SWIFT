import XCTest
@testable import FeimiCore

final class LiuTabParserTests: XCTestCase {
    func testParsesMinimalSyntheticLiuTabData() throws {
        let data = LiuTabTestSupport.makeTab(entries: [
            ("ab", "中"),
            ("ac", "文")
        ])

        let result = try LiuTabParser().parse(data)

        XCTAssertEqual(result["ab"], ["中"])
        XCTAssertEqual(result["ac"], ["文"])
    }

    func testThrowsWhenTabDataIsTruncated() {
        XCTAssertThrowsError(try LiuTabParser().parse(Data([0x00, 0x01]))) { error in
            XCTAssertEqual(error as? LiuTabParser.ParseError, .truncatedData)
        }
    }

}
