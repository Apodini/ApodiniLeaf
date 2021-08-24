//
// This source file is part of the Apodini Leaf open source project
//
// SPDX-FileCopyrightText: 2021 Paul Schmiedmayer and the project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Apodini
import LeafKit


extension LeafRenderer {
    /// Creates a ``Blob`` with a ``MimeType`` of text/html that renders the leaf template that can be passed to an Apodini ``Response``.
    /// - Parameters:
    ///   - path: The resource path of the Leaf file that should be used to render the HTML page
    ///   - context: The context that should be used to render the leaf template.
    /// - Returns: Returns an ``EventLoopFuture`` of the type ``Blob`` containing the rendered HTML page
    public func render(path: String, context: [String: LeafData] = [:]) -> EventLoopFuture<Blob> {
        render(path: path, context: context)
            .map { byteBuffer in
                Blob(byteBuffer, type: .text(.html))
            }
    }
    
    /// Creates a ``Blob`` with a ``MimeType`` of text/html that renders the leaf template that can be passed to an Apodini ``Response``.
    /// - Parameters:
    ///   - path: The resource path of the Leaf file that should be used to render the HTML page
    ///   - context: The context that should be used to render the leaf template.
    /// - Returns: Returns an ``EventLoopFuture`` of the type ``Blob`` containing the rendered HTML page
    public func render<C: Encodable>(path: String, context: C) -> EventLoopFuture<Blob> {
        let data: [String: LeafData]
        
        do {
            data = try LeafEncoder().encode(context)
        } catch {
            return eventLoop.makeFailedFuture(error)
        }
        
        return render(path: path, context: data)
    }
}
