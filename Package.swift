// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "JSONTrimmer",
    platforms: [.macOS(.v10_15)],
    products: [
        .executable(name: "jt", targets: ["JSONTrimmerCore"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.0"),
        .package(url: "https://github.com/pointfreeco/swift-parsing", from: "0.11.0"),
    ],
    targets: [
        .executableTarget(
            name: "JSONTrimmerCore",
            dependencies: [
                .product(name: "Parsing", package: "swift-parsing"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
        .testTarget(
            name: "JSONTrimmerCoreTests",
            dependencies: [
                "JSONTrimmerCore"
            ]
        ),
    ]
)
