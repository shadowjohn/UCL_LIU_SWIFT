import XCTest
@testable import FeimiCore

final class PinyiEngineTests: XCTestCase {
    private let fixture = """
    VERSION_0.01
    , - . / 0 1 2 3 4 5 6 7 8 9 ; a b c d e f g h i j k l m n o p q r s t u v w x y z
    ㄝ ㄦ ㄡ ㄥ ㄢ ㄅ ㄉ ˇ ˋ ㄓ ˊ ˙ ㄚ ㄞ ㄤ ㄇ ㄖ ㄏ ㄎ ㄍ ㄑ ㄕ ㄘ ㄛ ㄨ ㄜ ㄠ ㄩ ㄙ ㄟ ㄣ ㄆ ㄐ ㄋ ㄔ ㄧ ㄒ ㄊ ㄌ ㄗ ㄈ
    -3 爾 耳 洱
    wj/ 通 恫 蓪
    pns 你 妳 擬
    """

    func testParsesVersion001Pinyi() throws {
        let engine = try PinyiEngine(source: fixture)

        XCTAssertEqual(engine.zhuyinSymbols(for: "wj/"), "ㄊㄨㄥ")
        XCTAssertEqual(engine.zhuyinKey(for: "ㄊㄨㄥ"), "wj/")
        XCTAssertEqual(engine.zhuyinCandidates(for: "wj/"), ["通", "恫", "蓪"])
    }

    func testSameSoundLookupDeduplicatesAndPreservesOrder() throws {
        let source = fixture + "\npns 你 祢 你\n"
        let engine = try PinyiEngine(source: source)

        XCTAssertEqual(engine.sameSoundCandidates(containing: "你"), ["你", "妳", "擬", "祢"])
    }
}
