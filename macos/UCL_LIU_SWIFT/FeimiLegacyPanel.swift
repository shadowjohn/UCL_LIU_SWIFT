import AppKit

final class FeimiLegacyPanel {
    static let shared = FeimiLegacyPanel()

    private enum DefaultsKey {
        static let scale = "FeimiLegacyPanel.scale"
        static let candidateWidth = "FeimiLegacyPanel.candidateWidth"
        static let hasManualOrigin = "FeimiLegacyPanel.hasManualOrigin"
        static let manualOriginX = "FeimiLegacyPanel.manualOriginX"
        static let manualOriginY = "FeimiLegacyPanel.manualOriginY"
    }

    private let inputModeLabel = FeimiPanelCell(width: CGFloat(FeimiPanelLayout.inputModeWidth), alignment: .center)
    private let widthModeLabel = FeimiPanelCell(width: CGFloat(FeimiPanelLayout.widthModeWidth), alignment: .center)
    private let compositionLabel = FeimiPanelCell(width: CGFloat(FeimiPanelLayout.compositionWidth), alignment: .left)
    private let candidateLabel = FeimiPanelCell(width: CGFloat(FeimiPanelLayout.defaultCandidateWidth), alignment: .left)
    private let commandModeLabel = FeimiPanelCell(width: CGFloat(FeimiPanelLayout.commandModeWidth), alignment: .center)
    private let closeButton = NSButton(title: "X", target: nil, action: nil)
    private lazy var panel: NSPanel = makePanel()
    private var closeButtonWidthConstraint: NSLayoutConstraint?
    private var closeButtonHeightConstraint: NSLayoutConstraint?
    private var scale: CGFloat
    private var candidateWidth: CGFloat
    private var isHiddenByUser = false
    private var manualOrigin: NSPoint?
    private var dragStartMouseLocation: NSPoint?
    private var dragStartPanelOrigin: NSPoint?

    private init() {
        let savedScale = UserDefaults.standard.double(forKey: DefaultsKey.scale)
        let savedCandidateWidth = UserDefaults.standard.double(forKey: DefaultsKey.candidateWidth)
        let defaults = UserDefaults.standard
        self.scale = savedScale > 0 ? CGFloat(savedScale) : 1
        if savedCandidateWidth > 0 {
            self.candidateWidth = CGFloat(savedCandidateWidth)
        } else {
            self.candidateWidth = CGFloat(FeimiPanelLayout.defaultCandidateWidth)
        }
        if defaults.bool(forKey: DefaultsKey.hasManualOrigin) {
            self.manualOrigin = NSPoint(
                x: defaults.double(forKey: DefaultsKey.manualOriginX),
                y: defaults.double(forKey: DefaultsKey.manualOriginY)
            )
        }
    }

    func update(
        with state: FeimiPanelState,
        anchor: NSPoint?,
        revealsUserHiddenPanel: Bool = false
    ) {
        DispatchQueue.main.async {
            if revealsUserHiddenPanel {
                self.isHiddenByUser = false
            }

            guard state.shouldShowPanel, !self.isHiddenByUser else {
                self.panel.orderOut(nil)
                return
            }

            self.inputModeLabel.stringValue = state.inputModeLabel
            self.widthModeLabel.stringValue = state.widthModeLabel
            self.compositionLabel.stringValue = state.compositionLabel
            self.candidateLabel.stringValue = state.candidateLabel
            self.commandModeLabel.stringValue = state.commandModeLabel

            self.applyPanelMetrics()
            self.panel.setFrameOrigin(self.panelOrigin(anchor: anchor))
            self.panel.orderFrontRegardless()
        }
    }

    func hide() {
        DispatchQueue.main.async {
            self.panel.orderOut(nil)
        }
    }

    func hideByUser() {
        DispatchQueue.main.async {
            self.isHiddenByUser = true
            self.panel.orderOut(nil)
        }
    }

    func isNarrowLayoutEnabled() -> Bool {
        candidateWidth <= CGFloat(FeimiPanelLayout.narrowCandidateWidth)
    }

    func setWideLayout() {
        DispatchQueue.main.async {
            self.candidateWidth = CGFloat(FeimiPanelLayout.wideCandidateWidth)
            self.saveMetrics()
            self.applyPanelMetrics()
        }
    }

    func setNarrowLayout() {
        DispatchQueue.main.async {
            self.candidateWidth = CGFloat(FeimiPanelLayout.narrowCandidateWidth)
            self.saveMetrics()
            self.applyPanelMetrics()
        }
    }

    func increaseScale() {
        DispatchQueue.main.async {
            self.scale = min(self.scale + 0.1, CGFloat(FeimiPanelLayout.maximumScale))
            self.saveMetrics()
            self.applyPanelMetrics()
        }
    }

    func decreaseScale() {
        DispatchQueue.main.async {
            self.scale = max(self.scale - 0.1, CGFloat(FeimiPanelLayout.minimumScale))
            self.saveMetrics()
            self.applyPanelMetrics()
        }
    }

    private func makePanel() -> NSPanel {
        let panel = NSPanel(
            contentRect: NSRect(
                x: 120,
                y: 120,
                width: CGFloat(FeimiPanelLayout.contentWidth(
                    candidateWidth: FeimiPanelLayout.defaultCandidateWidth,
                    scale: 1
                )),
                height: CGFloat(FeimiPanelLayout.contentHeight(scale: 1))
            ),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.isReleasedWhenClosed = false
        panel.hidesOnDeactivate = false
        panel.level = .floating
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.backgroundColor = NSColor(calibratedWhite: 0.82, alpha: 1)
        panel.isOpaque = true
        panel.hasShadow = true

        let beginDrag: () -> Void = { [weak self] in
            self?.beginDraggingPanel()
        }
        let drag: () -> Void = { [weak self] in
            self?.dragPanel()
        }
        let endDrag: () -> Void = { [weak self] in
            self?.endDraggingPanel()
        }
        [
            inputModeLabel,
            widthModeLabel,
            compositionLabel,
            candidateLabel,
            commandModeLabel,
        ].forEach {
            $0.onMouseDown = beginDrag
            $0.onMouseDragged = drag
            $0.onMouseUp = endDrag
        }

        let stack = NSStackView()
        stack.orientation = .horizontal
        stack.alignment = .centerY
        stack.distribution = .fill
        stack.spacing = 0
        stack.translatesAutoresizingMaskIntoConstraints = false

        closeButton.bezelStyle = .regularSquare
        closeButton.font = NSFont.boldSystemFont(ofSize: 16)
        closeButton.target = self
        closeButton.action = #selector(closeButtonClicked)
        closeButton.translatesAutoresizingMaskIntoConstraints = false

        [
            inputModeLabel,
            widthModeLabel,
            compositionLabel,
            candidateLabel,
            commandModeLabel,
            closeButton,
        ].forEach(stack.addArrangedSubview)

        let contentView = FeimiPanelContentView()
        contentView.onMouseDown = beginDrag
        contentView.onMouseDragged = drag
        contentView.onMouseUp = endDrag
        contentView.wantsLayer = true
        contentView.layer?.backgroundColor = NSColor(calibratedWhite: 0.82, alpha: 1).cgColor
        contentView.layer?.borderColor = NSColor.black.cgColor
        contentView.layer?.borderWidth = 1
        contentView.addSubview(stack)
        panel.contentView = contentView

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stack.topAnchor.constraint(equalTo: contentView.topAnchor),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])

        applyPanelMetrics(to: panel)
        return panel
    }

    private func applyPanelMetrics(to targetPanel: NSPanel? = nil) {
        let cellHeight = CGFloat(FeimiPanelLayout.cellHeight) * scale
        inputModeLabel.set(
            width: CGFloat(FeimiPanelLayout.inputModeWidth) * scale,
            fontSize: 16 * scale,
            height: cellHeight
        )
        widthModeLabel.set(
            width: CGFloat(FeimiPanelLayout.widthModeWidth) * scale,
            fontSize: 16 * scale,
            height: cellHeight
        )
        compositionLabel.set(
            width: CGFloat(FeimiPanelLayout.compositionWidth) * scale,
            fontSize: 18 * scale,
            height: cellHeight
        )
        candidateLabel.set(width: candidateWidth * scale, fontSize: 18 * scale, height: cellHeight)
        commandModeLabel.set(
            width: CGFloat(FeimiPanelLayout.commandModeWidth) * scale,
            fontSize: 14 * scale,
            height: cellHeight
        )
        closeButton.font = NSFont.boldSystemFont(ofSize: 16 * scale)

        let buttonWidth = CGFloat(FeimiPanelLayout.closeButtonWidth) * scale
        closeButtonWidthConstraint?.isActive = false
        closeButtonHeightConstraint?.isActive = false
        closeButtonWidthConstraint = closeButton.widthAnchor.constraint(equalToConstant: buttonWidth)
        closeButtonHeightConstraint = closeButton.heightAnchor.constraint(equalToConstant: cellHeight)
        closeButtonWidthConstraint?.isActive = true
        closeButtonHeightConstraint?.isActive = true

        let width = FeimiPanelLayout.contentWidth(
            candidateWidth: Double(candidateWidth),
            scale: Double(scale)
        )
        let height = FeimiPanelLayout.contentHeight(scale: Double(scale))
        let activePanel = targetPanel ?? panel
        activePanel.setContentSize(NSSize(width: CGFloat(width), height: CGFloat(height)))
        activePanel.contentView?.layoutSubtreeIfNeeded()
    }

    private func saveMetrics() {
        UserDefaults.standard.set(Double(scale), forKey: DefaultsKey.scale)
        UserDefaults.standard.set(Double(candidateWidth), forKey: DefaultsKey.candidateWidth)
    }

    private func panelOrigin(anchor: NSPoint?) -> NSPoint {
        if let manualOrigin {
            return constrainedPanelOrigin(manualOrigin)
        }

        guard let screen = NSScreen.screens.first else {
            return NSPoint(x: 120, y: 120)
        }

        let visibleFrame = screen.visibleFrame
        let panelSize = panel.frame.size
        let preferred: NSPoint
        if let anchor {
            preferred = NSPoint(x: anchor.x, y: anchor.y - panelSize.height - 6)
        } else {
            preferred = NSPoint(
                x: visibleFrame.maxX - panelSize.width - 24,
                y: visibleFrame.minY + 8
            )
        }

        return constrainedPanelOrigin(preferred)
    }

    private func constrainedPanelOrigin(_ preferred: NSPoint) -> NSPoint {
        guard let screen = NSScreen.screens.first else {
            return preferred
        }

        let visibleFrame = screen.visibleFrame
        let panelSize = panel.frame.size
        let x = min(max(preferred.x, visibleFrame.minX + 8), visibleFrame.maxX - panelSize.width - 8)
        let y = min(max(preferred.y, visibleFrame.minY + 8), visibleFrame.maxY - panelSize.height - 8)
        return NSPoint(x: x, y: y)
    }

    private func beginDraggingPanel() {
        dragStartMouseLocation = NSEvent.mouseLocation
        dragStartPanelOrigin = panel.frame.origin
    }

    private func dragPanel() {
        guard let dragStartMouseLocation, let dragStartPanelOrigin else {
            beginDraggingPanel()
            return
        }

        let mouseLocation = NSEvent.mouseLocation
        let preferredOrigin = NSPoint(
            x: dragStartPanelOrigin.x + mouseLocation.x - dragStartMouseLocation.x,
            y: dragStartPanelOrigin.y + mouseLocation.y - dragStartMouseLocation.y
        )
        let newOrigin = constrainedPanelOrigin(preferredOrigin)
        panel.setFrameOrigin(newOrigin)
        manualOrigin = newOrigin
        saveManualOrigin(newOrigin)
    }

    private func endDraggingPanel() {
        dragPanel()
        dragStartMouseLocation = nil
        dragStartPanelOrigin = nil
    }

    private func saveManualOrigin(_ origin: NSPoint) {
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: DefaultsKey.hasManualOrigin)
        defaults.set(Double(origin.x), forKey: DefaultsKey.manualOriginX)
        defaults.set(Double(origin.y), forKey: DefaultsKey.manualOriginY)
    }

    @objc private func closeButtonClicked() {
        hideByUser()
    }
}

private final class FeimiPanelContentView: NSView {
    var onMouseDown: (() -> Void)?
    var onMouseDragged: (() -> Void)?
    var onMouseUp: (() -> Void)?

    override func mouseDown(with event: NSEvent) {
        onMouseDown?()
    }

    override func mouseDragged(with event: NSEvent) {
        onMouseDragged?()
    }

    override func mouseUp(with event: NSEvent) {
        onMouseUp?()
    }
}

private final class FeimiPanelCell: NSTextField {
    private var widthConstraint: NSLayoutConstraint?
    private var heightConstraint: NSLayoutConstraint?
    var onMouseDown: (() -> Void)?
    var onMouseDragged: (() -> Void)?
    var onMouseUp: (() -> Void)?

    init(width: CGFloat, alignment: NSTextAlignment) {
        super.init(frame: .zero)
        cell = FeimiCenteredTextFieldCell(textCell: "")
        translatesAutoresizingMaskIntoConstraints = false
        isEditable = false
        isSelectable = false
        isBezeled = false
        drawsBackground = true
        backgroundColor = NSColor(calibratedWhite: 0.86, alpha: 1)
        textColor = NSColor.black
        font = NSFont.boldSystemFont(ofSize: 18)
        lineBreakMode = .byTruncatingTail
        wantsLayer = true
        layer?.borderColor = NSColor.black.cgColor
        layer?.borderWidth = 1
        self.alignment = alignment
        set(width: width, fontSize: 18, height: 40)
    }

    func set(width: CGFloat, fontSize: CGFloat, height: CGFloat) {
        widthConstraint?.isActive = false
        heightConstraint?.isActive = false
        widthConstraint = widthAnchor.constraint(equalToConstant: width)
        heightConstraint = heightAnchor.constraint(equalToConstant: height)
        widthConstraint?.isActive = true
        heightConstraint?.isActive = true
        font = NSFont.boldSystemFont(ofSize: fontSize)
    }

    override func mouseDown(with event: NSEvent) {
        onMouseDown?()
    }

    override func mouseDragged(with event: NSEvent) {
        onMouseDragged?()
    }

    override func mouseUp(with event: NSEvent) {
        onMouseUp?()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        return nil
    }
}

private final class FeimiCenteredTextFieldCell: NSTextFieldCell {
    override func drawingRect(forBounds rect: NSRect) -> NSRect {
        var centeredRect = super.drawingRect(forBounds: rect)
        let textHeight = cellSize(forBounds: rect).height
        centeredRect.origin.y = rect.origin.y + max((rect.height - textHeight) / 2, 0)
        centeredRect.size.height = min(textHeight, rect.height)
        return centeredRect
    }
}
