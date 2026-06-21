// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Helix",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "Helix", targets: ["Helix"])
    ],
    targets: [
        .executableTarget(
            name: "Helix",
            path: "src"
        )
    ]
)
