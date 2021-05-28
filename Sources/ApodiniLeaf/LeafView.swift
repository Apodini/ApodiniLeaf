//
//  LeafView.swift
//
//
//  Created by Jan K on 27/05/2021.
//

import LeafKit
import Apodini

public struct LeafView<Context>: ResponseTransformable where Context: Encodable {
    private let path: String
    private let renderer: LeafRenderer
    private let context: Context?
    private let information: [InformationKey: String]
    
    public init(_ path: String, with renderer: LeafRenderer, context: Context? = nil, information: [InformationKey: String] = [:]) {
        self.path = path
        self.context = context
        self.renderer = renderer
        self.information = information
    }
    
    public func transformToResponse(on eventLoop: EventLoop) -> EventLoopFuture<Response<Raw>> {
        let data: [String: LeafData]
        
        do {
            data = try LeafEncoder().encode(context)
        } catch {
            return renderer.eventLoop.makeFailedFuture(error)
        }
        
        return renderer.render(path: path, context: data)
            .map { renderedHTML in
                let raw = Raw(renderedHTML, type: MimeType.text(.html, parameters: [:]))
                return Response.send(raw, information: information)
            }
    }
}
