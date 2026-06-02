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
    let panelPath = roundedRect(rect, radius: 34)

    NSGraphicsContext.saveGraphicsState()
    let shadow = NSShadow()
    shadow.shadowColor = NSColor(calibratedRed: 0.10, green: 0.20, blue: 0.34, alpha: 0.18)
    shadow.shadowBlurRadius = 34
    shadow.shadowOffset = NSSize(width: 0, height: -16)
    shadow.set()
    NSColor(calibratedRed: 0.90, green: 0.96, blue: 1.00, alpha: 0.92).setFill()
    panelPath.fill()
    NSGraphicsContext.restoreGraphicsState()

    NSColor(calibratedWhite: 1.0, alpha: 0.88).setStroke()
    panelPath.lineWidth = 2
    panelPath.stroke()

    let accent = NSColor(calibratedRed: 0.13, green: 0.43, blue: 1.00, alpha: 1.0)
    let muted = NSColor(calibratedRed: 0.42, green: 0.54, blue: 0.66, alpha: 0.78)
    let softLine = NSColor(calibratedRed: 0.55, green: 0.72, blue: 0.88, alpha: 0.42)

    accent.setFill()
    NSBezierPath(ovalIn: NSRect(x: rect.minX + 58, y: rect.maxY - 94, width: 28, height: 28)).fill()

    drawText(
        "运行中",
        in: NSRect(x: rect.minX + 112, y: rect.maxY - 108, width: 180, height: 42),
        font: .systemFont(ofSize: 31, weight: .semibold),
        color: NSColor(calibratedRed: 0.18, green: 0.23, blue: 0.29, alpha: 0.86)
    )

    drawText(
        "Codex 正在工作",
        in: NSRect(x: rect.minX + 58, y: rect.maxY - 182, width: rect.width - 116, height: 52),
        font: .systemFont(ofSize: 37, weight: .bold),
        color: NSColor(calibratedRed: 0.16, green: 0.20, blue: 0.26, alpha: 0.92)
    )

    drawText(
        "检测到任务活动",
        in: NSRect(x: rect.minX + 58, y: rect.maxY - 236, width: rect.width - 116, height: 40),
        font: .systemFont(ofSize: 27, weight: .medium),
        color: muted
    )

    softLine.setFill()
    roundedRect(NSRect(x: rect.minX + 58, y: rect.maxY - 282, width: rect.width - 116, height: 14), radius: 7).fill()
    accent.withAlphaComponent(0.70).setFill()
    roundedRect(NSRect(x: rect.minX + 58, y: rect.maxY - 282, width: (rect.width - 116) * 0.46, height: 14), radius: 7).fill()

    let projectRect = NSRect(x: rect.minX + 58, y: rect.minY + 30, width: rect.width - 270, height: 48)
    NSColor(calibratedWhite: 1.0, alpha: 0.46).setFill()
    roundedRect(projectRect, radius: 18).fill()
    drawText(
        "codex桌面小窗 · xStatus for Codex",
        in: NSRect(x: projectRect.minX + 24, y: projectRect.minY + 10, width: projectRect.width - 48, height: 30),
        font: .systemFont(ofSize: 22, weight: .medium),
        color: muted
    )

    drawText(
        "刚刚更新",
        in: NSRect(x: rect.maxX - 190, y: rect.minY + 38, width: 132, height: 30),
        font: .systemFont(ofSize: 21, weight: .medium),
        color: muted,
        alignment: .right
    )
}

let bitmap = try makeBitmap(width: width, height: height)
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)
defer { NSGraphicsContext.restoreGraphicsState() }

let canvas = NSRect(x: 0, y: 0, width: width, height: height)
let background = NSGradient(colors: [
    NSColor(calibratedRed: 0.95, green: 0.98, blue: 1.00, alpha: 1.0),
    NSColor(calibratedRed: 0.82, green: 0.92, blue: 1.00, alpha: 1.0),
    NSColor(calibratedRed: 0.97, green: 0.98, blue: 1.00, alpha: 1.0),
])!
background.draw(in: canvas, angle: -24)

NSColor(calibratedWhite: 1.0, alpha: 0.35).setFill()
roundedRect(NSRect(x: 60, y: 58, width: 1480, height: 604), radius: 46).fill()

drawIcon(in: NSRect(x: 158, y: 252, width: 216, height: 216))

drawText(
    "xStatus for Codex",
    in: NSRect(x: 142, y: 196, width: 520, height: 62),
    font: .systemFont(ofSize: 52, weight: .bold),
    color: NSColor(calibratedRed: 0.14, green: 0.22, blue: 0.34, alpha: 0.95)
)
drawText(
    "A lightweight macOS status widget for Codex.",
    in: NSRect(x: 146, y: 154, width: 560, height: 34),
    font: .systemFont(ofSize: 24, weight: .medium),
    color: NSColor(calibratedRed: 0.36, green: 0.48, blue: 0.60, alpha: 0.88)
)

drawMockPanel(in: NSRect(x: 712, y: 178, width: 710, height: 364))

guard let png = bitmap.representation(using: .png, properties: [:]) else {
    throw NSError(domain: "BannerGeneration", code: 2, userInfo: [NSLocalizedDescriptionKey: "Unable to encode PNG"])
}

let outputURL = URL(fileURLWithPath: outputPath)
try FileManager.default.createDirectory(at: outputURL.deletingLastPathComponent(), withIntermediateDirectories: true)
try png.write(to: outputURL, options: .atomic)
print(outputURL.path)
