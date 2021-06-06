//
//  File.swift
//  
//
//  Created by Jan K on 28/05/2021.
//

import Apodini
import LeafKit
import Foundation

extension Application {
    public var leafRenderer: LeafRenderer {
        self.storage[LeafRendererStorageKey.self]!
    }
}

public final class ApodiniLeafConfiguration: Configuration {
    let resourcePath: String
    
    public init(_ resourcePath: String) {
        self.resourcePath = resourcePath
    }
    
    public func configure(_ app: Application) {
        let sources = LeafSources.singleSource(
            NIOLeafFiles(
                fileio: app.fileio,
                limits: .onlyLeafExtensions,
                sandboxDirectory: resourcePath,
                viewDirectory: resourcePath,
                defaultExtension: "leaf"))
        
        let renderer = LeafRenderer(
            configuration: LeafConfiguration(rootDirectory: resourcePath),
            sources: sources,
            eventLoop: app.eventLoopGroup.next())
        
        app.storage[LeafRendererStorageKey.self] = renderer
    }
}

fileprivate struct LeafRendererStorageKey: StorageKey {
    typealias Value = LeafRenderer
}
