// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "gobii-client-swift",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "gobii-client-swift",
            targets: ["gobii-client-swift"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "gobii-client-swift"),
        .testTarget(
            name: "gobii-client-swiftTests",
            dependencies: ["gobii-client-swift"]
        ),
    ]
)
