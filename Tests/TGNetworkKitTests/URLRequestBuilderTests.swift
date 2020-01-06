//
//  File.swift
//  
//
//  Created by Taylor Guidon on 1/5/20.
//

import XCTest
@testable import TGNetworkKit

final class URLRequestBuilderTests: XCTestCase {

    func testURLRequestBuilderBuild() {
        let apiRequest = MockAPIRequest()
        let builder = URLRequestBuilder()
        let request = try? builder.build(apiRequest: apiRequest)

        XCTAssertNotNil(request?.url)
        XCTAssertNotNil(request?.url?.absoluteString)
        XCTAssertEqual(request?.httpMethod, "GET")
        XCTAssertNotNil(request?.httpBody)
    }

    static var urlRequestBuilderTests = [
        ("testURLRequestBuilderBuild", testURLRequestBuilderBuild)
    ]
}
