public struct FeimiPanelState: Equatable, Sendable {
    public let inputModeLabel: String
    public let widthModeLabel: String
    public let compositionLabel: String
    public let candidateLabel: String
    public let commandModeLabel: String
    public let shouldShowPanel: Bool

    public init(
        inputModeLabel: String,
        widthModeLabel: String,
        compositionLabel: String,
        candidateLabel: String,
        commandModeLabel: String,
        shouldShowPanel: Bool
    ) {
        self.inputModeLabel = inputModeLabel
        self.widthModeLabel = widthModeLabel
        self.compositionLabel = compositionLabel
        self.candidateLabel = candidateLabel
        self.commandModeLabel = commandModeLabel
        self.shouldShowPanel = shouldShowPanel
    }
}

public struct FeimiDisplayFormatter: Sendable {
    public init() {}

    public func panelState(
        for result: FeimiEngineResult,
        isFeimiMode: Bool = true,
        isHalfWidth: Bool = true,
        isGameMode: Bool = false
    ) -> FeimiPanelState {
        let candidateLabel = result.candidates
            .prefix(10)
            .enumerated()
            .map { index, candidate in "\(index)\(candidate.text)" }
            .joined(separator: " ")

        return FeimiPanelState(
            inputModeLabel: isFeimiMode ? "肥" : "英",
            widthModeLabel: isHalfWidth ? "半" : "全",
            compositionLabel: result.composition,
            candidateLabel: candidateLabel,
            commandModeLabel: isGameMode ? "遊戲模式" : "正常模式",
            shouldShowPanel: !result.composition.isEmpty || !candidateLabel.isEmpty
        )
    }
}
