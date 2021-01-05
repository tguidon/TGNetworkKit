//
//  File.swift
//  
//
//  Created by Taylor Guidon on 3/15/20.
//

import XCTest
@testable import TGNetworkKit

final class APIErrorTests: XCTestCase {

    enum MockCodingKey: CodingKey {
        case bar
    }

    func testAPIErrorNetworkingErrorEquality() {
        let error1 = APIError.networkingError(MockError.failed("fail"))
        let error2 = APIError.networkingError(MockError.failed("failed again"))

        XCTAssertEqual(error1, error1)
        XCTAssertNotEqual(error1, error2)
    }

    func testAPIErrorServerErrorEquality() {
        let error1 = APIError.serverError(500, "server fail".data(using: .utf8))
        let error2 = APIError.serverError(500, "server gone".data(using: .utf8))
        let error3 = APIError.serverError(501, "server fail".data(using: .utf8))


        XCTAssertEqual(error1, error1)
        XCTAssertNotEqual(error1, error2)
        XCTAssertNotEqual(error1, error3)
    }

    func testAPIErrorRequestErrorEquality() {
        let error1 = APIError.requestError(400, "request unauthorized".data(using: .utf8))
        let error2 = APIError.requestError(400, "forbidden".data(using: .utf8))
        let error3 = APIError.requestError(404, "request unauthorized".data(using: .utf8))

        XCTAssertEqual(error1, error1)
        XCTAssertNotEqual(error1, error2)
        XCTAssertNotEqual(error1, error3)
    }

    func testAPIErrorRedirectionErrorEquality() {
        let error1 = APIError.redirectionError(300, "redirect error".data(using: .utf8))
        let error2 = APIError.redirectionError(300, "can not find redirect".data(using: .utf8))
        let error3 = APIError.redirectionError(301, "redirect error".data(using: .utf8))

        XCTAssertEqual(error1, error1)
        XCTAssertNotEqual(error1, error2)
        XCTAssertNotEqual(error1, error3)
    }

    func testAPIErrorUnhandledHTTPStatuEquality() {
        let error1 = APIError.unhandledHTTPStatus(900, "whoa, this error".data(using: .utf8))
        let error2 = APIError.unhandledHTTPStatus(900, "to infinity and...".data(using: .utf8))
        let error3 = APIError.unhandledHTTPStatus(999, "whoa, this error".data(using: .utf8))

        XCTAssertEqual(error1, error1)
        XCTAssertNotEqual(error1, error2)
        XCTAssertNotEqual(error1, error3)
    }

    func testAPIErrorInvalidResponsequality() {
        let error1 = APIError.invalidResponse
        let error2 = APIError.dataIsNil

        XCTAssertEqual(error1, error1)
        XCTAssertNotEqual(error1, error2)
    }

    func testAPIErrorDecodingErrorEquality() {
        let context1 = DecodingError.Context(codingPath: [MockCodingKey.bar], debugDescription: "bar")
        let error1 = APIError.decodingError(DecodingError.dataCorrupted(context1))
        let error2 =  APIError.invalidResponse

        XCTAssertEqual(error1, error1)
        XCTAssertNotEqual(error1, error2)
    }

    func testAPIErrorParseErrorEquality() {
        let error1 = APIError.parseError(MockError.failed("failed to parse"))
        let error2 = APIError.parseError(MockError.failed("failed again"))

        XCTAssertEqual(error1, error1)
        XCTAssertNotEqual(error1, error2)
    }

    func testAPIErrorFailedToBuildURLRequestURLEquality() {
        let error1 = APIError.failedToBuildURLRequestURL
        let error2 = APIError.invalidResponse

        XCTAssertEqual(error1, error1)
        XCTAssertNotEqual(error1, error2)
    }

    func testAPIErrorDataIsNilEquality() {
        let error1 = APIError.dataIsNil
        let error2 = APIError.invalidResponse

        XCTAssertEqual(error1, error1)
        XCTAssertNotEqual(error1, error2)
    }

    func testAPIErrorUnhandledErrorEquality() {
        let error1 = APIError.unhandled("oops we don't handle this")
        let error2 = APIError.unhandled("doh")

        XCTAssertEqual(error1, error1)
        XCTAssertNotEqual(error1, error2)
    }

    func testAPIErrorStatusCode() {
        let testCases: [(APIError, Int?)] = [
            (APIError.serverError(500, nil), 500),
            (APIError.redirectionError(300, nil), 300),
            (APIError.serverError(400, nil), 400),
            (APIError.unhandledHTTPStatus(999, nil), 999),
            (APIError.dataIsNil, nil)
        ]

        testCases.forEach {
            XCTAssertEqual($0.httpStatusCode, $1)
        }
    }

    static var apiErrorTests = [
        ("testAPIErrorNetworkingErrorEquality", testAPIErrorNetworkingErrorEquality),
        ("testAPIErrorServerErrorEquality", testAPIErrorServerErrorEquality),
        ("testAPIErrorRequestErrorEquality", testAPIErrorRequestErrorEquality),
        ("testAPIErrorRedirectionErrorEquality", testAPIErrorRedirectionErrorEquality),
        ("testAPIErrorUnhandledHTTPStatuEquality", testAPIErrorUnhandledHTTPStatuEquality),
        ("testAPIErrorInvalidResponsequality", testAPIErrorInvalidResponsequality),
        ("testAPIErrorDecodingErrorEquality", testAPIErrorDecodingErrorEquality),
        ("testAPIErrorParseErrorEquality", testAPIErrorParseErrorEquality),
        ("testAPIErrorFailedToBuildURLRequestURLEquality", testAPIErrorFailedToBuildURLRequestURLEquality),
        ("testAPIErrorDataIsNilEquality", testAPIErrorDataIsNilEquality),
        ("testAPIErrorUnhandledErrorEquality", testAPIErrorUnhandledErrorEquality),
        ("testAPIErrorStatusCode", testAPIErrorStatusCode)
    ]
}
