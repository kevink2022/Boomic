// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Repository",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Repository",
            targets: ["Repository"]),
    ],
    dependencies: [
        .package(url: "./Domain", from: "1.0.0"),
        .package(url: "./Models", from: "1.0.0"),
        .package(url: "./Storage", from: "1.0.0"),
        .package(url: "./Database", from: "1.0.0"),
        .package(url: "./MediaFileKit", from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Repository",
            dependencies: [
                "Domain",
                "Models",
                "Storage",
                "Database",
                "MediaFileKit"]),
        .testTarget(
            name: "RepositoryTests",
            dependencies: ["Repository"]),
    ]
)
