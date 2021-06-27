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
        
        let app = try TestWebService.start(waitForCompletion: false)
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
