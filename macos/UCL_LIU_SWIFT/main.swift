import AppKit
import Carbon
import Foundation
import InputMethodKit

private let fallbackInputSourceID = "tw.3wa.UCL_LIU_SWIFT"

private func configuredInputSourceID() -> String {
    guard let inputSourceID = Bundle.main.infoDictionary?["TISInputSourceID"] as? String,
          !inputSourceID.isEmpty else {
        return fallbackInputSourceID
    }

    return inputSourceID
}

private func inputSourceProperty(_ inputSource: TISInputSource, key: CFString) -> String? {
    guard let pointer = TISGetInputSourceProperty(inputSource, key) else {
        return nil
    }

    return Unmanaged<CFString>.fromOpaque(pointer).takeUnretainedValue() as String
}

private func logRegistrationDiagnostics(expectedInputSourceID: String, bundleIdentifier: String) {
    guard let allSources = TISCreateInputSourceList(nil, true)?.takeRetainedValue() as? [TISInputSource] else {
        NSLog("UCL_LIU_SWIFT: cannot list input sources for registration diagnostics")
        return
    }

    let nearbySources = allSources.compactMap { inputSource -> String? in
        let sourceID = inputSourceProperty(inputSource, key: kTISPropertyInputSourceID)
        let sourceBundleID = inputSourceProperty(inputSource, key: kTISPropertyBundleID)
        let sourceName = inputSourceProperty(inputSource, key: kTISPropertyLocalizedName)
        let searchable = [sourceID, sourceBundleID, sourceName]
            .compactMap { $0 }
            .joined(separator: " ")
            .lowercased()

        guard searchable.contains("ucl") ||
            searchable.contains("liu") ||
            searchable.contains("3wa") ||
            searchable.contains("shadowjohn") ||
            searchable.contains("feimi") else {
            return nil
        }

        return "id=\(sourceID ?? "<nil>"), bundle=\(sourceBundleID ?? "<nil>"), name=\(sourceName ?? "<nil>")"
    }

    NSLog("UCL_LIU_SWIFT: expected input source id: \(expectedInputSourceID), bundle id: \(bundleIdentifier)")
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
    let inputSourceID = configuredInputSourceID()
    let registerStatus = TISRegisterInputSource(bundleURL as CFURL)
    guard registerStatus == noErr else {
        NSLog("UCL_LIU_SWIFT: TISRegisterInputSource failed: \(registerStatus)")
        return registerStatus
    }

    let properties = [
        kTISPropertyInputSourceID as String: inputSourceID
    ] as CFDictionary

    guard let inputSources = TISCreateInputSourceList(properties, true)?.takeRetainedValue() as? [TISInputSource],
          !inputSources.isEmpty else {
        NSLog("UCL_LIU_SWIFT: registered but cannot find input source: \(inputSourceID)")
        logRegistrationDiagnostics(expectedInputSourceID: inputSourceID, bundleIdentifier: bundleIdentifier)
        return 2
    }

    for inputSource in inputSources {
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
_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
