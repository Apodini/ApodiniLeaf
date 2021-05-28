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
    private let renderer: LeafRenderer
    private let information: [InformationKey: String]
    
    public init(_ path: String, with renderer: LeafRenderer, context: [String: LeafData] = [:], information: [InformationKey: String] = [:]) {
        self.path = path
        self.context = context
        self.renderer = renderer
        self.information = information
    }
    
    public func transformToResponse(on eventLoop: EventLoop) -> EventLoopFuture<Response<Raw>> {
        renderer.render(path: path, context: context)
            .map { renderedHTML in
                let raw = Raw(renderedHTML, type: MimeType.text(.html, parameters: [:]))
                return Response.send(raw, information: information)
            }
    }
}
