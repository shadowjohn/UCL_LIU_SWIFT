public enum FeimiPanelLayout {
    public static let inputModeWidth = 36.0
    public static let widthModeWidth = 36.0
    public static let compositionWidth = 130.0
    public static let defaultCandidateWidth = 350.0
    public static let narrowCandidateWidth = 260.0
    public static let wideCandidateWidth = 520.0
    public static let commandModeWidth = 86.0
    public static let closeButtonWidth = 34.0
    public static let cellHeight = 40.0
    public static let minimumScale = 0.8
    public static let maximumScale = 1.8

    public static func contentWidth(candidateWidth: Double, scale: Double) -> Double {
        (
            inputModeWidth +
                widthModeWidth +
                compositionWidth +
                candidateWidth +
                commandModeWidth +
                closeButtonWidth
        ) * scale + 2
    }

    public static func contentHeight(scale: Double) -> Double {
        cellHeight * scale + 2
    }
}
