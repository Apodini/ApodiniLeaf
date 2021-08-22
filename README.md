<!--
                  
This source file is part of the Apodini Leaf open source project

SPDX-FileCopyrightText: 2021 Paul Schmiedmayer and the project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>

SPDX-License-Identifier: MIT
             
-->

# Apodini Leaf

[![DOI](https://zenodo.org/badge/371102138.svg)](https://zenodo.org/badge/latestdoi/371102138)
[![codecov](https://codecov.io/gh/Apodini/ApodiniLeaf/branch/develop/graph/badge.svg?token=Rd38F6yTCC)](https://codecov.io/gh/Apodini/ApodiniLeaf)
[![jazzy](https://raw.githubusercontent.com/Apodini/ApodiniLeaf/gh-pages/badge.svg)](https://apodini.github.io/ApodiniLeaf/)
[![Build and Test](https://github.com/Apodini/ApodiniLeaf/actions/workflows/build-and-test.yml/badge.svg)](https://github.com/Apodini/ApodiniLeaf/actions/workflows/build-and-test.yml)

Apodini Leaf is a small [Apodini](https://github.com/Apodini/Apodini) extension to support the [Leaf](https://github.com/vapor/leaf-kit) teamplating engine.
The [Leaf documentation](https://docs.vapor.codes/4.0/leaf/overview/) provides a good overview of the usage of Leaf.

## Integrate Swift Package

To use Apodini Leaf you have to add it as a depenency to your Swift Package in your Package.swift file. As Apodini Leaf is extending [Apodini](https://github.com/Apodini/Apodini) it is also currenlty using 0.X releases and every minor version number increment could include breaking changes. Therefore using `.upToNextMinor(from: "0.1.0")` is advised:
```swift
dependencies: [
    .package(url: "https://github.com/Apodini/ApodiniLeaf.git", .upToNextMinor(from: "0.1.0")),
    // More package dependencies ...
]
```
Next add ApodiniLeaf as a target dependency to your web service target:
```swift
.target(
    name: "MyWebService",
    dependencies: [
        .product(name: "Apodini", package: "Apodini"),
        .product(name: "ApodiniLeaf", package: "ApodiniLeaf"),
        // More target dependencies ...
    ]
)
```
Now you can import ApodiniLeaf in your web service:
```swift
import ApodiniLeaf
```

## Usage

To use ApodiniLeaf, you have to define a `LeafConfiguration` in your `WebService` instance. You can pass in a `Bundle` or absolute path.
In this example we have defined [Swift Package resources using the resources definition](https://developer.apple.com/documentation/swift_packages/bundling_resources_with_a_swift_package) in our Package.Swift file:
```swift
.testTarget(
    name: "MyWebService",
    dependencies: [
        // ...
    ],
    resources: [
        .process("Resources")
    ]
)
```

The folder structure looks like follows:
```
MyWebService
├── Package.swift
├── Resources
│   ├── Example.leaf
└── Sources
    └── ...
```

The example Leaf file has the following content:
```html
<title>#(title)</title>
<body>#(body)</body>
```

We use the `Bundle.module` to access the created resources bundle in the `WebService` configuration to configure the `LeafRenderer` as follows:
```swift
struct TestWebService: WebService {
    var configuration: Configuration {
        LeafConfiguration(Bundle.module)
    }
    
    var content: some Component {
        Text("Test")
    }
}
```

Now that we have defined the configuration, we can use the `LeafRenderer` in our Apodini `Handlers` using the `@Environment` property wrapper:
```swift
struct ExampleHandler: Handler {
    @Environment(\.leafRenderer) var leafRenderer: LeafRenderer
    
    
    func handle() -> some ResponseTransformable {
        struct ExampleContent: Encodable {
            let title: String
            let body: String
        }
        
        let content = ExampleContent(title: "Paul", body: "Hello!")
        return leafRenderer.render(path: "Example", context: content)
    }
}
```
The `ExampleHandler` uses the `@Environment` property wrapper to retrieve the `LeafRenderer` and uses a Swift `struct` to fill in the content and renders the HTML using the `LeafRenderer`'s `render(path:context:)` method. For more information about Leaf, please refer to the [Leaf documentation](https://docs.vapor.codes/4.0/leaf/overview/).

## Contributing
Contributions to this project are welcome. Please make sure to read the [contribution guidelines](https://github.com/Apodini/.github/blob/main/CONTRIBUTING.md) and the [contributor covenant code of conduct](https://github.com/Apodini/.github/blob/main/CODE_OF_CONDUCT.md) first.

## License
This project is licensed under the MIT License. See [License](https://github.com/Apodini/ApodiniLeaf/blob/develop/LICENSE) for more information.
