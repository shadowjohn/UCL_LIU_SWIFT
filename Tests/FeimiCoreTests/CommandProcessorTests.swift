import XCTest
@testable import FeimiCore

final class CommandProcessorTests: XCTestCase {
    func testRecognizesAll001CommandsCaseInsensitively() {
        let processor = CommandProcessor()

        XCTAssertEqual(processor.command(in: ",,,unlock"), .unlock)
        XCTAssertEqual(processor.command(in: ",,,LOCK"), .lock)
        XCTAssertEqual(processor.command(in: ",,,version"), .version)
        XCTAssertEqual(processor.command(in: ",,,c"), .simplified)
        XCTAssertEqual(processor.command(in: ",,,t"), .traditional)
        XCTAssertEqual(processor.command(in: ",,,s"), .narrow)
        XCTAssertEqual(processor.command(in: ",,,l"), .wide)
        XCTAssertEqual(processor.command(in: ",,,+"), .larger)
        XCTAssertEqual(processor.command(in: ",,,-"), .smaller)
        XCTAssertEqual(processor.command(in: ",,,z"), .articleToCode)
        XCTAssertEqual(processor.command(in: ",,,x"), .codeToArticle)
    }

    func testReturnsNilWhenBufferDoesNotEndWithCommand() {
        let processor = CommandProcessor()

        XCTAssertNil(processor.command(in: "abc"))
        XCTAssertNil(processor.command(in: ",,"))
        XCTAssertNil(processor.command(in: "abc,,,unknown"))
    }
}
