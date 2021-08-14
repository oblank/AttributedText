// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AttributedText",
    platforms: [
        .macOS(.v10_12),
        .iOS(.v11),
        .tvOS(.v11),
    ],
    products: [
        .library(
            name: "AttributedText",
            targets: ["AttributedText"]
        ),
    ],
    dependencies: [
        .package(
            name: "Lightbox",
            url: "https://github.com/hyperoslo/Lightbox",
            .branch("master")
        ),
        .package(
            name: "SnapshotTesting",
            url: "https://github.com/pointfreeco/swift-snapshot-testing",
            from: "1.8.2"
        ),
    ],
    targets: [
        .target(
            name: "AttributedText",
            dependencies: ["Lightbox"]
        ),
        .testTarget(
            name: "AttributedTextTests",
            dependencies: ["AttributedText", "SnapshotTesting"],
            exclude: ["__Snapshots__"]
        ),
    ]
)
