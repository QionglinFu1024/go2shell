// swift-tools-version: 6.3
import PackageDescription

let package = Package(
    name: "go2shell",
    platforms: [
        .macOS(.v15)
    ],
    products: [
        .executable(
            name: "go2shell",
            targets: ["go2shell"]
        )
    ],
    targets: [
        .executableTarget(
            name: "go2shell",
            path: "Sources"
        )
    ]
)
