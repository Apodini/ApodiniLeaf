import Apodini
import Foundation
import LeafKit


private struct LeafRendererStorageKey: StorageKey {
    typealias Value = LeafRenderer
}


extension Application {
    /// A `LeafRenderer` instance that can be used to create `Blob`s using or
    /// `render(path:context:)`
    public var leafRenderer: LeafRenderer {
        guard let leafRenderer = self.storage[LeafRendererStorageKey.self] else {
            fatalError(
                """
                Could not create a LeafRenderer.
                Please use a LeafConfiguration to define the Bundle or resource path where Leaf templates should be loaded from.
                """
            )
        }
        return leafRenderer
    }
}


/// Configures the `LeafRenderer` to define the `Bundle` or resource path where Leaf templates should be loaded from.
public final class LeafConfiguration: Configuration {
    let resourcePath: String
    
    
    /// - Parameter resourcePath: Defines a resource path where the Leaf templates should be loaded from
    public init(_ resourcePath: String) {
        self.resourcePath = resourcePath
    }
    
    /// - Parameter resourcePath: Defines the `Bundle` where the Leaf templates should be loaded from.
    /// If you use Swift Package resources you can use `Bundle.module` to load the resources from the associated resources bundle.
    public convenience init(_ bundle: Bundle) {
        guard let resourcePath = bundle.resourcePath else {
            fatalError("The bundle \(bundle) has no resource path. Could not initialize the LeafRenderer.")
        }
        self.init(resourcePath)
    }
    
    
    public func configure(_ app: Application) {
        let sources = LeafSources.singleSource(
            NIOLeafFiles(
                fileio: app.fileio,
                limits: .onlyLeafExtensions,
                sandboxDirectory: resourcePath,
                viewDirectory: resourcePath,
                defaultExtension: "leaf"
            )
        )
        
        let renderer = LeafRenderer(
            configuration: LeafKit.LeafConfiguration(rootDirectory: resourcePath),
            sources: sources,
            eventLoop: app.eventLoopGroup.next()
        )
        
        app.storage[LeafRendererStorageKey.self] = renderer
    }
}
