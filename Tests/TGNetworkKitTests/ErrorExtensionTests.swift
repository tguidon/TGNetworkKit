//
//  File.swift
//  
//
//  Created by Taylor Guidon on 3/15/20.
//

import XCTest
@testable import TGNetworkKit

final class ErrorExtensionTests: XCTestCase {

    func testErrorAsAPIError() {
        let error = makeMaskedAPIError(apiError: APIError.dataIsNil)

        XCTAssertEqual(error.asAPIError, APIError.dataIsNil)
    }

    func testErrorAsAPIErrorUnhandled() {
        let error = makeMaskedAPIError(apiError: MockError.failed("Fake Error"))

        XCTAssertEqual(error.asAPIError, APIError.unhandled("Fake Error"))
    }

    private func makeMaskedAPIError(apiError: Error) -> Error {
        return apiError
    }

    static var errorExtensionTests = [
        ("testErrorAsAPIError", testErrorAsAPIError),
        ("testErrorAsAPIErrorUnhandled", testErrorAsAPIErrorUnhandled)
    ]
}
