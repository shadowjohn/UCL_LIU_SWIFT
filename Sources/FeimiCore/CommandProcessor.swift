public enum FeimiCommand: Equatable, Sendable {
    case unlock
    case lock
    case version
    case simplified
    case traditional
    case narrow
    case wide
    case larger
    case smaller
    case articleToCode
    case codeToArticle
}

public struct CommandProcessor: Sendable {
    private let commands: [(suffix: String, command: FeimiCommand)] = [
        (",,,unlock", .unlock),
        (",,,lock", .lock),
        (",,,version", .version),
        (",,,c", .simplified),
        (",,,t", .traditional),
        (",,,s", .narrow),
        (",,,l", .wide),
        (",,,+", .larger),
        (",,,-", .smaller),
        (",,,z", .articleToCode),
        (",,,x", .codeToArticle)
    ]

    public init() {}

    public func command(in buffer: String) -> FeimiCommand? {
        let normalized = buffer.lowercased()
        return commands.first { normalized.hasSuffix($0.suffix) }?.command
    }
}
