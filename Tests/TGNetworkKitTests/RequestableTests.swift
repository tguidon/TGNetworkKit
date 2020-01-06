//
//  File.swift
//  
//
//  Created by Taylor Guidon on 6/24/19.
//

import XCTest
@testable import TGNetworkKit

final class RequestableTests: XCTestCase {

    func testRequestableBuildURLComponentsWithPath() {
        struct Model: Requestable {

            static var host: String {
                return "example.com"
            }

            static var path: String? {
                return "/path/to/data"
            }
        }

        let urlComponents = Model.buildURLComponents()
        XCTAssertEqual(urlComponents.url?.absoluteString, "https://example.com/path/to/data")
    }

    func testRequestableBuildURLComponentsWithNoPath() {
        struct Model: Requestable {

            static var host: String {
                return "example.com"
            }
        }

        XCTAssertNil(Model.path)
        let urlComponents = Model.buildURLComponents()
        XCTAssertEqual(urlComponents.url?.absoluteString, "https://example.com")
    }

    static var requestableTests = [
        ("testRequestableBuildURLComponentsWithPath", testRequestableBuildURLComponentsWithPath),
        ("testRequestableBuildURLComponentsWithNoPath", testRequestableBuildURLComponentsWithNoPath)
    ]
}
