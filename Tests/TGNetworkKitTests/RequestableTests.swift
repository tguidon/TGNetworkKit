//
//  File.swift
//  
//
//  Created by Taylor Guidon on 6/24/19.
//

import XCTest
@testable import TGNetworkKit

final class RequestableTests: XCTestCase {

    func testRequestableMakeRequestWithPath() {
        struct Model: Requestable {

            static var host: String {
                return "example.com"
            }

            static var path: String? {
                return "/path/to/data"
            }
        }

        let request = Model.buildURLComponents()
        XCTAssertEqual(request.url?.absoluteString, "https://example.com/path/to/data")
    }

    func testRequestableMakeRequestWithNilPath() {
        struct Model: Requestable {

            static var host: String {
                return "example.com"
            }
        }

        XCTAssertNil(Model.path)
        let request = Model.buildURLComponents()
        XCTAssertEqual(request.url?.absoluteString, "https://example.com")
    }

    static var requestableTests = [
        ("testRequestableMakeRequestWithPath", testRequestableMakeRequestWithPath),
        ("testRequestableMakeRequestWithNilPath", testRequestableMakeRequestWithNilPath)
    ]
}
