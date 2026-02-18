// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "IDGenerator",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(name: "IDGenerator", targets: ["IDGenerator"]),
        .library(name: "IDGeneratorDependency", targets: ["IDGeneratorDependency"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-concurrency-extras", from: "1.0.0"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "IDGenerator",
            dependencies: [
                .product(name: "ConcurrencyExtras", package: "swift-concurrency-extras"),
            ]
        ),
        .target(
            name: "IDGeneratorDependency",
            dependencies: [
                "IDGenerator",
                .product(name: "Dependencies", package: "swift-dependencies"),
            ]
        ),
        .testTarget(
            name: "IDGeneratorTests",
            dependencies: ["IDGenerator"]
        ),
        .testTarget(
            name: "IDGeneratorDependencyTests",
            dependencies: [
                "IDGeneratorDependency",
                .product(name: "Dependencies", package: "swift-dependencies"),
            ]
        )
    ]
)
