import Foundation
import XCTest
@testable import FeimiCore

final class FeimiDictionaryLoaderTests: XCTestCase {
    func testLoadsJsonBeforeCin() throws {
        let directory = try makeTemporaryDirectory()
        try write("""
        {"chardefs":{"ab":["金"]}}
        """, to: directory.appendingPathComponent("liu.json"))
        try write("""
        %chardef begin
        ab 中
        %chardef end
        """, to: directory.appendingPathComponent("liu.cin"))

        let result = try FeimiDictionaryLoader().load(from: directory)

        XCTAssertEqual(result.source, .json)
        XCTAssertEqual(result.chardefs["ab"], ["金"])
        XCTAssertEqual(result.dictionary.lookup("ab").map(\.text), ["金"])
    }

    func testLoadsCinAndWritesJsonCacheWhenJsonIsMissing() throws {
        let directory = try makeTemporaryDirectory()
        try write("""
        %chardef begin
        ab 中 忠
        %chardef end
        """, to: directory.appendingPathComponent("liu.cin"))

        let result = try FeimiDictionaryLoader().load(from: directory)

        XCTAssertEqual(result.source, .cin)
        XCTAssertEqual(result.chardefs["ab"], ["中", "忠"])
        XCTAssertTrue(FileManager.default.fileExists(atPath: directory.appendingPathComponent("liu.json").path))
    }

    func testLoadsTabAndWritesCinAndJsonCachesWhenJsonAndCinAreMissing() throws {
        let directory = try makeTemporaryDirectory()
        try LiuTabTestSupport.makeTab(entries: [
            ("ab", "中")
        ]).write(to: directory.appendingPathComponent("liu-uni.tab"))

        let result = try FeimiDictionaryLoader().load(from: directory)

        XCTAssertEqual(result.source, .tab)
        XCTAssertEqual(result.chardefs["ab"], ["中"])
        XCTAssertTrue(FileManager.default.fileExists(atPath: directory.appendingPathComponent("liu.cin").path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: directory.appendingPathComponent("liu.json").path))
    }

    func testThrowsWhenNoDictionaryFileExists() throws {
        let directory = try makeTemporaryDirectory()

        XCTAssertThrowsError(try FeimiDictionaryLoader().load(from: directory)) { error in
            XCTAssertEqual(error as? FeimiDictionaryLoader.LoadError, .missingDictionaryFiles)
        }
    }

    private func makeTemporaryDirectory() throws -> URL {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("UCL_LIU_SWIFT_Tests", isDirectory: true)
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        addTeardownBlock {
            try? FileManager.default.removeItem(at: directory)
        }
        return directory
    }

    private func write(_ content: String, to url: URL) throws {
        try content.data(using: .utf8)!.write(to: url)
    }
}
