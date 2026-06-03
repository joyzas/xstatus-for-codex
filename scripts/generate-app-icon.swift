#!/usr/bin/env swift

import AppKit
import Foundation

private struct IconChunk {
    let code: String
    let size: Int
}

private let chunks: [IconChunk] = [
    IconChunk(code: "icp4", size: 16),
    IconChunk(code: "icp5", size: 32),
    IconChunk(code: "icp6", size: 64),
    IconChunk(code: "ic07", size: 128),
    IconChunk(code: "ic08", size: 256),
    IconChunk(code: "ic09", size: 512),
    IconChunk(code: "ic10", size: 1024),
]

private func point(_ value: CGFloat, _ scale: CGFloat) -> CGFloat {
    value * scale
}

private func roundedRect(_ rect: NSRect, radius: CGFloat) -> NSBezierPath {
    NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius)
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
        bitmapFormat: [.alphaFirst],
        bytesPerRow: 0,
        bitsPerPixel: 0
    ) else {
        throw NSError(domain: "IconGeneration", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to create bitmap"])
    }
    return bitmap
}

private func drawIcon(size: Int) throws -> Data {
    let dimension = CGFloat(size)
    let scale = dimension / 1024.0
    let bitmap = try makeBitmap(width: size, height: size)

    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)
    defer { NSGraphicsContext.restoreGraphicsState() }

    NSColor.clear.setFill()
    NSRect(x: 0, y: 0, width: dimension, height: dimension).fill()
    NSGraphicsContext.current?.imageInterpolation = .high

    let outerRect = NSRect(
        x: point(26, scale),
        y: point(26, scale),
        width: point(972, scale),
        height: point(972, scale)
    )
    let outerPath = roundedRect(outerRect, radius: point(198, scale))

    NSGraphicsContext.saveGraphicsState()
    let outerShadow = NSShadow()
    outerShadow.shadowColor = NSColor(calibratedRed: 0.30, green: 0.56, blue: 0.86, alpha: 0.20)
    outerShadow.shadowBlurRadius = point(26, scale)
    outerShadow.shadowOffset = NSSize(width: 0, height: -point(8, scale))
    outerShadow.set()

    let outerGradient = NSGradient(colors: [
        NSColor(calibratedRed: 0.98, green: 1.00, blue: 1.00, alpha: 1.00),
        NSColor(calibratedRed: 0.74, green: 0.89, blue: 1.00, alpha: 1.00),
        NSColor(calibratedRed: 0.48, green: 0.74, blue: 0.98, alpha: 1.00),
    ])!
    outerGradient.draw(in: outerPath, angle: -38)
    NSGraphicsContext.restoreGraphicsState()

    NSColor(calibratedWhite: 1.0, alpha: 0.92).setStroke()
    outerPath.lineWidth = max(1.0, point(7, scale))
    outerPath.stroke()

    let glowPath = roundedRect(
        NSRect(x: point(70, scale), y: point(74, scale), width: point(884, scale), height: point(884, scale)),
        radius: point(166, scale)
    )
    NSColor(calibratedWhite: 1.0, alpha: 0.18).setStroke()
    glowPath.lineWidth = max(1.0, point(20, scale))
    glowPath.stroke()

    let cardRect = NSRect(
        x: point(170, scale),
        y: point(304, scale),
        width: point(684, scale),
        height: point(402, scale)
    )
    let cardPath = roundedRect(cardRect, radius: point(86, scale))

    NSGraphicsContext.saveGraphicsState()
    let cardShadow = NSShadow()
    cardShadow.shadowColor = NSColor(calibratedRed: 0.28, green: 0.52, blue: 0.78, alpha: 0.28)
    cardShadow.shadowBlurRadius = point(30, scale)
    cardShadow.shadowOffset = NSSize(width: 0, height: -point(10, scale))
    cardShadow.set()

    let cardGradient = NSGradient(colors: [
        NSColor(calibratedRed: 0.99, green: 1.00, blue: 1.00, alpha: 0.96),
        NSColor(calibratedRed: 0.84, green: 0.94, blue: 1.00, alpha: 0.92),
    ])!
    cardGradient.draw(in: cardPath, angle: -20)
    NSGraphicsContext.restoreGraphicsState()

    NSColor(calibratedWhite: 1.0, alpha: 0.84).setStroke()
    cardPath.lineWidth = max(1.0, point(6, scale))
    cardPath.stroke()

    let dotRect = NSRect(
        x: point(258, scale),
        y: point(510, scale),
        width: point(76, scale),
        height: point(76, scale)
    )
    NSGraphicsContext.saveGraphicsState()
    let dotShadow = NSShadow()
    dotShadow.shadowColor = NSColor(calibratedRed: 0.08, green: 0.42, blue: 1.0, alpha: 0.38)
    dotShadow.shadowBlurRadius = point(18, scale)
    dotShadow.shadowOffset = .zero
    dotShadow.set()
    NSColor(calibratedRed: 0.10, green: 0.43, blue: 1.00, alpha: 1.00).setFill()
    NSBezierPath(ovalIn: dotRect).fill()
    NSGraphicsContext.restoreGraphicsState()

    let lineColor = NSColor(calibratedRed: 0.45, green: 0.62, blue: 0.80, alpha: 0.74)
    lineColor.setFill()
    roundedRect(
        NSRect(x: point(414, scale), y: point(544, scale), width: point(340, scale), height: point(40, scale)),
        radius: point(20, scale)
    ).fill()
    roundedRect(
        NSRect(x: point(414, scale), y: point(482, scale), width: point(220, scale), height: point(34, scale)),
        radius: point(17, scale)
    ).fill()

    NSColor(calibratedRed: 0.62, green: 0.78, blue: 0.94, alpha: 0.40).setFill()
    roundedRect(
        NSRect(x: point(245, scale), y: point(376, scale), width: point(596, scale), height: point(36, scale)),
        radius: point(18, scale)
    ).fill()

    NSColor(calibratedRed: 0.13, green: 0.47, blue: 1.00, alpha: 0.88).setFill()
    roundedRect(
        NSRect(x: point(245, scale), y: point(376, scale), width: point(372, scale), height: point(36, scale)),
        radius: point(18, scale)
    ).fill()

    guard let png = bitmap.representation(using: .png, properties: [:]) else {
        throw NSError(domain: "IconGeneration", code: 2, userInfo: [NSLocalizedDescriptionKey: "Unable to encode PNG"])
    }
    return png
}

private func appendBigEndianUInt32(_ value: Int, to data: inout Data) {
    var number = UInt32(value).bigEndian
    withUnsafeBytes(of: &number) { data.append(contentsOf: $0) }
}

private func makeICNS() throws -> Data {
    var body = Data()

    for chunk in chunks {
        let png = try drawIcon(size: chunk.size)
        body.append(chunk.code.data(using: .ascii)!)
        appendBigEndianUInt32(png.count + 8, to: &body)
        body.append(png)
    }

    var output = Data("icns".utf8)
    appendBigEndianUInt32(body.count + 8, to: &output)
    output.append(body)
    return output
}

let outputPath = CommandLine.arguments.dropFirst().first ?? "Resources/AppIcon.icns"
let outputURL = URL(fileURLWithPath: outputPath)
try FileManager.default.createDirectory(at: outputURL.deletingLastPathComponent(), withIntermediateDirectories: true)
try makeICNS().write(to: outputURL, options: .atomic)
print(outputURL.path)
