// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "SE0295Polyfill",
    products: [
        .library(
            name: "SE0295Polyfill",
            targets: ["SE0295Polyfill"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/omochi/SwiftTypeReader", .branch("main"))
    ],
    targets: [
        .target(
            name: "SE0295Polyfill",
            dependencies: [
                "SwiftTypeReader"
            ]
        ),
        .testTarget(
            name: "SE0295PolyfillTests",
            dependencies: ["SE0295Polyfill"],
            exclude: ["Resources"]
        ),
    ]
)
