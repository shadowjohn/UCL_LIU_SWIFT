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

    private func loadInfoPlist(
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> [String: Any] {
        let testFileURL = URL(fileURLWithPath: String(describing: file))
        let rootURL = testFileURL
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let plistURL = rootURL
            .appendingPathComponent("macos")
            .appendingPathComponent("UCL_LIU_SWIFT")
            .appendingPathComponent("Info.plist")
        let data = try Data(contentsOf: plistURL)
        let plist = try PropertyListSerialization.propertyList(from: data, options: [], format: nil)

        guard let dictionary = plist as? [String: Any] else {
            XCTFail("Info.plist is not a dictionary", file: file, line: line)
            return [:]
        }

        return dictionary
    }
}
