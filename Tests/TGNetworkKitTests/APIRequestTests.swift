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
        struct Request: APIRequest {
            typealias Resource = MockResource

            var scheme: String {
                return "ftp"
            }

            var host: String {
                return "example.com"
            }

            var path: String? {
                return "/path/to/data"
            }

            var method: HTTPMethod {
                return .get
            }
        }

        let request = Request()
        XCTAssertEqual(request.scheme, "ftp")
        XCTAssertEqual(request.host, "example.com")
        XCTAssertEqual(request.path, "/path/to/data")
        XCTAssertEqual(request.method, HTTPMethod.get)
        XCTAssertNil(request.parameters)
        XCTAssertNil(request.headers)
        XCTAssertNil(request.body)
        let urlComponents = request.urlComponents
        XCTAssertEqual(urlComponents.url?.absoluteString, "ftp://example.com/path/to/data")
    }

    func testAPIRequestFullProperties() {
        struct Request: APIRequest {
            typealias Resource = MockResource

            var scheme: String {
                return "ftp"
            }

            var host: String {
                return "example.com"
            }

            var path: String? {
                return "/path/to/data"
            }

            var method: HTTPMethod {
                return .get
            }

            var parameters: Parameters? {
                return ["q": "foo"]
            }

            var headers: Headers? {
                return ["header": "value"]
            }

            var body: Encodable? {
                return MockBody(id: "1", value: 100)
            }
        }

        let request = Request()
        XCTAssertEqual(request.scheme, "ftp")
        XCTAssertEqual(request.host, "example.com")
        XCTAssertEqual(request.path, "/path/to/data")
        XCTAssertEqual(request.method, HTTPMethod.get)
        XCTAssertNotNil(request.parameters)
        XCTAssertNotNil(request.headers)
        XCTAssertNotNil(request.body)
        let urlComponents = request.urlComponents
        XCTAssertEqual(urlComponents.url?.absoluteString, "ftp://example.com/path/to/data")
    }

    func testAPIRequestURLComponentsWithPath() {
        struct Request: APIRequest {
            typealias Resource = MockResource

            var host: String {
                return "example.com"
            }

            var path: String? {
                  return "/path/to/data"
            }

            var method: HTTPMethod {
                return .get
            }
        }

        let request = Request()
        let urlComponents = request.urlComponents
        XCTAssertEqual(urlComponents.url?.absoluteString, "https://example.com/path/to/data")
    }

    func testAPIRequestURLComponentsWithNoPath() {
        struct Request: APIRequest {
            typealias Resource = MockResource

            var host: String {
                return "example.com"
            }

            var method: HTTPMethod {
                return .get
            }
        }

        let request = Request()
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
