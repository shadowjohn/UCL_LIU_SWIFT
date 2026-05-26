import Foundation
import XCTest

final class MacOSMetadataTests: XCTestCase {
    func testInputMethodUsesFeimiAsVisibleName() throws {
        let plist = try loadInfoPlist()

        XCTAssertEqual(plist["CFBundleName"] as? String, "肥米")
        XCTAssertEqual(plist["CFBundleDisplayName"] as? String, "肥米")
        XCTAssertEqual(plist["CFBundleExecutable"] as? String, "UCL_LIU_SWIFT")
        XCTAssertEqual(plist["TISInputSourceID"] as? String, "tw.3wa.UCL_LIU_SWIFT")
    }

    func testControlSpacePredicateUsesExplicitReturn() throws {
        let source = try String(contentsOf: macOSSourceURL("FeimiInputController.swift"))

        XCTAssertTrue(source.contains("private func isControlSpace(_ event: NSEvent) -> Bool"))
        XCTAssertTrue(source.contains("return event.keyCode == 49"))
    }

    private func loadInfoPlist(
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> [String: Any] {
        let plistURL = macOSSourceURL("Info.plist", file: file)
        let data = try Data(contentsOf: plistURL)
        let plist = try PropertyListSerialization.propertyList(from: data, options: [], format: nil)

        guard let dictionary = plist as? [String: Any] else {
            XCTFail("Info.plist is not a dictionary", file: file, line: line)
            return [:]
        }

        return dictionary
    }

    private func macOSSourceURL(
        _ pathComponent: String,
        file: StaticString = #filePath
    ) -> URL {
        let testFileURL = URL(fileURLWithPath: String(describing: file))
        return testFileURL
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("macos")
            .appendingPathComponent("UCL_LIU_SWIFT")
            .appendingPathComponent(pathComponent)
    }
}
