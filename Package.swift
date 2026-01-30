// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ClipStack",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(
            name: "ClipStack",
            targets: ["ClipStack"]
        )
    ],
    dependencies: [
        // Add dependencies here if needed
    ],
    targets: [
        .executableTarget(
            name: "ClipStack",
            dependencies: [],
            path: "ClipStack/Sources"
        ),
        .testTarget(
            name: "ClipStackTests",
            dependencies: ["ClipStack"],
            path: "ClipStack/Tests"
        )
    ]
)