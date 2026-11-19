import Cocoa
import SwiftUI

let settingsRequested = NSEvent.modifierFlags.contains(.option)
    || CommandLine.arguments.contains("--settings")
    || CommandLine.arguments.contains("--show-ui")

UserDefaults.standard.register(defaults: ["PreferredTerminal": TerminalManager.defaultTerminal.rawValue])

handleOpenRequest(showSettings: settingsRequested,
                  forceTerminal: CommandLine.arguments.contains("--open-terminal")) {
    Go2ShellApp.main()
}

@MainActor
func handleOpenRequest(showSettings: Bool, forceTerminal: Bool = false, presentSettings: () -> Void) {
    if showSettings {
        presentSettings()
        return
    }
    do {
        let context = try FinderManager.currentContext()
        if context.isApplicationSelected && !forceTerminal {
            presentSettings()
        } else {
            try TerminalManager.openTerminal(at: context.directory)
        }
    } catch {
        NSLog("go2shell: %@", error.localizedDescription)
        NSApplication.shared.activate()
        NSAlert(error: error).runModal()
    }
}
