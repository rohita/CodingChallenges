// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CodingChallenges",
    platforms: [.macOS(.v13)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "CodingChallenges",
            targets: ["CodingChallenges"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-collections.git", .upToNextMinor(from: "1.1.0")),
        .package(url: "https://github.com/rohita/swift-sly.git", branch: "main")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "CodingChallenges",
            dependencies: [
              .product(name: "Collections", package: "swift-collections"),
              .product(name: "SwiftSly", package: "swift-sly")
            ]
        ),
        .testTarget(
            name: "CodingChallengesTests",
            dependencies: ["CodingChallenges"]),
    ]
)
