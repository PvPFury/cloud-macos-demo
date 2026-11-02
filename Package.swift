// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "CloudMacDemo",
    platforms: [
        .macOS(.v13)
    ],
    targets: [
        .executableTarget(
            name: "CloudMacDemo",
            path: "Sources/CloudMacDemo"
        )
    ]
)
