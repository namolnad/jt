// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "JSONTrimmer",
    platforms: [.macOS(.v10_15)],
    products: [
        .executable(name: "json-trimmer", targets: ["JSONTrimmer"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.0"),
        .package(url: "https://github.com/pointfreeco/swift-parsing", from: "0.11.0"),
    ],
    targets: [
        .executableTarget(
            name: "JSONTrimmer",
            dependencies: [
                .product(name: "Parsing", package: "swift-parsing"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
        .testTarget(
            name: "JSONTrimmerTests",
            dependencies: [.target(name: "JSONTrimmer")]
        ),
    ]
)
