// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DataLiteCore",
    platforms: [
        .macOS(.v10_14),
        .iOS(.v12)
    ],
    products: [
        .library(
            name: "DataLiteCore",
            targets: ["DataLiteCore"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/angd-dev/data-lite-c.git", from: "2.0.0"),
        .package(url: "https://github.com/apple/swift-collections.git", from: "1.1.4"),
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "DataLiteCore",
            dependencies: [
                .product(name: "DataLiteC", package: "data-lite-c"),
                .product(name: "OrderedCollections", package: "swift-collections")
            ],
            cSettings: [
                .define("SQLITE_HAS_CODEC")
            ]
        ),
        .testTarget(
            name: "DataLiteCoreTests",
            dependencies: ["DataLiteCore"],
            cSettings: [
                .define("SQLITE_HAS_CODEC")
            ]
        )
    ]
)
