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
                sandboxDirectory: Bundle.main.resourcePath! + "Views/",
                viewDirectory: Bundle.main.resourcePath! + "Views/",
                defaultExtension: "leaf"))
        
        return LeafRenderer(
            configuration: LeafConfiguration(rootDirectory: Bundle.main.resourcePath! + "Views/"),
            sources: sources,
            eventLoop: self.eventLoopGroup.next())
    }
}
