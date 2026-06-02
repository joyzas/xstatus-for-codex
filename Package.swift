// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "CodexStatusWidget",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "CodexStatusWidget", targets: ["CodexStatusWidget"])
    ],
    targets: [
        .executableTarget(
            name: "CodexStatusWidget",
            path: "Sources/CodexStatusWidget"
        )
    ]
)
