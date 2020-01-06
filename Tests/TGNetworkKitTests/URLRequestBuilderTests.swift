//
//  File.swift
//  
//
//  Created by Taylor Guidon on 1/5/20.
//

import XCTest
@testable import TGNetworkKit

final class URLRequestBuilderTests: XCTestCase {

    struct MockBody: Encodable {
        let data: DataBody

        init(id: String, value: Int) {
            let data = DataBody(id: id, value: value)
            self.data = data
        }
    }

    struct DataBody: Encodable {
        let id: String
        let value: Int
    }

    func testURLRequestBuilderBuild() {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "example.com"
        let method = HTTPMethod.get
        let body = MockBody(id: "abc", value: 100)
        let urlParameters = ["foo": "bar", "baz": "bip"]

        let builder = URLRequestBuilder(urlComponents: components, method: method, body: body, urlParameters: urlParameters)
        let request = try? builder.build()

        XCTAssertEqual(request?.url, URL(string: "https://example.com?foo=bar&baz=bip"))
        XCTAssertEqual(request?.url?.absoluteString, "https://example.com?foo=bar&baz=bip")
        XCTAssertEqual(request?.httpMethod, "GET")
        XCTAssertNotNil(request?.httpBody)
    }

    static var urlRequestBuilderTests = [
        ("testURLRequestBuilderBuild", testURLRequestBuilderBuild)
    ]
}
