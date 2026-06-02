#!/usr/bin/env swift

import AppKit
import Foundation

private let width = 1600
private let height = 720
private let outputPath = CommandLine.arguments.dropFirst().first ?? "Resources/READMEBanner.png"

private func roundedRect(_ rect: NSRect, radius: CGFloat) -> NSBezierPath {
    NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius)
}

private func drawText(_ text: String, in rect: NSRect, font: NSFont, color: NSColor, alignment: NSTextAlignment = .left) {
    let paragraph = NSMutableParagraphStyle()
    paragraph.alignment = alignment
    paragraph.lineBreakMode = .byTruncatingTail
    text.draw(
        in: rect,
        withAttributes: [
            .font: font,
            .foregroundColor: color,
            .paragraphStyle: paragraph,
        ]
    )
}

private func makeBitmap(width: Int, height: Int) throws -> NSBitmapImageRep {
    guard let bitmap = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: width,
        pixelsHigh: height,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bitmapFormat: [],
        bytesPerRow: 0,
        bitsPerPixel: 0
    ) else {
        throw NSError(domain: "BannerGeneration", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to create bitmap"])
    }
    return bitmap
}

private func drawIcon(in rect: NSRect) {
    guard let icon = NSImage(contentsOfFile: "Resources/AppIcon.icns") else {
        return
    }

    NSGraphicsContext.saveGraphicsState()
    let shadow = NSShadow()
    shadow.shadowColor = NSColor(calibratedRed: 0.20, green: 0.38, blue: 0.62, alpha: 0.20)
    shadow.shadowBlurRadius = 36
    shadow.shadowOffset = NSSize(width: 0, height: -12)
    shadow.set()
    icon.draw(in: rect, from: .zero, operation: .sourceOver, fraction: 1)
    NSGraphicsContext.restoreGraphicsState()
}

private func drawMockPanel(in rect: NSRect) {
    let panelPath = roundedRect(rect, radius: 38)

    NSGraphicsContext.saveGraphicsState()
    let shadow = NSShadow()
    shadow.shadowColor = NSColor(calibratedRed: 0.10, green: 0.20, blue: 0.34, alpha: 0.18)
    shadow.shadowBlurRadius = 34
    shadow.shadowOffset = NSSize(width: 0, height: -16)
    shadow.set()
    NSColor(calibratedRed: 0.92, green: 0.97, blue: 1.00, alpha: 0.95).setFill()
    panelPath.fill()
    NSGraphicsContext.restoreGraphicsState()

    NSColor(calibratedWhite: 1.0, alpha: 0.88).setStroke()
    panelPath.lineWidth = 2
    panelPath.stroke()

    let accent = NSColor(calibratedRed: 0.13, green: 0.43, blue: 1.00, alpha: 1.0)
    let muted = NSColor(calibratedRed: 0.42, green: 0.54, blue: 0.66, alpha: 0.78)
    let softLine = NSColor(calibratedRed: 0.55, green: 0.72, blue: 0.88, alpha: 0.42)

    accent.setFill()
    NSBezierPath(ovalIn: NSRect(x: rect.minX + 64, y: rect.maxY - 102, width: 30, height: 30)).fill()

    drawText(
        "运行中",
        in: NSRect(x: rect.minX + 118, y: rect.maxY - 113, width: 180, height: 42),
        font: .systemFont(ofSize: 32, weight: .semibold),
        color: NSColor(calibratedRed: 0.18, green: 0.23, blue: 0.29, alpha: 0.86)
    )

    drawText(
        "Codex 正在工作",
        in: NSRect(x: rect.minX + 64, y: rect.maxY - 194, width: rect.width - 128, height: 58),
        font: .systemFont(ofSize: 40, weight: .bold),
        color: NSColor(calibratedRed: 0.16, green: 0.20, blue: 0.26, alpha: 0.92)
    )

    drawText(
        "检测到任务活动",
        in: NSRect(x: rect.minX + 64, y: rect.maxY - 252, width: rect.width - 128, height: 40),
        font: .systemFont(ofSize: 28, weight: .medium),
        color: muted
    )

    softLine.setFill()
    roundedRect(NSRect(x: rect.minX + 64, y: rect.minY + 86, width: rect.width - 128, height: 14), radius: 7).fill()
    accent.withAlphaComponent(0.70).setFill()
    roundedRect(NSRect(x: rect.minX + 64, y: rect.minY + 86, width: (rect.width - 128) * 0.46, height: 14), radius: 7).fill()
}

private func drawStatusChip(_ text: String, dotColor: NSColor, in rect: NSRect) {
    NSColor(calibratedWhite: 1.0, alpha: 0.58).setFill()
    roundedRect(rect, radius: rect.height / 2).fill()

    dotColor.setFill()
    NSBezierPath(ovalIn: NSRect(x: rect.minX + 20, y: rect.midY - 6, width: 12, height: 12)).fill()

    drawText(
        text,
        in: NSRect(x: rect.minX + 44, y: rect.minY + 11, width: rect.width - 58, height: 24),
        font: .systemFont(ofSize: 18, weight: .semibold),
        color: NSColor(calibratedRed: 0.24, green: 0.34, blue: 0.46, alpha: 0.82)
    )
}

let bitmap = try makeBitmap(width: width, height: height)
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)
defer { NSGraphicsContext.restoreGraphicsState() }

let canvas = NSRect(x: 0, y: 0, width: width, height: height)
let background = NSGradient(colors: [
    NSColor(calibratedRed: 0.98, green: 1.00, blue: 1.00, alpha: 1.0),
    NSColor(calibratedRed: 0.84, green: 0.93, blue: 1.00, alpha: 1.0),
    NSColor(calibratedRed: 0.91, green: 0.97, blue: 1.00, alpha: 1.0),
])!
background.draw(in: canvas, angle: -24)

NSColor(calibratedWhite: 1.0, alpha: 0.42).setFill()
roundedRect(NSRect(x: 70, y: 64, width: 1460, height: 592), radius: 52).fill()

drawIcon(in: NSRect(x: 158, y: 382, width: 180, height: 180))

drawText(
    "xStatus for Codex",
    in: NSRect(x: 150, y: 312, width: 560, height: 70),
    font: .systemFont(ofSize: 58, weight: .bold),
    color: NSColor(calibratedRed: 0.14, green: 0.22, blue: 0.34, alpha: 0.95)
)
drawText(
    "A lightweight macOS status widget for Codex.",
    in: NSRect(x: 154, y: 266, width: 570, height: 34),
    font: .systemFont(ofSize: 25, weight: .medium),
    color: NSColor(calibratedRed: 0.36, green: 0.48, blue: 0.60, alpha: 0.88)
)

drawStatusChip(
    "Running",
    dotColor: NSColor(calibratedRed: 0.13, green: 0.47, blue: 1.00, alpha: 1),
    in: NSRect(x: 154, y: 184, width: 146, height: 46)
)
drawStatusChip(
    "Waiting",
    dotColor: NSColor(calibratedRed: 0.72, green: 0.50, blue: 1.00, alpha: 1),
    in: NSRect(x: 318, y: 184, width: 144, height: 46)
)
drawStatusChip(
    "Done",
    dotColor: NSColor(calibratedRed: 0.16, green: 0.68, blue: 0.40, alpha: 1),
    in: NSRect(x: 480, y: 184, width: 116, height: 46)
)

drawMockPanel(in: NSRect(x: 790, y: 170, width: 660, height: 390))

guard let png = bitmap.representation(using: .png, properties: [:]) else {
    throw NSError(domain: "BannerGeneration", code: 2, userInfo: [NSLocalizedDescriptionKey: "Unable to encode PNG"])
}

let outputURL = URL(fileURLWithPath: outputPath)
try FileManager.default.createDirectory(at: outputURL.deletingLastPathComponent(), withIntermediateDirectories: true)
try png.write(to: outputURL, options: .atomic)
print(outputURL.path)
