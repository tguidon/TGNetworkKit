//
//  File.swift
//  
//
//  Created by Taylor Guidon on 1/5/20.
//

import XCTest
@testable import TGNetworkKit

final class APIRequestTests: XCTestCase {

    func testAPIRequestProperties() {
        let request = APIRequest(
            method: .get,
            scheme: "ftp",
            host: "example.com",
            path: "/path/to/data"
        )

        XCTAssertEqual(request.scheme, "ftp")
        XCTAssertEqual(request.host, "example.com")
        XCTAssertEqual(request.path, "/path/to/data")
        XCTAssertEqual(request.method, HTTPMethod.get)
        XCTAssertNil(request.params)
        XCTAssertNil(request.headers)
        XCTAssertNil(request.data)
        let urlComponents = request.urlComponents
        XCTAssertEqual(urlComponents.url?.absoluteString, "ftp://example.com/path/to/data")
    }

    func testAPIRequestFullProperties() {
        let request = APIRequest(
            method: .get,
            scheme: "ftp",
            host: "example.com",
            path: "/path/to/data",
            headers: ["header": "value"],
            params: [URLQueryItem(name: "q", value: "foo")],
            data: MockBody(id: "1", value: 100).asData
        )

        XCTAssertEqual(request.scheme, "ftp")
        XCTAssertEqual(request.host, "example.com")
        XCTAssertEqual(request.path, "/path/to/data")
        XCTAssertEqual(request.method, HTTPMethod.get)
        XCTAssertNotNil(request.params)
        XCTAssertNotNil(request.headers)
        XCTAssertNotNil(request.data)
        let urlComponents = request.urlComponents
        XCTAssertEqual(urlComponents.url?.absoluteString, "ftp://example.com/path/to/data")
    }

    func testAPIRequestURLComponentsWithPath() {
        let request = APIRequest(method: .get, host: "example.com", path: "/path/to/data")
        let urlComponents = request.urlComponents
        XCTAssertEqual(urlComponents.url?.absoluteString, "https://example.com/path/to/data")
    }

    func testAPIRequestURLComponentsWithNoPath() {
        let request = APIRequest(method: .get, host: "example.com")
        let urlComponents = request.urlComponents
        XCTAssertEqual(urlComponents.url?.absoluteString, "https://example.com")
    }

    static var apiRequestTests = [
        ("testAPIRequestProperties", testAPIRequestProperties),
        ("testAPIRequestFullProperties", testAPIRequestFullProperties),
        ("testAPIRequestURLComponentsWithPath", testAPIRequestURLComponentsWithPath),
        ("testAPIRequestURLComponentsWithNoPath", testAPIRequestURLComponentsWithNoPath)
    ]
}
