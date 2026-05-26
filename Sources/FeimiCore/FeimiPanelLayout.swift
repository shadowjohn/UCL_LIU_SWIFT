public enum FeimiPanelLayout {
    public static let defaultCandidateWidth = 360.0
    public static let narrowCandidateWidth = 260.0
    public static let wideCandidateWidth = 520.0
    public static let minimumScale = 0.8
    public static let maximumScale = 1.8

    public static func contentWidth(candidateWidth: Double, scale: Double) -> Double {
        (40 + 40 + 150 + candidateWidth + 120 + 40) * scale + 4
    }

    public static func contentHeight(scale: Double) -> Double {
        40 * scale + 2
    }
}
