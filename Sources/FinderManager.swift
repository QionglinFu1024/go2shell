import Cocoa

struct FinderContext {
    let directory: URL
    let selectedItem: URL?

    var isApplicationSelected: Bool {
        guard let selectedItem else { return false }
        return selectedItem.resolvingSymlinksInPath().standardizedFileURL.path
            == Bundle.main.bundleURL.resolvingSymlinksInPath().standardizedFileURL.path
    }
}

enum FinderManager {
    @MainActor
    static func currentContext() throws -> FinderContext {
        // Ask Finder for both selection and window in the same event context.
        let source = """
        tell application "Finder"
            set chosenItems to selection
            if chosenItems is not {} then
                set chosenItem to item 1 of chosenItems
                set selectedPath to POSIX path of (chosenItem as alias)
                if class of chosenItem is folder or class of chosenItem is disk then
                    return {selectedPath, selectedPath}
                end if
                return {POSIX path of ((container of chosenItem) as alias), selectedPath}
            end if
            if (count of Finder windows) > 0 then
                return {POSIX path of ((target of front Finder window) as alias)}
            end if
            return {POSIX path of (path to desktop folder)}
        end tell
        """
        var error: NSDictionary?
        let result = NSAppleScript(source: source)?.executeAndReturnError(&error)
        guard let path = result?.atIndex(1)?.stringValue,
              !path.isEmpty else {
            let message = error?[NSAppleScript.errorMessage] as? String
                ?? NSLocalizedString("finder.path_error", comment: "")
            throw NSError(domain: "go2shell.Finder", code: error?[NSAppleScript.errorNumber] as? Int ?? -1,
                          userInfo: [NSLocalizedDescriptionKey: message])
        }
        let selectedItem = result?.atIndex(2)?.stringValue.map { URL(fileURLWithPath: $0) }
        return FinderContext(directory: URL(fileURLWithPath: path, isDirectory: true), selectedItem: selectedItem)
    }
}
