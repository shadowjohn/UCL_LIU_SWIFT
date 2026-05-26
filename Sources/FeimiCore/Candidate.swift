public struct Candidate: Equatable, Sendable {
    public let text: String
    public let code: String
    public let index: Int

    public init(text: String, code: String, index: Int) {
        self.text = text
        self.code = code
        self.index = index
    }
}
