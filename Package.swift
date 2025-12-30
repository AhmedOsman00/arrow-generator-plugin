// swift-tools-version:6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ArrowGeneratorPlugin",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .plugin(
            name: "ArrowGeneratorPlugin",
            targets: ["ArrowGeneratorPlugin"]
        ),
        .library(
            name: "ArrowGeneratorPluginSupport",
            targets: ["ArrowGeneratorPluginSupport"]
        )
    ],
    targets: [
        .target(
            name: "ArrowGeneratorPluginSupport",
            path: "Sources/Support"
        ),
        .plugin(
            name: "ArrowGeneratorPlugin",
            capability: .command(
                intent: .custom(verb: "arrow-generator", description: "Generate dependency injection container code"),
                permissions: [
                    .writeToPackageDirectory(reason: "Generates dependencies.generated.swift file in package sources")
                ]
            )
        ),
    ]
)
