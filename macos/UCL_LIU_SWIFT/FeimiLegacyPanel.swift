import AppKit

final class FeimiLegacyPanel {
    static let shared = FeimiLegacyPanel()

    private let inputModeLabel = FeimiPanelCell(width: 40, alignment: .center)
    private let widthModeLabel = FeimiPanelCell(width: 40, alignment: .center)
    private let compositionLabel = FeimiPanelCell(width: 150, alignment: .left)
    private let candidateLabel = FeimiPanelCell(width: 360, alignment: .left)
    private let commandModeLabel = FeimiPanelCell(width: 120, alignment: .center)
    private let closeButton = NSButton(title: "╳", target: nil, action: nil)
    private lazy var panel: NSPanel = makePanel()

    private init() {}

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

            self.panel.contentView?.layoutSubtreeIfNeeded()
            self.panel.setFrameOrigin(self.panelOrigin(anchor: anchor))
            self.panel.orderFrontRegardless()
        }
    }

    func hide() {
        DispatchQueue.main.async {
            self.panel.orderOut(nil)
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
        closeButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 40).isActive = true

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

        return panel
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
        widthAnchor.constraint(equalToConstant: width).isActive = true
        heightAnchor.constraint(equalToConstant: 40).isActive = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        return nil
    }
}
