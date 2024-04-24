// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "VKParser",
    platforms: [
        .iOS(.v15),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "VKParser",
            targets: ["VKParser"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/marmelroy/Zip.git",
            .upToNextMinor(from: "2.1.2")
        ),
        .package(
            url: "https://github.com/apple/swift-argument-parser",
            from: "1.2.3"
        ),
        .package(
            url: "https://github.com/crossroadlabs/Regex",
            from: "1.2.0"
        ),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "VKParser",
            dependencies: [
                .product(name: "Zip", package: "Zip"),
                .product(name: "Regex", package: "Regex"),
                .product(name: "Logging", package: "swift-log"),
            ],
            swiftSettings: [
                .unsafeFlags(
                    ["-cross-module-optimization"],
                    .when(configuration: .release)
                )
            ]
        ),
        .executableTarget(
            name: "parse",
            dependencies: [
                .product(
                    name: "ArgumentParser",
                    package: "swift-argument-parser"
                ),
                .target(name: "VKParser"),
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "VKParserTests",
            dependencies: ["VKParser"]),
    ]
)
