//
//  LeafView.swift
//
//
//  Created by Jan K on 27/05/2021.
//

import LeafKit
import Apodini

public struct LeafView: ResponseTransformable {
    private let context: [String: LeafData]
    private let path: String
    private let information: [InformationKey: String]
    private let fileio: NonBlockingFileIO
    private let resourcesDir: String
    
    public init(_ path: String, _ context: [String: LeafData]?, information: [InformationKey: String]?, fileio: NonBlockingFileIO, resourcesDir: String) {
        self.path = path
        self.context = context ?? [:]
        self.information = information ?? [:]
        self.fileio = fileio
        self.resourcesDir = resourcesDir
    }
    
    public func transformToResponse(on eventLoop: EventLoop) -> EventLoopFuture<Response<Raw>> {
        let sources = LeafSources.singleSource(NIOLeafFiles(fileio: fileio, limits: .onlyLeafExtensions, sandboxDirectory: resourcesDir, viewDirectory: resourcesDir, defaultExtension: "leaf"))
        
        let renderer = LeafRenderer(configuration: LeafConfiguration(rootDirectory: resourcesDir), sources: sources, eventLoop: eventLoop)
        
        return renderer.render(path: path, context: context)
            .map { renderedHTML in
                let raw = Raw(renderedHTML, type: MimeType.text(.html, parameters: [:]))
                return Response.send(raw, information: information)
            }
    }
}
