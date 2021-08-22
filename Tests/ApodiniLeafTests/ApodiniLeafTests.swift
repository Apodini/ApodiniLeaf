//
// This source file is part of the Apodini Leaf open source project
//
// SPDX-FileCopyrightText: 2021 Paul Schmiedmayer and the project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

@testable import Apodini
@testable import ApodiniLeaf
import XCTest


final class ApodiniLeafTests: XCTestCase {
    func testApodiniLeaf() throws {
        struct TestWebService: WebService {
            var configuration: Configuration {
                LeafConfiguration(Bundle.module)
            }
            
            var content: some Component {
                Text("Test")
            }
        }
        
        let app = try TestWebService.start(mode: .boot)
        let leafRenderer = app.leafRenderer
        
        
        struct TestContent: Encodable {
            let title: String
            let body: String
        }
        
        let content = TestContent(title: "Paul", body: "Hello!")
        let renderResult = try leafRenderer.render(path: "Test", context: content).wait()
        
        XCTAssertEqual(renderResult.type, .text(.html))
        let html = renderResult.byteBuffer.getString(at: renderResult.byteBuffer.readerIndex, length: renderResult.byteBuffer.readableBytes)
        XCTAssertEqual(html, "<title>Paul</title>\n<body>Hello!</body>\n")
    }
}
