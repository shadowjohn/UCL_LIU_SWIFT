import AppKit
import InputMethodKit

@objc(FeimiInputController)
final class FeimiInputController: IMKInputController {
    private var engine = FeimiEngine(
        dictionary: FeimiDataStore.loadDictionary(),
        pinyiEngine: FeimiDataStore.loadPinyiEngine()
    )

    override func recognizedEvents(_ sender: Any!) -> Int {
        Int(NSEvent.EventTypeMask.keyDown.rawValue)
    }

    override func handle(_ event: NSEvent!, client sender: Any!) -> Bool {
        guard event.type == .keyDown, let input = feimiInput(from: event) else {
            return false
        }

        let result = engine.handle(input)
        clearMarkedTextIfNeeded(result, client: sender)

        if let commitText = result.commitText {
            commit(commitText, client: sender)
        }

        if let command = result.command {
            handle(command, client: sender)
        }

        if result.commitText == nil, result.command == nil {
            updateMarkedText(result, client: sender)
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

    private func isAllowedCompositionCharacter(_ character: Character) -> Bool {
        character.isLetter || ",.'[]+-".contains(character)
    }

    private func updateMarkedText(_ result: FeimiEngineResult, client sender: Any!) {
        guard !result.composition.isEmpty,
              let client = sender as? IMKTextInput else {
            return
        }

        let text = markedText(for: result)
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

    private func markedText(for result: FeimiEngineResult) -> String {
        let candidates = result.candidates.prefix(10).enumerated().map { index, candidate in
            "\(index)\(candidate.text)"
        }.joined(separator: " ")

        guard !candidates.isEmpty else {
            return result.composition
        }

        return "\(result.composition) \(candidates)"
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
            commit("UCL_LIU_SWIFT 0.01", client: sender)
        default:
            NSSound.beep()
            NSLog("UCL_LIU_SWIFT: command not wired yet: \(command)")
        }
    }
}
