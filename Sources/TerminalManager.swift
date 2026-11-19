// 移植自 OpenInTerminal - OpenInTerminalCore/App.swift (Terminal 部分)

import Cocoa

class TerminalManager {
    enum Terminal: String, CaseIterable {
        case terminal = "Terminal"
        case iterm = "iTerm"
        case warp = "Warp"
        case ghostty = "Ghostty"
        case wezterm = "WezTerm"
        case kitty = "Kitty"
        case alacritty = "Alacritty"

        var displayName: String {
            switch self {
            case .terminal: return "Terminal.app"
            case .iterm: return "iTerm2"
            case .warp: return "Warp"
            case .ghostty: return "Ghostty"
            case .wezterm: return "WezTerm"
            case .kitty: return "Kitty"
            case .alacritty: return "Alacritty"
            }
        }

        var appPath: String {
            switch self {
            case .terminal: return "/System/Applications/Utilities/Terminal.app"
            case .iterm: return "/Applications/iTerm.app"
            case .warp: return "/Applications/Warp.app"
            case .ghostty: return "/Applications/Ghostty.app"
            case .wezterm: return "/Applications/WezTerm.app"
            case .kitty: return "/Applications/kitty.app"
            case .alacritty: return "/Applications/Alacritty.app"
            }
        }

        var isInstalled: Bool {
            FileManager.default.fileExists(atPath: appPath)
        }
    }

    static var defaultTerminal: Terminal {
        Terminal.iterm.isInstalled ? .iterm : .terminal
    }

    static func openTerminal(at directory: URL) throws {
        let preference = UserDefaults.standard.string(forKey: "PreferredTerminal") ?? defaultTerminal.rawValue
        let preferred = Terminal(rawValue: preference) ?? defaultTerminal
        let terminal = preferred.isInstalled ? preferred : .terminal
        NSLog("go2shell: %@ → %@", terminal.displayName, directory.path)

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/open")
        process.arguments = ["-a", terminal.appPath, directory.path]
        let errors = Pipe()
        process.standardError = errors
        try process.run()
        let output = errors.fileHandleForReading.readDataToEndOfFile()
        process.waitUntilExit()
        if process.terminationStatus != 0 {
            throw NSError(domain: "go2shell.open", code: Int(process.terminationStatus),
                          userInfo: [NSLocalizedDescriptionKey: String(decoding: output, as: UTF8.self)])
        }
    }
}
