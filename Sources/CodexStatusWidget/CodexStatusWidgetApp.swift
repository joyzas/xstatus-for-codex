import AppKit
import Combine
import SwiftUI

@MainActor
final class CodexStatusWidgetApp: NSObject, NSApplicationDelegate {
    private enum DefaultsKey {
        static let showMenuStatusSymbol = "showMenuStatusSymbol"
    }

    private var panel: StatusPanel?
    private var statusItem: NSStatusItem?
    private var symbolMenuItem: NSMenuItem?
    private let store = StatusStore()
    private var cancellables = Set<AnyCancellable>()
    private var hideWorkItem: DispatchWorkItem?
    private var showMenuStatusSymbol: Bool {
        get {
            if UserDefaults.standard.object(forKey: DefaultsKey.showMenuStatusSymbol) == nil {
                return true
            }
            return UserDefaults.standard.bool(forKey: DefaultsKey.showMenuStatusSymbol)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: DefaultsKey.showMenuStatusSymbol)
        }
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        configureStatusItem()
        observeStatusChanges()
        showPanel(autoHide: true)
    }

    private func configureStatusItem() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        item.button?.image = nil
        item.button?.title = " Codex"
        item.button?.toolTip = "xStatus for Codex"

        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "显示浮窗", action: #selector(showPanelFromMenu), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "隐藏浮窗", action: #selector(hidePanelFromMenu), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "刷新状态", action: #selector(refreshFromMenu), keyEquivalent: "r"))
        let statusSymbolItem = NSMenuItem(title: "显示状态符号", action: #selector(toggleStatusSymbol), keyEquivalent: "")
        statusSymbolItem.state = showMenuStatusSymbol ? .on : .off
        menu.addItem(statusSymbolItem)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "退出", action: #selector(quit), keyEquivalent: "q"))
        item.menu = menu
        symbolMenuItem = statusSymbolItem
        statusItem = item
        updateMenuBarTitle(for: store.snapshot)
    }

    private func observeStatusChanges() {
        store.$snapshot
            .receive(on: RunLoop.main)
            .sink { [weak self] snapshot in
                self?.updateMenuBarTitle(for: snapshot)
            }
            .store(in: &cancellables)

        store.$snapshot
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.showPanel(autoHide: true)
            }
            .store(in: &cancellables)
    }

    private func updateMenuBarTitle(for snapshot: StatusSnapshot) {
        let symbol = showMenuStatusSymbol ? " \(snapshot.phase.menuSymbol)" : ""
        statusItem?.button?.title = " Codex：\(snapshot.phase.label)\(symbol)"
        symbolMenuItem?.state = showMenuStatusSymbol ? .on : .off
    }

    private func showPanel(autoHide: Bool) {
        if autoHide && FullScreenDetector.isFrontmostAppFullScreen() {
            hidePanel()
            return
        }

        if panel == nil {
            let content = StatusWidgetView(
                store: store,
                onHide: { [weak self] in self?.hidePanel() },
                onQuit: { NSApp.terminate(nil) }
            )
            let hostingView = NSHostingView(rootView: content)
            let newPanel = StatusPanel(contentRect: NSRect(x: 0, y: 0, width: 360, height: 138))
            newPanel.contentView = hostingView
            newPanel.centerOnVisibleDesktop()
            panel = newPanel
        }

        hideWorkItem?.cancel()
        panel?.orderFrontRegardless()

        if autoHide {
            scheduleAutoHide()
        }
    }

    private func scheduleAutoHide() {
        let workItem = DispatchWorkItem { [weak self] in
            Task { @MainActor in
                self?.hidePanel()
            }
        }
        hideWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: workItem)
    }

    private func hidePanel() {
        hideWorkItem?.cancel()
        hideWorkItem = nil
        panel?.orderOut(nil)
    }

    @objc private func showPanelFromMenu() {
        showPanel(autoHide: false)
    }

    @objc private func hidePanelFromMenu() {
        hidePanel()
    }

    @objc private func refreshFromMenu() {
        store.refresh()
        showPanel(autoHide: false)
    }

    @objc private func toggleStatusSymbol() {
        showMenuStatusSymbol.toggle()
        updateMenuBarTitle(for: store.snapshot)
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }
}
