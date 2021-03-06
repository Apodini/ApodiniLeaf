// swift-tools-version:5.5

//
// This source file is part of the Apodini Leaf open source project
//
// SPDX-FileCopyrightText: 2021 Paul Schmiedmayer and the project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//


import PackageDescription


let package = Package(
    name: "ApodiniLeaf",
    platforms: [
        .macOS(.v11)
    ],
    products: [
        .library(name: "ApodiniLeaf", targets: ["ApodiniLeaf"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
        .package(url: "https://github.com/Apodini/Apodini.git", .upToNextMinor(from: "0.9.1")),
        .package(url: "https://github.com/vapor/leaf-kit.git", from: "1.4.0")
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
