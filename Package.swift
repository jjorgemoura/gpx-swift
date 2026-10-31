// swift-tools-version: 6.4
// Platform matrix: see platform/standards/platforms.md (PLAT-2). Trim per library.

import PackageDescription

let package = Package(
    name: "LibraryTemplate",
    platforms: [
        .iOS(.v26),
        .macOS(.v26),
    ],
    products: [
        .library(name: "LibraryTemplate", targets: ["LibraryTemplate"])
    ],
    targets: [
        .target(name: "LibraryTemplate"),
        .testTarget(
            name: "LibraryTemplateTests",
            dependencies: ["LibraryTemplate"],
            resources: [.copy("Fixtures")]
        ),
    ]
)
