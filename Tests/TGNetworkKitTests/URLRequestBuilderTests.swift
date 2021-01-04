//
//  File.swift
//  
//
//  Created by Taylor Guidon on 1/5/20.
//

import XCTest
@testable import TGNetworkKit

final class URLRequestBuilderTests: XCTestCase {

    func testURLRequestBuilderBuildReturnsNotNil() {
        let apiRequest = APIRequest.buildMock()
        let builder = URLRequestBuilder()
        XCTAssertNotNil(builder.build(apiRequest: apiRequest))
    }

    func testURLRequestBuilderBuildReturnsNil() {
        let apiRequest = APIRequest.buildMock(host: "example.com", path: "auth/login")
        let builder = URLRequestBuilder()
        XCTAssertNil(builder.build(apiRequest: apiRequest))
    }

    func testURLRequestBuilderBuildAPIRequestRequiredProperties() {
        let apiRequest = APIRequest.buildMock(method: .get, scheme: "https", host: "example.com", path: "/path")
        let builder = URLRequestBuilder()
        guard let request = builder.build(apiRequest: apiRequest) else {
            XCTFail("urlRequest is nil")
            return
        }

        XCTAssertEqual(request.url?.absoluteString, "https://example.com/path")
        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertNil(request.httpBody)
    }

    func testURLRequestBuilderBuildAPIRequestAllProperties() {
        let parameters: Parameters = [URLQueryItem(name: "foo", value: "bar")]
        let headers: Headers = ["type": "json", "number": "101"]
        let data = MockBody(id: "1", value: 100).asData
        let apiRequest = APIRequest.buildMock(
            method: .get, scheme: "https", host: "example.com", path: "/path", headers: headers, params: parameters, data: data
        )
        let builder = URLRequestBuilder()
        guard let request = builder.build(apiRequest: apiRequest) else {
            XCTFail("urlRequest is nil")
            return
        }

        XCTAssertEqual(request.url?.absoluteString, "https://example.com/path?foo=bar")
        XCTAssertEqual(request.value(forHTTPHeaderField: "type"), "json")
        XCTAssertEqual(request.value(forHTTPHeaderField: "number"), "101")
        XCTAssertNotNil(request.httpBody)
    }

    static var urlRequestBuilderTests = [
        ("testURLRequestBuilderBuildReturnsNotNil", testURLRequestBuilderBuildReturnsNotNil),
        ("testURLRequestBuilderBuildReturnsNil", testURLRequestBuilderBuildReturnsNil),
        ("testURLRequestBuilderBuildAPIRequestRequiredProperties", testURLRequestBuilderBuildAPIRequestRequiredProperties),
        ("testURLRequestBuilderBuildAPIRequestAllProperties", testURLRequestBuilderBuildAPIRequestAllProperties)
    ]
}
