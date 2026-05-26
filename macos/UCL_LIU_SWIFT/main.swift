import AppKit
import Carbon
import Foundation
import InputMethodKit

private func registerInputMethod() -> Int32 {
    let bundleURL = Bundle.main.bundleURL
    let bundleIdentifier = Bundle.main.bundleIdentifier ?? "tw.shadowjohn.UCLLIUSWIFT"
    let registerStatus = TISRegisterInputSource(bundleURL as CFURL)
    guard registerStatus == noErr else {
        NSLog("UCL_LIU_SWIFT: TISRegisterInputSource failed: \(registerStatus)")
        return registerStatus
    }

    let properties = [
        kTISPropertyInputSourceID as String: bundleIdentifier
    ] as CFDictionary

    guard let inputSources = TISCreateInputSourceList(properties, true)?.takeRetainedValue() as? [TISInputSource],
          !inputSources.isEmpty else {
        NSLog("UCL_LIU_SWIFT: registered but cannot find input source: \(bundleIdentifier)")
        return 2
    }

    for inputSource in inputSources {
        let enableStatus = TISEnableInputSource(inputSource)
        if enableStatus == noErr {
            _ = TISSelectInputSource(inputSource)
            NSLog("UCL_LIU_SWIFT: enabled input source: \(bundleIdentifier)")
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
