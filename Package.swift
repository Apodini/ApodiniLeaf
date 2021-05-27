// swift-tools-version:5.2

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
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/Apodini/Apodini.git", .branch("feature/rawRequest")),
        .package(url: "https://github.com/vapor/leaf.git", from: "4.0.0")
    ],
    targets: [
        .target(
                name: "ApodiniLeaf",
                dependencies: [
                    .product(name: "Leaf", package: "leaf"),
                    .product(name: "Apodini", package: "Apodini"),
                    .product(name: "ApodiniREST", package: "Apodini"),
                    .product(name: "ApodiniOpenAPI", package: "Apodini")
                ])
    ]
)
