//
//  File.swift
//  
//
//  Created by Taylor Guidon on 1/5/20.
//

import XCTest
@testable import TGNetworkKit

final class URLRequestBuilderTests: XCTestCase {

    func testURLRequestBuilderBuildNoThrow() {
        let apiRequest = MockAPIRequest()
        let builder = URLRequestBuilder()
        XCTAssertNoThrow(try builder.build(apiRequest: apiRequest))
    }

    func testURLRequestBuilderBuildThrows() {
        let apiRequest = MockAPIRequest()
        let builder = MockRequestBuilder()
        XCTAssertThrowsError(try builder.build(apiRequest: apiRequest))
    }

    func testURLRequestBuilderBuildAPIRequestRequiredProperties() {
        let apiRequest = MockAPIRequest(scheme: "https", host: "example.com", path: "/path", method: .get)
        let builder = URLRequestBuilder()
        let request = try? builder.build(apiRequest: apiRequest)

        XCTAssertEqual(request?.url?.absoluteString, "https://example.com/path")
        XCTAssertEqual(request?.httpMethod, "GET")
        XCTAssertNil(request?.httpBody)
    }

    func testURLRequestBuilderBuildAPIRequestAllProperties() {
        let parameters: Parameters = ["foo": "bar"]
        let headers: Headers = ["type": "json", "number": "101"]
        let body: Body = MockBody(id: "1", value: 100)
        let apiRequest = MockAPIRequest(
            scheme: "https", host: "example.com", path: "/path", method: .get, parameters: parameters, headers: headers, body: body
        )
        let builder = URLRequestBuilder()
        let request = try? builder.build(apiRequest: apiRequest)

        XCTAssertEqual(request?.url?.absoluteString, "https://example.com/path?foo=bar")
        XCTAssertEqual(request?.value(forHTTPHeaderField: "type"), "json")
        XCTAssertEqual(request?.value(forHTTPHeaderField: "number"), "101")
        XCTAssertNotNil(request?.httpBody)
    }

    static var urlRequestBuilderTests = [
        ("testURLRequestBuilderBuildNoThrow", testURLRequestBuilderBuildNoThrow),
        ("testURLRequestBuilderBuildThrows", testURLRequestBuilderBuildThrows),
        ("testURLRequestBuilderBuildAPIRequestRequiredProperties", testURLRequestBuilderBuildAPIRequestRequiredProperties),
        ("testURLRequestBuilderBuildAPIRequestAllProperties", testURLRequestBuilderBuildAPIRequestAllProperties)
    ]
}
