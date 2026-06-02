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

private func drawIcon(size: Int) throws -> Data {
    let dimension = CGFloat(size)
    let scale = dimension / 1024.0
    guard let bitmap = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: size,
        pixelsHigh: size,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bitmapFormat: [],
        bytesPerRow: 0,
        bitsPerPixel: 0
    ) else {
        throw NSError(domain: "IconGeneration", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to create bitmap"])
    }

    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)
    defer { NSGraphicsContext.restoreGraphicsState() }

    NSColor.clear.setFill()
    NSRect(x: 0, y: 0, width: dimension, height: dimension).fill()
    NSGraphicsContext.current?.imageInterpolation = .high

    let outerRect = NSRect(
        x: point(118, scale),
        y: point(98, scale),
        width: point(788, scale),
        height: point(828, scale)
    )
    let outerPath = roundedRect(outerRect, radius: point(148, scale))

    NSGraphicsContext.saveGraphicsState()
    let outerShadow = NSShadow()
    outerShadow.shadowColor = NSColor(calibratedRed: 0.40, green: 0.62, blue: 0.90, alpha: 0.22)
    outerShadow.shadowBlurRadius = point(34, scale)
    outerShadow.shadowOffset = NSSize(width: 0, height: -point(10, scale))
    outerShadow.set()

    let outerGradient = NSGradient(colors: [
        NSColor(calibratedRed: 0.96, green: 0.99, blue: 1.00, alpha: 1.00),
        NSColor(calibratedRed: 0.73, green: 0.88, blue: 1.00, alpha: 1.00),
        NSColor(calibratedRed: 0.56, green: 0.76, blue: 0.96, alpha: 1.00),
    ])!
    outerGradient.draw(in: outerPath, angle: -35)
    NSGraphicsContext.restoreGraphicsState()

    NSColor(calibratedWhite: 1.0, alpha: 0.88).setStroke()
    outerPath.lineWidth = max(1.0, point(8, scale))
    outerPath.stroke()

    let innerRect = NSRect(
        x: point(230, scale),
        y: point(306, scale),
        width: point(564, scale),
        height: point(340, scale)
    )
    let innerPath = roundedRect(innerRect, radius: point(72, scale))

    NSGraphicsContext.saveGraphicsState()
    let cardShadow = NSShadow()
    cardShadow.shadowColor = NSColor(calibratedRed: 0.36, green: 0.58, blue: 0.82, alpha: 0.24)
    cardShadow.shadowBlurRadius = point(28, scale)
    cardShadow.shadowOffset = NSSize(width: 0, height: -point(8, scale))
    cardShadow.set()

    let cardGradient = NSGradient(colors: [
        NSColor(calibratedRed: 0.98, green: 1.00, blue: 1.00, alpha: 0.95),
        NSColor(calibratedRed: 0.83, green: 0.94, blue: 1.00, alpha: 0.92),
    ])!
    cardGradient.draw(in: innerPath, angle: -18)
    NSGraphicsContext.restoreGraphicsState()

    NSColor(calibratedWhite: 1.0, alpha: 0.82).setStroke()
    innerPath.lineWidth = max(1.0, point(5, scale))
    innerPath.stroke()

    let dotRect = NSRect(
        x: point(284, scale),
        y: point(470, scale),
        width: point(62, scale),
        height: point(62, scale)
    )
    NSGraphicsContext.saveGraphicsState()
    let dotShadow = NSShadow()
    dotShadow.shadowColor = NSColor(calibratedRed: 0.12, green: 0.45, blue: 1.0, alpha: 0.38)
    dotShadow.shadowBlurRadius = point(16, scale)
    dotShadow.shadowOffset = .zero
    dotShadow.set()
    NSColor(calibratedRed: 0.10, green: 0.43, blue: 1.00, alpha: 1.00).setFill()
    NSBezierPath(ovalIn: dotRect).fill()
    NSGraphicsContext.restoreGraphicsState()

    let lineColor = NSColor(calibratedRed: 0.46, green: 0.63, blue: 0.82, alpha: 0.72)
    lineColor.setFill()
    roundedRect(
        NSRect(x: point(398, scale), y: point(500, scale), width: point(310, scale), height: point(34, scale)),
        radius: point(17, scale)
    ).fill()
    roundedRect(
        NSRect(x: point(398, scale), y: point(452, scale), width: point(196, scale), height: point(30, scale)),
        radius: point(15, scale)
    ).fill()

    NSColor(calibratedRed: 0.61, green: 0.76, blue: 0.92, alpha: 0.38).setFill()
    roundedRect(
        NSRect(x: point(290, scale), y: point(370, scale), width: point(456, scale), height: point(30, scale)),
        radius: point(15, scale)
    ).fill()

    NSColor(calibratedRed: 0.13, green: 0.47, blue: 1.00, alpha: 0.88).setFill()
    roundedRect(
        NSRect(x: point(290, scale), y: point(370, scale), width: point(270, scale), height: point(30, scale)),
        radius: point(15, scale)
    ).fill()

    guard let png = bitmap.representation(using: .png, properties: [:]) else {
        throw NSError(domain: "IconGeneration", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to create PNG data"])
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
