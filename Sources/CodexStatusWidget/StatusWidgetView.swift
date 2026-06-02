import SwiftUI

struct StatusWidgetView: View {
    @ObservedObject var store: StatusStore
    var onHide: () -> Void
    var onQuit: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            statusBadge

            VStack(alignment: .leading, spacing: 7) {
                header
                content
                footer
            }
        }
        .padding(.top, 14)
        .padding(.bottom, 15)
        .padding(.leading, 14)
        .padding(.trailing, 16)
        .frame(width: 360, height: 138)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color.white.opacity(0.30), lineWidth: 0.8)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .contentShape(Rectangle())
    }

    private var statusBadge: some View {
        ZStack {
            Circle()
                .fill(store.snapshot.phase.accent.opacity(0.16))
                .frame(width: 34, height: 34)

            Circle()
                .fill(store.snapshot.phase.accent)
                .frame(width: 13, height: 13)
                .shadow(color: store.snapshot.phase.accent.opacity(0.50), radius: 5)
        }
        .accessibilityLabel(store.snapshot.phase.label)
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 8) {
            Text(store.snapshot.phase.label)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.secondary)
                .lineLimit(1)

            Spacer()

            Button {
                store.refresh()
            } label: {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 12, weight: .medium))
            }
            .buttonStyle(NotificationIconButtonStyle())
            .help("刷新状态")

            Button {
                store.revealStatusFile()
            } label: {
                Image(systemName: "doc.text.magnifyingglass")
                    .font(.system(size: 12, weight: .medium))
            }
            .buttonStyle(NotificationIconButtonStyle())
            .help("查看状态文件")

            Button {
                onHide()
            } label: {
                Image(systemName: "eye.slash")
                    .font(.system(size: 12, weight: .medium))
            }
            .buttonStyle(NotificationIconButtonStyle())
            .help("隐藏浮窗")

            Button {
                onQuit()
            } label: {
                Image(systemName: "xmark.circle")
                    .font(.system(size: 12, weight: .medium))
            }
            .buttonStyle(NotificationIconButtonStyle())
            .help("退出小组件")
        }
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(store.snapshot.title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .fixedSize(horizontal: false, vertical: true)

            if let detail = store.snapshot.detail, !detail.isEmpty {
                Text(detail)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if let progress = store.snapshot.progress {
                ProgressView(value: min(max(progress, 0), 1))
                    .tint(store.snapshot.phase.accent)
                    .controlSize(.small)
                    .frame(height: 4)
                    .padding(.top, 2)
                    .padding(.trailing, 2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var footer: some View {
        HStack(spacing: 8) {
            if let workspace = store.snapshot.workspace, !workspace.isEmpty {
                Label(workspace, systemImage: "folder")
                    .lineLimit(1)
            } else {
                Label("Codex", systemImage: "terminal")
            }

            Spacer()

            Text(relativeUpdateText)
                .lineLimit(1)
        }
        .font(.system(size: 11, weight: .medium))
        .foregroundStyle(.secondary)
        .padding(.top, 1)
    }

    private var relativeUpdateText: String {
        guard let date = ISO8601DateFormatter().date(from: store.snapshot.updatedAt) else {
            return "刚刚更新"
        }

        let seconds = Int(Date().timeIntervalSince(date))
        if seconds < 60 {
            return "刚刚更新"
        }

        let minutes = seconds / 60
        if minutes < 60 {
            return "\(minutes) 分钟前更新"
        }

        let hours = minutes / 60
        if hours < 24 {
            return "\(hours) 小时前更新"
        }

        let days = hours / 24
        return "\(days) 天前更新"
    }
}

private struct NotificationIconButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.secondary)
            .frame(width: 22, height: 22)
            .background(
                Circle()
                    .fill(configuration.isPressed ? Color.primary.opacity(0.12) : Color.clear)
            )
            .contentShape(Circle())
    }
}
