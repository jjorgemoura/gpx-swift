// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "LibraryTemplate",
    platforms: [
        .iOS(.v26),
        .macOS(.v26),
    ],
    products: [
        .library(name: "GPXSwift", targets: ["GPXSwift"])
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "GPXSwift",
            dependencies: [],
        ),
        .testTarget(
            name: "GPXSwiftTests",
            dependencies: ["GPXSwift"],
        ),
    ]
)
