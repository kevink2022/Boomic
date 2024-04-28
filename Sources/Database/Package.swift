// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Database",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Database",
            targets: ["Database"]),
        .library(
            name: "Storage",
            targets: ["Storage"]),
        .library(
            name: "DatabaseMocks",
            targets: ["DatabaseMocks"]),
    ],
    dependencies: [
        .package(url: "./Models", from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Database",
            dependencies: ["Models", "Storage"]),
        .target(
            name: "Storage",
            dependencies: ["Models"]),
        .target(
            name: "DatabaseMocks",
            dependencies: [
                "Database",
                .product(name: "ModelsMocks", package: "Models")
            ]),
        .testTarget(
            name: "DatabaseTests",
            dependencies: [
                "Database",
                .product(name: "ModelsMocks", package: "Models")
            ]),
        .testTarget(
            name: "StorageTests",
            dependencies: ["Storage"]),
    ]
)
