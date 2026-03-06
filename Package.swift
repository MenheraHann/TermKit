// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "TermKit",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "TermKit", targets: ["TermKit"])
    ],
    targets: [
        .executableTarget(name: "TermKit")
    ]
)
