import AppKit
import CoreGraphics

enum FullScreenDetector {
    static func isFrontmostAppFullScreen() -> Bool {
        guard
            let frontmostApp = NSWorkspace.shared.frontmostApplication,
            let screenFrame = NSScreen.main?.frame
        else {
            return false
        }

        let options: CGWindowListOption = [.optionOnScreenOnly, .excludeDesktopElements]
        guard let windowList = CGWindowListCopyWindowInfo(options, kCGNullWindowID) as? [[String: Any]] else {
            return false
        }

        return windowList.contains { window in
            guard
                let ownerPID = window[kCGWindowOwnerPID as String] as? pid_t,
                ownerPID == frontmostApp.processIdentifier,
                let layer = window[kCGWindowLayer as String] as? Int,
                layer == 0,
                let bounds = window[kCGWindowBounds as String] as? [String: Any],
                let x = bounds["X"] as? CGFloat,
                let y = bounds["Y"] as? CGFloat,
                let width = bounds["Width"] as? CGFloat,
                let height = bounds["Height"] as? CGFloat
            else {
                return false
            }

            let windowFrame = CGRect(x: x, y: y, width: width, height: height)
            return windowFrame.nearlyMatches(screenFrame)
        }
    }
}

private extension CGRect {
    func nearlyMatches(_ other: CGRect) -> Bool {
        abs(minX - other.minX) <= 2 &&
            abs(minY - other.minY) <= 2 &&
            abs(width - other.width) <= 4 &&
            abs(height - other.height) <= 4
    }
}
