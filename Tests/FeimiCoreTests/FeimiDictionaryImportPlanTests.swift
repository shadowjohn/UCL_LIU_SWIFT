import Foundation
import XCTest
@testable import FeimiCore

final class FeimiDictionaryImportPlanTests: XCTestCase {
    func testPlansJsonImport() throws {
        let plan = try FeimiDictionaryImportPlan(
            sourceURL: URL(fileURLWithPath: "/Downloads/my-liu.json")
        )

        XCTAssertEqual(plan.kind, .json)
        XCTAssertEqual(plan.destinationFileName, "liu.json")
        XCTAssertEqual(plan.fileNamesToBackUpBeforeCopy, ["liu.json"])
    }

    func testPlansCinImport() throws {
        let plan = try FeimiDictionaryImportPlan(
            sourceURL: URL(fileURLWithPath: "/Downloads/anything.cin")
        )

        XCTAssertEqual(plan.kind, .cin)
        XCTAssertEqual(plan.destinationFileName, "liu.cin")
        XCTAssertEqual(plan.fileNamesToBackUpBeforeCopy, ["liu.cin", "liu.json"])
    }

    func testPlansOfficialTabImportOnlyForLiuUniTab() throws {
        let plan = try FeimiDictionaryImportPlan(
            sourceURL: URL(fileURLWithPath: "/Downloads/LIU-UNI.TAB")
        )

        XCTAssertEqual(plan.kind, .tab)
        XCTAssertEqual(plan.destinationFileName, "liu-uni.tab")
        XCTAssertEqual(plan.fileNamesToBackUpBeforeCopy, ["liu-uni.tab", "liu.cin", "liu.json"])
    }

    func testRejectsUnsupportedImportFile() {
        XCTAssertThrowsError(
            try FeimiDictionaryImportPlan(sourceURL: URL(fileURLWithPath: "/Downloads/other.tab"))
        ) { error in
            XCTAssertEqual(error as? FeimiDictionaryImportPlan.ImportError, .unsupportedFile("other.tab"))
        }
    }
}
