// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "TermKit",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "TermKit", targets: ["TermKit"]),
        .executable(name: "opentk", targets: ["OpenTKCLI"])
    ],
    targets: [
        .executableTarget(
            name: "TermKit",
            exclude: ["CLI"],
            resources: [.process("Resources")]
        ),
        .executableTarget(
            name: "OpenTKCLI",
            path: "Sources/TermKit/CLI"
        ),
        .testTarget(
            name: "TermKitTests",
            dependencies: ["TermKit"]
        ),
    ]
)
