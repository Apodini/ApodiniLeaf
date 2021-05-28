//
//  File.swift
//  
//
//  Created by Jan K on 28/05/2021.
//

import Apodini
import LeafKit

extension Application {
    var leafRenderer: LeafRenderer {
        let sources = LeafSources.singleSource(
            NIOLeafFiles(
                fileio: self.fileio,
                limits: .onlyLeafExtensions,
                sandboxDirectory: self.directory.resourcesDirectory + "Views/",
                viewDirectory: self.directory.resourcesDirectory + "Views/",
                defaultExtension: "leaf"))
        
        return LeafRenderer(
            configuration: LeafConfiguration(rootDirectory: self.directory.resourcesDirectory + "Views/"),
            sources: sources,
            eventLoop: self.eventLoopGroup.next())
    }
}
