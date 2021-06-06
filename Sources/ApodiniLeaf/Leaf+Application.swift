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
        let sources = LeafSources.singleSource(
            NIOLeafFiles(
                fileio: self.fileio,
                limits: .onlyLeafExtensions,
                sandboxDirectory: Bundle.module.resourcePath! + "Views/",
                viewDirectory: Bundle.module.resourcePath! + "Views/",
                defaultExtension: "leaf"))
        
        return LeafRenderer(
            configuration: LeafConfiguration(rootDirectory: Bundle.module.resourcePath! + "Views/"),
            sources: sources,
            eventLoop: self.eventLoopGroup.next())
    }
}
