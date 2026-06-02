import Foundation
import SwiftUI

enum TaskPhase: String, Codable {
    case idle
    case running
    case waiting
    case failed
    case completed
    case unknown

    init(rawValue: String) {
        switch rawValue.lowercased() {
        case "idle":
            self = .idle
        case "running", "in_progress", "working":
            self = .running
        case "waiting", "needs_input", "approval", "blocked":
            self = .waiting
        case "failed", "error":
            self = .failed
        case "completed", "complete", "done", "success":
            self = .completed
        default:
            self = .unknown
        }
    }

    var label: String {
        switch self {
        case .idle:
            "空闲"
        case .running:
            "运行中"
        case .waiting:
            "等待确认"
        case .failed:
            "失败"
        case .completed:
            "已完成"
        case .unknown:
            "未知"
        }
    }

    var menuSymbol: String {
        switch self {
        case .idle:
            "○"
        case .running:
            "●"
        case .waiting:
            "◐"
        case .failed:
            "×"
        case .completed:
            "✓"
        case .unknown:
            "?"
        }
    }

    var accent: Color {
        switch self {
        case .idle:
            Color(red: 0.48, green: 0.52, blue: 0.57)
        case .running:
            Color(red: 0.18, green: 0.45, blue: 0.92)
        case .waiting:
            Color(red: 0.93, green: 0.62, blue: 0.16)
        case .failed:
            Color(red: 0.86, green: 0.22, blue: 0.24)
        case .completed:
            Color(red: 0.14, green: 0.62, blue: 0.42)
        case .unknown:
            Color(red: 0.50, green: 0.34, blue: 0.72)
        }
    }
}

struct StatusSnapshot: Codable, Equatable {
    var status: String
    var title: String
    var detail: String?
    var workspace: String?
    var progress: Double?
    var updatedAt: String

    var phase: TaskPhase {
        TaskPhase(rawValue: status)
    }

    static let idle = StatusSnapshot(
        status: "idle",
        title: "Codex 当前空闲",
        detail: "暂无正在执行的任务",
        workspace: nil,
        progress: nil,
        updatedAt: ISO8601DateFormatter().string(from: Date())
    )
}
