// swift-tools-version:5.3

import PackageDescription


let package = Package(
    name: "ApodiniLeaf",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .library(name: "ApodiniLeaf", targets: ["ApodiniLeaf"])
    ],
    dependencies: [
        .package(url: "https://github.com/Apodini/Apodini.git", .upToNextMinor(from: "0.2.0")),
        .package(url: "https://github.com/vapor/leaf-kit.git", from: "1.2.0")
    ],
    targets: [
        .target(
            name: "ApodiniLeaf",
            dependencies: [
                .product(name: "Apodini", package: "Apodini"),
                .product(name: "LeafKit", package: "leaf-kit")
            ]
        ),
        .testTarget(
            name: "ApodiniLeafTests",
            dependencies: [
                .target(name: "ApodiniLeaf")
            ],
            resources: [
                .process("Resources")
            ]
        )
    ]
)
