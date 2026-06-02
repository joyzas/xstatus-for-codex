import AppKit

final class StatusPanel: NSPanel {
    init(contentRect: NSRect) {
        super.init(
            contentRect: contentRect,
            styleMask: [.borderless, .nonactivatingPanel, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        isFloatingPanel = true
        canHide = false
        collectionBehavior = [.canJoinAllSpaces, .stationary]
        level = .floating
        isOpaque = false
        backgroundColor = .clear
        hasShadow = true
        isMovableByWindowBackground = true
        hidesOnDeactivate = false
        titleVisibility = .hidden
        titlebarAppearsTransparent = true
    }

    override var canBecomeKey: Bool {
        true
    }

    override var canBecomeMain: Bool {
        true
    }

    func centerOnVisibleDesktop() {
        guard let screenFrame = NSScreen.main?.visibleFrame else {
            center()
            return
        }

        let origin = NSPoint(
            x: screenFrame.maxX - frame.width - 28,
            y: screenFrame.maxY - frame.height - 34
        )
        setFrameOrigin(origin)
    }
}
