import AppKit
import InputMethodKit

@objc(FeimiInputController)
final class FeimiInputController: IMKInputController {
    private var engine = FeimiEngine(
        dictionary: FeimiDataStore.loadDictionary(),
        pinyiEngine: FeimiDataStore.loadPinyiEngine()
    )
    private let displayFormatter = FeimiDisplayFormatter()

    override init!(server: IMKServer!, delegate: Any!, client inputClient: Any!) {
        super.init(server: server, delegate: delegate, client: inputClient)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reloadData),
            name: .feimiReloadData,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func recognizedEvents(_ sender: Any!) -> Int {
        Int(NSEvent.EventTypeMask.keyDown.rawValue)
    }

    override func activateServer(_ sender: Any!) {
        showStatusPanel(client: sender)
        FeimiDictionaryImportController.shared.promptForMissingDictionaryIfNeeded()
    }

    override func deactivateServer(_ sender: Any!) {
        FeimiLegacyPanel.shared.hide()
    }

    override func handle(_ event: NSEvent!, client sender: Any!) -> Bool {
        guard event.type == .keyDown else {
            return false
        }

        if isControlSpace(event) {
            let cleared = engine.handle(.escape)
            clearMarkedTextIfNeeded(cleared, client: sender)
            FeimiRuntimeState.shared.toggleFeimiMode()
            showStatusPanel(client: sender, revealsUserHiddenPanel: true)
            return true
        }

        guard FeimiRuntimeState.shared.isFeimiMode else {
            return false
        }

        guard let input = feimiInput(from: event) else {
            return false
        }

        let result = engine.handle(input)

        guard result.didConsumeInput else {
            return false
        }

        clearMarkedTextIfNeeded(result, client: sender)

        if let commitText = result.commitText {
            commit(commitText, client: sender)
        }

        var commandWasHandled = false
        if let command = result.command {
            handle(command, client: sender)
            commandWasHandled = true
        }

        if result.commitText == nil, result.command == nil {
            updateMarkedText(result, client: sender)
        }

        if !commandWasHandled {
            updateLegacyPanel(result, client: sender)
        }

        return true
    }

    private func feimiInput(from event: NSEvent) -> FeimiInput? {
        let blockedModifiers: NSEvent.ModifierFlags = [.command, .control, .option]
        guard event.modifierFlags.intersection(blockedModifiers).isEmpty else {
            return nil
        }

        switch event.keyCode {
        case 36, 76:
            return .enter
        case 49:
            return .space
        case 51, 117:
            return .backspace
        case 53:
            return .escape
        default:
            break
        }

        if let characters = event.charactersIgnoringModifiers,
           characters.count == 1,
           let digit = characters.first?.wholeNumberValue {
            return .digit(digit)
        }

        guard let characters = event.charactersIgnoringModifiers?.lowercased(),
              characters.allSatisfy(isAllowedCompositionCharacter) else {
            return nil
        }

        return characters.isEmpty ? nil : .text(characters)
    }

    private func isControlSpace(_ event: NSEvent) -> Bool {
        let blockedModifiers: NSEvent.ModifierFlags = [.command, .option]
        return event.keyCode == 49 &&
            event.modifierFlags.contains(.control) &&
            event.modifierFlags.intersection(blockedModifiers).isEmpty
    }

    private func isAllowedCompositionCharacter(_ character: Character) -> Bool {
        character.isLetter || ",.'[]+-".contains(character)
    }

    private func updateMarkedText(_ result: FeimiEngineResult, client sender: Any!) {
        guard !result.composition.isEmpty,
              let client = sender as? IMKTextInput else {
            return
        }

        let text = result.composition
        let selection = NSRange(location: text.utf16.count, length: 0)
        client.setMarkedText(
            text as NSString,
            selectionRange: selection,
            replacementRange: NSRange(location: NSNotFound, length: NSNotFound)
        )
    }

    private func clearMarkedTextIfNeeded(_ result: FeimiEngineResult, client sender: Any!) {
        guard result.composition.isEmpty,
              let client = sender as? IMKTextInput else {
            return
        }

        client.setMarkedText(
            "" as NSString,
            selectionRange: NSRange(location: 0, length: 0),
            replacementRange: NSRange(location: NSNotFound, length: NSNotFound)
        )
    }

    private func commit(_ text: String, client sender: Any!) {
        guard let client = sender as? IMKTextInput else {
            return
        }

        client.insertText(
            text as NSString,
            replacementRange: NSRange(location: NSNotFound, length: NSNotFound)
        )
    }

    private func handle(_ command: FeimiCommand, client sender: Any!) {
        switch command {
        case .version:
            commit("肥米 0.01", client: sender)
            showStatusPanel(client: sender)
        case .lock:
            FeimiRuntimeState.shared.setGameMode(true)
            showStatusPanel(client: sender)
        case .unlock:
            FeimiRuntimeState.shared.setGameMode(false)
            showStatusPanel(client: sender)
        case .narrow:
            FeimiLegacyPanel.shared.setNarrowLayout()
            showStatusPanel(client: sender)
        case .wide:
            FeimiLegacyPanel.shared.setWideLayout()
            showStatusPanel(client: sender)
        case .larger:
            FeimiLegacyPanel.shared.increaseScale()
            showStatusPanel(client: sender)
        case .smaller:
            FeimiLegacyPanel.shared.decreaseScale()
            showStatusPanel(client: sender)
        default:
            NSSound.beep()
            NSLog("UCL_LIU_SWIFT: command not wired yet: \(command)")
            showStatusPanel(client: sender)
        }
    }

    private func updateLegacyPanel(_ result: FeimiEngineResult, client sender: Any!) {
        let state = displayFormatter.panelState(
            for: result,
            isFeimiMode: FeimiRuntimeState.shared.isFeimiMode,
            isGameMode: FeimiRuntimeState.shared.isGameMode,
            keepsPanelVisible: true
        )
        FeimiLegacyPanel.shared.update(with: state, anchor: candidateAnchor(client: sender))
    }

    private func showStatusPanel(client sender: Any!, revealsUserHiddenPanel: Bool = false) {
        FeimiLegacyPanel.shared.update(
            with: idlePanelState(),
            anchor: candidateAnchor(client: sender),
            revealsUserHiddenPanel: revealsUserHiddenPanel
        )
    }

    @objc private func reloadData() {
        engine = FeimiEngine(
            dictionary: FeimiDataStore.loadDictionary(),
            pinyiEngine: FeimiDataStore.loadPinyiEngine()
        )
        FeimiLegacyPanel.shared.update(with: idlePanelState(), anchor: nil)
        NSLog("UCL_LIU_SWIFT: reloaded dictionary and pinyi data")
    }

    private func idlePanelState() -> FeimiPanelState {
        FeimiPanelState(
            inputModeLabel: FeimiRuntimeState.shared.isFeimiMode ? "肥" : "英",
            widthModeLabel: "半",
            compositionLabel: "",
            candidateLabel: "",
            commandModeLabel: FeimiRuntimeState.shared.isGameMode ? "遊戲模式" : "正常模式",
            shouldShowPanel: true
        )
    }

    private func candidateAnchor(client sender: Any!) -> NSPoint? {
        guard let client = sender as? IMKTextInput else {
            return nil
        }

        var lineRect = NSRect.zero
        _ = client.attributes(forCharacterIndex: 0, lineHeightRectangle: &lineRect)
        guard !lineRect.isEmpty else {
            return nil
        }

        return NSPoint(x: lineRect.minX, y: lineRect.minY)
    }
}
