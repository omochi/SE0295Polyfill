// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "SE0295Polyfill",
    products: [
        .library(
            name: "SE0295Polyfill",
            targets: ["SE0295Polyfill"]
        ),
        .executable(
            name: "se0295",
            targets: ["se0295"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/omochi/SwiftTypeReader", .branch("main"))
    ],
    targets: [
        .target(
            name: "SE0295Polyfill",
            dependencies: [
                .product(name: "SwiftTypeReader", package: "SwiftTypeReader")
            ]
        ),
        .testTarget(
            name: "SE0295PolyfillTests",
            dependencies: ["SE0295Polyfill"],
            exclude: ["Resources"]
        ),
        .target(
            name: "se0295",
            dependencies: [
                "SE0295Polyfill"
            ]
        )
    ]
)
