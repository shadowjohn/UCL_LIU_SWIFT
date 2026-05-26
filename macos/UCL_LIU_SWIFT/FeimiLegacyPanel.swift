import AppKit

final class FeimiLegacyPanel {
    static let shared = FeimiLegacyPanel()

    private enum DefaultsKey {
        static let scale = "FeimiLegacyPanel.scale"
        static let candidateWidth = "FeimiLegacyPanel.candidateWidth"
    }

    private let inputModeLabel = FeimiPanelCell(width: 40, alignment: .center)
    private let widthModeLabel = FeimiPanelCell(width: 40, alignment: .center)
    private let compositionLabel = FeimiPanelCell(width: 150, alignment: .left)
    private let candidateLabel = FeimiPanelCell(width: 360, alignment: .left)
    private let commandModeLabel = FeimiPanelCell(width: 120, alignment: .center)
    private let closeButton = NSButton(title: "╳", target: nil, action: nil)
    private lazy var panel: NSPanel = makePanel()
    private var closeButtonWidthConstraint: NSLayoutConstraint?
    private var closeButtonHeightConstraint: NSLayoutConstraint?
    private var scale: CGFloat
    private var candidateWidth: CGFloat

    private init() {
        let savedScale = UserDefaults.standard.double(forKey: DefaultsKey.scale)
        let savedCandidateWidth = UserDefaults.standard.double(forKey: DefaultsKey.candidateWidth)
        self.scale = savedScale > 0 ? savedScale : 1
        self.candidateWidth = savedCandidateWidth > 0 ? savedCandidateWidth : 360
    }

    func update(with state: FeimiPanelState, anchor: NSPoint?) {
        DispatchQueue.main.async {
            guard state.shouldShowPanel else {
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

    func setWideLayout() {
        DispatchQueue.main.async {
            self.candidateWidth = 520
            self.saveMetrics()
            self.applyPanelMetrics()
        }
    }

    func setNarrowLayout() {
        DispatchQueue.main.async {
            self.candidateWidth = 260
            self.saveMetrics()
            self.applyPanelMetrics()
        }
    }

    func increaseScale() {
        DispatchQueue.main.async {
            self.scale = min(self.scale + 0.1, 1.8)
            self.saveMetrics()
            self.applyPanelMetrics()
        }
    }

    func decreaseScale() {
        DispatchQueue.main.async {
            self.scale = max(self.scale - 0.1, 0.8)
            self.saveMetrics()
            self.applyPanelMetrics()
        }
    }

    private func makePanel() -> NSPanel {
        let panel = NSPanel(
            contentRect: NSRect(x: 120, y: 120, width: 754, height: 42),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.isReleasedWhenClosed = false
        panel.hidesOnDeactivate = false
        panel.level = .floating
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.backgroundColor = NSColor.windowBackgroundColor
        panel.isOpaque = true
        panel.hasShadow = true

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

        let contentView = NSView()
        contentView.wantsLayer = true
        contentView.layer?.borderColor = NSColor.separatorColor.cgColor
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
        inputModeLabel.set(width: 40 * scale, fontSize: 16 * scale, height: 40 * scale)
        widthModeLabel.set(width: 40 * scale, fontSize: 16 * scale, height: 40 * scale)
        compositionLabel.set(width: 150 * scale, fontSize: 18 * scale, height: 40 * scale)
        candidateLabel.set(width: candidateWidth * scale, fontSize: 18 * scale, height: 40 * scale)
        commandModeLabel.set(width: 120 * scale, fontSize: 14 * scale, height: 40 * scale)
        closeButton.font = NSFont.boldSystemFont(ofSize: 16 * scale)

        let buttonSide = 40 * scale
        closeButtonWidthConstraint?.isActive = false
        closeButtonHeightConstraint?.isActive = false
        closeButtonWidthConstraint = closeButton.widthAnchor.constraint(equalToConstant: buttonSide)
        closeButtonHeightConstraint = closeButton.heightAnchor.constraint(equalToConstant: buttonSide)
        closeButtonWidthConstraint?.isActive = true
        closeButtonHeightConstraint?.isActive = true

        let width = (40 + 40 + 150 + candidateWidth + 120 + 40) * scale + 4
        let height = 40 * scale + 2
        let activePanel = targetPanel ?? panel
        activePanel.setContentSize(NSSize(width: width, height: height))
        activePanel.contentView?.layoutSubtreeIfNeeded()
    }

    private func saveMetrics() {
        UserDefaults.standard.set(Double(scale), forKey: DefaultsKey.scale)
        UserDefaults.standard.set(Double(candidateWidth), forKey: DefaultsKey.candidateWidth)
    }

    private func panelOrigin(anchor: NSPoint?) -> NSPoint {
        guard let screen = NSScreen.screens.first else {
            return NSPoint(x: 120, y: 120)
        }

        let visibleFrame = screen.visibleFrame
        let panelSize = panel.frame.size
        let preferred = anchor ?? NSPoint(
            x: visibleFrame.maxX - panelSize.width - 24,
            y: visibleFrame.minY + 24
        )
        let x = min(max(preferred.x, visibleFrame.minX + 8), visibleFrame.maxX - panelSize.width - 8)
        let y = min(max(preferred.y - panelSize.height - 6, visibleFrame.minY + 8), visibleFrame.maxY - panelSize.height - 8)

        return NSPoint(x: x, y: y)
    }

    @objc private func closeButtonClicked() {
        panel.orderOut(nil)
    }
}

private final class FeimiPanelCell: NSTextField {
    private var widthConstraint: NSLayoutConstraint?
    private var heightConstraint: NSLayoutConstraint?

    init(width: CGFloat, alignment: NSTextAlignment) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        isEditable = false
        isSelectable = false
        isBezeled = false
        drawsBackground = true
        backgroundColor = NSColor.textBackgroundColor
        textColor = NSColor.labelColor
        font = NSFont.boldSystemFont(ofSize: 18)
        lineBreakMode = .byTruncatingTail
        wantsLayer = true
        layer?.borderColor = NSColor.separatorColor.cgColor
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

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        return nil
    }
}
