// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "gpx-swift",
    platforms: [
        .iOS(.v26),
        .macOS(.v26),
        .tvOS(.v26),
        .visionOS(.v26),
    ],
    products: [
        .library(name: "GPXSwift", targets: ["GPXSwift"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "GPXSwift",
            dependencies: [],
        ),
        .testTarget(
            name: "GPXSwiftTests",
            dependencies: ["GPXSwift"],
            resources: [.copy("Fixtures")],
        ),
    ]
)
