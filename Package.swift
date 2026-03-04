// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "TermKit",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "TermKit",
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "TermKitTests",
            dependencies: ["TermKit"]
        ),
    ]
)
