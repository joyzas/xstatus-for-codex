import AppKit
import Darwin
import Foundation

@MainActor
final class StatusStore: ObservableObject {
    @Published private(set) var snapshot: StatusSnapshot = .idle
    @Published private(set) var lastReadError: String?

    let statusFileURL: URL
    private var fallbackTimer: Timer?
    private var statusDirectoryWatcher: DispatchSourceFileSystemObject?
    private var refreshWorkItem: DispatchWorkItem?
    private let decoder = JSONDecoder()

    init(statusFileURL: URL = StatusStore.defaultStatusFileURL) {
        self.statusFileURL = statusFileURL
        bootstrapStatusFileIfNeeded()
        refresh()
        startWatchingStatusDirectory()
    }

    static var defaultStatusFileURL: URL {
        FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".codex/status-widget/status.json")
    }

    func refresh() {
        do {
            let data = try Data(contentsOf: statusFileURL)
            let decoded = try decoder.decode(StatusSnapshot.self, from: data)
            if decoded != snapshot {
                snapshot = decoded
            }
            lastReadError = nil
        } catch {
            lastReadError = error.localizedDescription
        }
    }

    func revealStatusFile() {
        NSWorkspace.shared.activateFileViewerSelecting([statusFileURL])
    }

    private func startWatchingStatusDirectory() {
        let directory = statusFileURL.deletingLastPathComponent()
        let descriptor = open(directory.path, O_EVTONLY)

        guard descriptor >= 0 else {
            startFallbackPolling()
            return
        }

        let source = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: descriptor,
            eventMask: [.write, .extend, .attrib, .delete, .rename],
            queue: .main
        )

        source.setEventHandler { [weak self] in
            self?.scheduleDebouncedRefresh()
        }

        source.setCancelHandler {
            close(descriptor)
        }

        statusDirectoryWatcher = source
        source.resume()
    }

    private func scheduleDebouncedRefresh() {
        refreshWorkItem?.cancel()

        let workItem = DispatchWorkItem { [weak self] in
            Task { @MainActor in
                self?.refresh()
            }
        }

        refreshWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15, execute: workItem)
    }

    private func startFallbackPolling() {
        fallbackTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.refresh()
            }
        }
    }

    private func bootstrapStatusFileIfNeeded() {
        let fileManager = FileManager.default
        let directory = statusFileURL.deletingLastPathComponent()

        do {
            try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
            guard !fileManager.fileExists(atPath: statusFileURL.path) else {
                return
            }

            let data = try JSONEncoder.prettyPrinted.encode(StatusSnapshot.idle)
            try data.write(to: statusFileURL, options: .atomic)
        } catch {
            lastReadError = error.localizedDescription
        }
    }
}

private extension JSONEncoder {
    static var prettyPrinted: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return encoder
    }
}
