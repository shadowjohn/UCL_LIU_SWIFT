import AppKit
import Foundation
import InputMethodKit

guard let server = IMKServer(
    name: Bundle.main.infoDictionary?["InputMethodConnectionName"] as? String,
    bundleIdentifier: Bundle.main.bundleIdentifier
) else {
    NSLog("UCL_LIU_SWIFT: cannot initialize IMKServer")
    exit(1)
}

let feimiInputMethodServer = server
NSApplication.shared.setActivationPolicy(.accessory)
NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
