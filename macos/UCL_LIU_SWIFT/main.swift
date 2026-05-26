import AppKit
import Carbon
import Foundation
import InputMethodKit

private let fallbackInputSourceID = "tw.3wa.UCL_LIU_SWIFT"

private func uniqueNonEmpty(_ values: [String]) -> [String] {
    var seen = Set<String>()
    return values.filter { value in
        guard !value.isEmpty, !seen.contains(value) else {
            return false
        }
        seen.insert(value)
        return true
    }
}

private func configuredInputSourceIDs() -> [String] {
    let info = Bundle.main.infoDictionary ?? [:]
    var inputSourceIDs = [fallbackInputSourceID]

    if let inputSourceID = info["TISInputSourceID"] as? String {
        inputSourceIDs.append(inputSourceID)
    }

    if let visibleInputModes = info["tsVisibleInputModeOrderedArrayKey"] as? [String] {
        inputSourceIDs.append(contentsOf: visibleInputModes)
    }

    if let components = info["ComponentInputModeDict"] as? [String: Any],
       let modeList = components["tsInputModeListKey"] as? [String: Any] {
        inputSourceIDs.append(contentsOf: modeList.keys.map(\.description))
    }

    return uniqueNonEmpty(inputSourceIDs)
}

private func inputSourceProperty(_ inputSource: TISInputSource, key: CFString) -> String? {
    guard let pointer = TISGetInputSourceProperty(inputSource, key) else {
        return nil
    }

    return Unmanaged<CFString>.fromOpaque(pointer).takeUnretainedValue() as String
}

private func findRegisteredInputSources(matching expectedInputSourceIDs: [String]) -> [TISInputSource] {
    guard let allSources = TISCreateInputSourceList(nil, true)?.takeRetainedValue() as? [TISInputSource] else {
        return []
    }

    return expectedInputSourceIDs.compactMap { expectedID in
        allSources.first { inputSource in
            inputSourceProperty(inputSource, key: kTISPropertyInputSourceID) == expectedID ||
                inputSourceProperty(inputSource, key: kTISPropertyInputModeID) == expectedID
        }
    }
}

private func logRegistrationDiagnostics(expectedInputSourceIDs: [String], bundleIdentifier: String) {
    guard let allSources = TISCreateInputSourceList(nil, true)?.takeRetainedValue() as? [TISInputSource] else {
        NSLog("UCL_LIU_SWIFT: cannot list input sources for registration diagnostics")
        return
    }

    let expectedSet = Set(expectedInputSourceIDs.map { $0.lowercased() })
    let nearbySources = allSources.compactMap { inputSource -> String? in
        let sourceID = inputSourceProperty(inputSource, key: kTISPropertyInputSourceID)
        let sourceModeID = inputSourceProperty(inputSource, key: kTISPropertyInputModeID)
        let sourceBundleID = inputSourceProperty(inputSource, key: kTISPropertyBundleID)
        let sourceName = inputSourceProperty(inputSource, key: kTISPropertyLocalizedName)
        let searchable = [sourceID, sourceModeID, sourceBundleID, sourceName]
            .compactMap { $0 }
            .joined(separator: " ")
            .lowercased()

        guard expectedSet.contains(sourceID?.lowercased() ?? "") ||
            expectedSet.contains(sourceModeID?.lowercased() ?? "") ||
            searchable.contains("ucl") ||
            searchable.contains("liu") ||
            searchable.contains("3wa") ||
            searchable.contains("shadowjohn") ||
            searchable.contains("feimi") else {
            return nil
        }

        return "id=\(sourceID ?? "<nil>"), mode=\(sourceModeID ?? "<nil>"), bundle=\(sourceBundleID ?? "<nil>"), name=\(sourceName ?? "<nil>")"
    }

    NSLog("UCL_LIU_SWIFT: expected input source ids: \(expectedInputSourceIDs.joined(separator: ", ")), bundle id: \(bundleIdentifier)")
    if nearbySources.isEmpty {
        NSLog("UCL_LIU_SWIFT: no nearby input sources found after registration")
    } else {
        for source in nearbySources {
            NSLog("UCL_LIU_SWIFT: nearby input source: \(source)")
        }
    }
}

private func registerInputMethod() -> Int32 {
    let bundleURL = Bundle.main.bundleURL
    let bundleIdentifier = Bundle.main.bundleIdentifier ?? "tw.3wa.inputmethod.UCL-LIU-SWIFT"
    let inputSourceIDs = configuredInputSourceIDs()
    let registerStatus = TISRegisterInputSource(bundleURL as CFURL)
    guard registerStatus == noErr else {
        NSLog("UCL_LIU_SWIFT: TISRegisterInputSource failed: \(registerStatus)")
        return registerStatus
    }

    let inputSources = findRegisteredInputSources(matching: inputSourceIDs)
    guard !inputSources.isEmpty else {
        NSLog("UCL_LIU_SWIFT: registered but cannot find input source: \(inputSourceIDs.joined(separator: ", "))")
        logRegistrationDiagnostics(expectedInputSourceIDs: inputSourceIDs, bundleIdentifier: bundleIdentifier)
        return 2
    }

    for inputSource in inputSources {
        let inputSourceID = inputSourceProperty(inputSource, key: kTISPropertyInputSourceID) ?? inputSourceIDs[0]
        let enableStatus = TISEnableInputSource(inputSource)
        if enableStatus == noErr {
            _ = TISSelectInputSource(inputSource)
            NSLog("UCL_LIU_SWIFT: enabled input source: \(inputSourceID)")
        } else {
            NSLog("UCL_LIU_SWIFT: TISEnableInputSource failed: \(enableStatus)")
        }
    }

    return 0
}

if CommandLine.arguments.dropFirst().first?.lowercased() == "install" {
    exit(registerInputMethod())
}

guard let server = IMKServer(
    name: Bundle.main.infoDictionary?["InputMethodConnectionName"] as? String,
    bundleIdentifier: Bundle.main.bundleIdentifier
) else {
    NSLog("UCL_LIU_SWIFT: cannot initialize IMKServer")
    exit(1)
}

let feimiInputMethodServer = server
_ = feimiInputMethodServer
NSApplication.shared.setActivationPolicy(.accessory)
let feimiStatusMenu = FeimiStatusMenu.shared
_ = feimiStatusMenu
_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
