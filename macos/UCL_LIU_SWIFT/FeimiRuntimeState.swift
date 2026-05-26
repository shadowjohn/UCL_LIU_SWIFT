import Foundation

final class FeimiRuntimeState {
    static let shared = FeimiRuntimeState()

    private enum DefaultsKey {
        static let gameMode = "FeimiRuntimeState.gameMode"
        static let feimiMode = "FeimiRuntimeState.feimiMode"
    }

    private(set) var isGameMode: Bool
    private(set) var isFeimiMode: Bool

    private init() {
        self.isGameMode = UserDefaults.standard.bool(forKey: DefaultsKey.gameMode)
        if UserDefaults.standard.object(forKey: DefaultsKey.feimiMode) == nil {
            self.isFeimiMode = true
        } else {
            self.isFeimiMode = UserDefaults.standard.bool(forKey: DefaultsKey.feimiMode)
        }
    }

    func setGameMode(_ isGameMode: Bool) {
        self.isGameMode = isGameMode
        UserDefaults.standard.set(isGameMode, forKey: DefaultsKey.gameMode)
    }

    func toggleGameMode() {
        setGameMode(!isGameMode)
    }

    func setFeimiMode(_ isFeimiMode: Bool) {
        self.isFeimiMode = isFeimiMode
        UserDefaults.standard.set(isFeimiMode, forKey: DefaultsKey.feimiMode)
    }

    func toggleFeimiMode() {
        setFeimiMode(!isFeimiMode)
    }
}
