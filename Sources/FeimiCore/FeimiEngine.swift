public enum FeimiInput: Equatable, Sendable {
    case text(String)
    case space
    case enter
    case escape
    case backspace
}

public struct FeimiEngineResult: Equatable, Sendable {
    public let composition: String
    public let candidates: [Candidate]
    public let commitText: String?
    public let command: FeimiCommand?

    public init(
        composition: String,
        candidates: [Candidate],
        commitText: String? = nil,
        command: FeimiCommand? = nil
    ) {
        self.composition = composition
        self.candidates = candidates
        self.commitText = commitText
        self.command = command
    }
}

public struct FeimiEngine: Sendable {
    private let dictionary: FeimiDictionary
    private let commandProcessor: CommandProcessor
    private var buffer: String
    private var candidates: [Candidate]

    public init(dictionary: FeimiDictionary, commandProcessor: CommandProcessor = CommandProcessor()) {
        self.dictionary = dictionary
        self.commandProcessor = commandProcessor
        self.buffer = ""
        self.candidates = []
    }

    public mutating func handle(_ input: FeimiInput) -> FeimiEngineResult {
        switch input {
        case .text(let text):
            buffer.append(contentsOf: text.lowercased())
            refreshCandidates()
            return currentResult()

        case .space:
            return acceptWithSpace()

        case .enter:
            return acceptWithEnter()

        case .escape:
            clear()
            return currentResult()

        case .backspace:
            guard !buffer.isEmpty else {
                return currentResult()
            }
            buffer.removeLast()
            refreshCandidates()
            return currentResult()
        }
    }

    private mutating func acceptWithSpace() -> FeimiEngineResult {
        if let command = commandProcessor.command(in: buffer) {
            clear()
            return FeimiEngineResult(composition: "", candidates: [], command: command)
        }

        if let candidate = candidates.first {
            clear()
            return FeimiEngineResult(composition: "", candidates: [], commitText: candidate.text)
        }

        guard !buffer.isEmpty else {
            return FeimiEngineResult(composition: "", candidates: [], commitText: " ")
        }

        let rawText = "\(buffer) "
        clear()
        return FeimiEngineResult(composition: "", candidates: [], commitText: rawText)
    }

    private mutating func acceptWithEnter() -> FeimiEngineResult {
        if let command = commandProcessor.command(in: buffer) {
            clear()
            return FeimiEngineResult(composition: "", candidates: [], command: command)
        }

        guard !buffer.isEmpty else {
            return currentResult()
        }

        let rawText = buffer
        clear()
        return FeimiEngineResult(composition: "", candidates: [], commitText: rawText)
    }

    private func currentResult() -> FeimiEngineResult {
        FeimiEngineResult(composition: buffer, candidates: candidates)
    }

    private mutating func refreshCandidates() {
        candidates = dictionary.lookup(buffer)
    }

    private mutating func clear() {
        buffer = ""
        candidates = []
    }
}
